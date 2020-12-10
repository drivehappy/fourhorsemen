module GameState

open Player
open World
open Codegen.Proto


type GameMsg =
    | AddPlayer of (string * Player.Player)
    | RemovePlayer of string
    | ReceivedClientData of ((SC_Main -> Async<unit>) * string * CS_Main)


type ClientPlayerMapping = Map<string, Player.Player>


// Main handler for incoming network messages from the client
let handleClientMessage  (player : Player.Player) (pbCSMain : CS_Main) : SC_Main option =
    match pbCSMain.Type with
    | CS_Main.Types.Type.PlayerJoin ->
        let pj = if (isNull pbCSMain.PlayerJoin) then None else Some pbCSMain.PlayerJoin

        pj
        |> Option.iter (fun playerJoin ->
            let playerName = pbCSMain.PlayerJoin.PlayerName
            ()
        )

        let root = new SC_Main()
        root.Type <- SC_Main.Types.Type.InitialState
        root.AssignedPlayerId <- player.networkClientId

        Some root

    | _ ->
        // Unhandled
        None


//
let networkWorldState () =
    MailboxProcessor<GameMsg>.Start(fun inbox ->
        let rec loop (clientPlayer : ClientPlayerMapping) (worldState : World) =
            async {
                let! msg = inbox.Receive()
                match msg with
                | AddPlayer (clientId, player) ->
                    let newPlayers = player :: worldState.players
                    let newWorld = { worldState with players = newPlayers }
                    let newClientPlayerMap = clientPlayer.Add(clientId, player)

                    return! loop newClientPlayerMap newWorld

                | RemovePlayer clientId ->
                    let playerLookup = clientPlayer.TryFind(clientId)
                    let newPlayers =
                        match playerLookup with
                        | Some pl ->
                            worldState.players
                            |> List.filter (fun p -> p = pl)
                        | None ->
                            worldState.players
                    let newWorld = { worldState with players = newPlayers }
                    let newClientPlayerMap = clientPlayer.Remove(clientId)

                    return! loop newClientPlayerMap newWorld

                | ReceivedClientData (sendFunc, clientId, pbCSMain) ->
                    do!
                        clientId
                        |> clientPlayer.TryFind
                        |> Option.bind (fun p -> handleClientMessage p pbCSMain)
                        |> Option.map (fun response -> sendFunc response)
                        |> Option.defaultValue (Async.result ())

                    return! loop clientPlayer worldState
                    
            }

        loop Map.empty initWorld
    )


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
