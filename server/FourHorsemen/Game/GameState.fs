module GameState

open Microsoft.FSharp.Data.UnitSystems.SI.UnitSymbols
open World
open Monster
open Player
open Entity
open System.Diagnostics
open Helpers
open System


//
let removePlayerFromWorldState (worldState : World) (player : Player.Player) : World =
    let newPlayers =
        worldState.players
        |> List.filter (fun p -> !p = player)

    { worldState with players = newPlayers }


let updatePlayerInList (players : Ref<Player> list) (player : Player) =
    players
    |> List.iter (fun p ->
        if p.Value.networkClientId = player.networkClientId then
            p := player
    )

//
type NetworkClientId = string

//
type PlayerAction =
    | PlayerSetName of (NetworkClientId * string)
    | PlayerMove of (NetworkClientId * Codegen.Proto.Vec2)
    | PlayerAttack of NetworkClientId


//
type GameStateMsg =
    | AddPlayer of Player
    | RemovePlayer of string            // Network client id
    | RunPlayerAction of PlayerAction
    | RunGameStep of float<s>              // dt
    | RegisterBroadcast of (World -> Async<unit>)


//
let distanceSq (p1 : Entity.Vec2) (p2 : Entity.Vec2) =
    let x = (p1.x - p2.x)
    let y = (p1.y - p2.y)
    (x * x) + (y * y)


// Finds the closest neighbors to point p, with consideration of a max range.
// If no neighbors within the max range, then we return None
let findClosestNeighborMaxRange (p : Entity.Vec2) (neighbors : Ref<Player> list) (maxRange : float32) : Ref<Player> list =
    let maxRangeSq = maxRange * maxRange

    // Probably more optimal way to go about this, naive approach for now.
    // Also, guessing that the filtering prior to sorting might be faster.
    neighbors
    |> List.map (fun n -> (n, distanceSq p n.Value.position))
    |> List.filter (fun (_, distanceSq) -> (distanceSq <= maxRangeSq))
    |> List.sortBy snd
    |> List.map fst


//
let runAI (worldState : World) (monsters : Monster[]) (dt : float<s>) : Monster[] =
    let rangeAggro = 65.0f
    let markRange = 65.0f   // 65-70 yards?'
    let markDebuffDuration = secondToMillisecond 75.0<s>

    
    monsters
    |> Array.map (fun b ->
        // Run boss debuff timers and player applications

        // Check timer for this boss
        let newMarkTimer =
            let tempNewMarkTimer = b.markTimer - dt

            if tempNewMarkTimer <= 0.0<s> then
                // If the timer has reached 0 then:
                //   1. Reset the timer
                //   2. Apply debuff to all nearby players
                let playersAddNewMarks = findClosestNeighborMaxRange b.position worldState.players markRange

                playersAddNewMarks
                |> List.iter (fun p ->
                    let updateStackCount (m : MarkTimerAndStacks option) =
                        (m
                         |> Option.map snd
                         |> Option.defaultValue 0) + 1

                    let newDebuffs = 
                        match b.type_ with
                        | Mograine -> { p.Value.debuffs with mograineMark = Some (markDebuffDuration, updateStackCount p.Value.debuffs.mograineMark) }
                        | Thane -> { p.Value.debuffs with thaneMark = Some (markDebuffDuration, updateStackCount p.Value.debuffs.thaneMark) }
                        | Zeliek -> { p.Value.debuffs with zeliekMark = Some (markDebuffDuration, updateStackCount p.Value.debuffs.zeliekMark) }
                        | Blaumeux -> { p.Value.debuffs with blaumeuxMark = Some (markDebuffDuration, updateStackCount p.Value.debuffs.blaumeuxMark) }

                    p.Value <- { !p with debuffs = newDebuffs }
                )

                // Return the reset value of the mark timer (12 seconds)
                markTimerFreq
            else
                tempNewMarkTimer

        // Update boss
        { b with markTimer = newMarkTimer }
    )
    |> Array.map (fun b ->
        // ShieldWall
        let healthPercent = (float32 b.curHealth) / (float32 b.maxHealth)
        
        // Check shield wall states
        if healthPercent < 0.50f && not b.shieldWall50Used then
            // TODO: Use ShieldWall 50%
            ()
        elif healthPercent < 0.20f && not b.shieldWall20Used then
            // TODO: Use ShieldWall 20%
            ()

        b
    )
    |> Array.map (fun b ->
        let newBossState =
            // Check range aggro on players if we currently have no threat
            match b.threat with
            | x :: xs ->
                // We have at least someone on the threat table, don't check range aggro, use same state
                b

            | [] ->
                // Combine all the threat tables from the bosses
                let combinedThreatTables : Ref<Player> seq =
                    worldState.bosses
                    |> Array.toSeq
                    |> Seq.map (fun b -> b.threat |> List.map fst)
                    |> Seq.concat

                // We don't have any player on threat table, check for closest. Additionally, add any players found on
                // other bosses' threat table - this will link them and cause all to attack at start.
                // If we find one, apply it to the threat table with 0 threat.
                findClosestNeighborMaxRange b.position worldState.players rangeAggro
                |> List.append (Seq.toList combinedThreatTables)
                |> List.tryHead
                |> Option.map (fun p -> { b with threat = [ (p, 0) ]})
                |> Option.defaultValue b

        newBossState
    )
    |> Array.map (fun b ->
        // Re-evaluate threat from players and select a target
        let newBossState =
            let newTarget =
                b.threat
                |> List.sortByDescending snd
                |> List.tryHead
                |> Option.map fst

            { b with target = newTarget }

        newBossState
    )
    |> Array.map (fun b ->
        // Move the boss towards its target
        let newBossState =
            match b.target with
            | Some t ->
                let distSq = distanceSq b.position t.Value.position
                let minDistanceSq = 8.0f * 8.0f

                // Check if we're in a minimum range to stop moving toward target
                if distSq <= minDistanceSq then
                    b
                else
                    // We're too far, move towards target
                    let newDirection = Math.Atan2((float (t.Value.position.y - b.position.y)), float (t.Value.position.x - b.position.x))
                    let newPosition : Entity.Vec2 =
                        { x = b.position.x + float32 (Math.Cos(newDirection) * b.speed * dt)
                          y = b.position.y + float32 (Math.Sin(newDirection) * b.speed * dt)
                        }

                    { b with direction = float32 newDirection; position = newPosition }

            | None ->
                b

        newBossState
    )



// Core game state
let gameState () =
    MailboxProcessor<GameStateMsg>.Start(fun inbox ->
        let rec loop (worldState : World) (broadcast : (World -> Async<unit>) option) =
            async {
                let! msg = inbox.Receive()
                match msg with
                | AddPlayer p ->
                    let newPlayers = ref p :: worldState.players
                    let newWorld = { worldState with players = newPlayers }
                    return! loop newWorld broadcast

                | RemovePlayer clientId ->
                    let lookupPlayer =
                        worldState.players
                        |> List.tryFind (fun p -> p.Value.networkClientId = clientId)

                    let newWorld =
                        match lookupPlayer with
                        | Some p -> removePlayerFromWorldState worldState !p
                        | None -> worldState

                    return! loop newWorld broadcast

                | RunPlayerAction action ->
                    match action with
                    | PlayerSetName (clientId, name) ->
                        // Find associated player with client and update name
                        worldState.players
                        |> List.tryFind (fun p -> p.Value.networkClientId = clientId)
                        |> Option.iter (fun p ->
                            p := { !p with name = name }
                        )

                    | PlayerMove (clientId, position) ->
                        // Find associated player with client and update position
                        worldState.players
                        |> List.tryFind (fun p -> p.Value.networkClientId = clientId)
                        |> Option.iter (fun p ->
                            p := { !p with position = denormPBtoVec2 worldState.dimensions position }
                        )


                    | _ ->
                        // TODO
                        ()

                    return! loop worldState broadcast

                | RunGameStep dt ->
                    printfn "Game step: %f" dt

                    // Run AI updates
                    let newBosses = runAI worldState worldState.bosses dt
                    let newWorldState = { worldState with bosses = newBosses }

                    // Finally, broadcast the world state to our clients
                    broadcast
                    |> Option.iter (fun b ->
                        b newWorldState
                        |> Async.StartImmediate
                    )

                    return! loop newWorldState broadcast

                | RegisterBroadcast f ->
                    return! loop worldState (Some f)
            }

        loop initWorld None
    )


// Core game loop, responsible for posting the game step message to the game state
let gameLoop (gameState : MailboxProcessor<GameStateMsg>) =
    async {
        let sw = Stopwatch()
        let mutable loop = true

        while loop do
            sw.Start()
            do! Async.Sleep 100
            
            gameState.Post (RunGameStep (((float sw.ElapsedMilliseconds) / 1000.0) * 1.0<s>))
            sw.Reset()
    }
