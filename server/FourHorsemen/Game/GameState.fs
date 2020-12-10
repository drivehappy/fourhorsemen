module GameState

open World
open Monster
open Player
open System.Diagnostics


//
let removePlayerFromWorldState (worldState : World) (player : Player.Player) : World =
    let newPlayers =
        worldState.players
        |> List.filter (fun p -> p = player)

    { worldState with players = newPlayers }

//
type NetworkClientId = string

//
type PlayerAction =
    | PlayerSetName of (NetworkClientId * string)
    | PlayerMove of NetworkClientId
    | PlayerAttack of NetworkClientId


//
type GameStateMsg =
    | AddPlayer of Player
    | RemovePlayer of string            // Network client id
    | RunPlayerAction of PlayerAction
    | RunGameStep of float              // dt
    | RegisterBroadcast of (World -> Async<unit>)


//
let runAI (monsters : Monster[]) : Monster[] =
    monsters
    |> Array.map (fun b ->
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


//
let gameState () =
    MailboxProcessor<GameStateMsg>.Start(fun inbox ->
        let rec loop (worldState : World) (broadcast : (World -> Async<unit>) option) =
            async {
                let! msg = inbox.Receive()
                match msg with
                | AddPlayer p ->
                    let newPlayers = p :: worldState.players
                    let newWorld = { worldState with players = newPlayers }
                    return! loop newWorld broadcast

                | RemovePlayer clientId ->
                    let lookupPlayer =
                        worldState.players
                        |> List.tryFind (fun p -> p.networkClientId = clientId)

                    let newWorld =
                        match lookupPlayer with
                        | Some p -> removePlayerFromWorldState worldState p
                        | None -> worldState

                    return! loop newWorld broadcast

                | RunPlayerAction action ->
                    // TODO

                    return! loop worldState broadcast

                | RunGameStep dt ->
                    printfn "Game step: %f" dt

                    // Run AI updates
                    let newBosses = runAI worldState.bosses
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


// TODO: Timer that Posts a message on an interval into gameState
let gameLoop (gameState : MailboxProcessor<GameStateMsg>) =
    async {
        let sw = Stopwatch()
        let mutable loop = true

        while loop do
            sw.Start()
            do! Async.Sleep 100
            
            gameState.Post (RunGameStep ((float sw.ElapsedMilliseconds) / 1000.0))
            sw.Reset()
    }


(*
let gameTick (world : World) =
    // Run boss actions
    world.bosses
    |> Array.iter (fun b ->
        let healthPercent = (float32 b.curHealth) / (float32 b.maxHealth)

        if healthPercent < 0.50f && not b.shieldWall50Used then
            // TODO: Use ShieldWall 50%
            ()
        if healthPercent < 0.20f && not b.shieldWall20Used then
            // TODO: Use ShieldWall 20%
            ()
    )
*)
