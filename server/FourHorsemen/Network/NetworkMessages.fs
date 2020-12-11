module NetworkMessages

open Codegen
open Codegen.Proto
open System.Security.Cryptography
open System.Text
open Suave.WebSocket
open Suave.Sockets
open Player
open Monster
open World
open Google.Protobuf
open GameState


// Main handler for incoming network messages from the client
let handleClientMessage (clientId : NetworkClientId) (gameState : MailboxProcessor<GameStateMsg>) (pbCSMain : CS_Main) =
    match pbCSMain.Type with
    | CS_Main.Types.Type.PlayerJoin ->
        let pj = if (isNull pbCSMain.PlayerJoin) then None else Some pbCSMain.PlayerJoin

        let newPlayerState =
            pj
            |> Option.iter (fun playerJoin ->
                gameState.Post (RunPlayerAction (PlayerSetName (clientId, playerJoin.PlayerName)))
            )
        ()

    | CS_Main.Types.Type.PlayerMove ->
        printfn "Received player move: %A" pbCSMain.PlayerMove
        ()

    | CS_Main.Types.Type.RequestGameStart ->
        // TODO: Check permissions
        printfn "Request game start"
        ()

    | CS_Main.Types.Type.RequestGameReset ->
        // TODO: Check permissions
        printfn "Request game reset"
        ()

    | _ ->
        // Unhandled
        ()


// Convert our absolute position into a normalized position
let normalizePos (world : World) (p : Entity.Vec2) : Entity.Vec2 =
    { x = p.x / world.worldWidth; y = p.y / world.worldHeight }


// Build a server -> client message from the provided world state,
// this will just send everything.
let buildSCWorldState (world : World) : ByteSegment =
    let pbSCMain = SC_Main()
    pbSCMain.Type <- SC_Main.Types.Type.GameStepUpdate

    // Helpers
    let vec2ToPB (v : Entity.Vec2) : Proto.Vec2 =
        Proto.Vec2(PositionX = v.x, PositionY = v.y)

    let normalizeVec2ToPB (v : Entity.Vec2) : Proto.Vec2 =
        normalizePos world v
        |> vec2ToPB

    // Build player message
    world.players
    |> List.iter (fun p ->
        let convertPlayerToProto (p : Player.Player) : Proto.Player =
            let pb = Proto.Player()
            pb.Guid <- p.networkClientId
            pb.Position <- normalizeVec2ToPB p.position
            pb.Direction <- p.direction
            pb

        pbSCMain.BulkPlayerUpdate.Add(convertPlayerToProto p)
    )

    // Build boss message
    world.bosses
    |> Array.iter (fun b ->
        let convertMonsterToProto (m : Monster) : Proto.Boss =
            let pb = Proto.Boss()
            pb.Type <-
                match m.type_ with
                | Mograine -> Proto.Boss.Types.Type.Mograine
                | Thane -> Proto.Boss.Types.Type.Thane
                | Zeliek -> Proto.Boss.Types.Type.Zeliek
                | Blaumeux -> Proto.Boss.Types.Type.Blaumeux
            pb.Position <- normalizeVec2ToPB m.position
            pb.Direction <- m.direction
            pb.Name <- m.name
            pb

        pbSCMain.BulkBossUpdate.Add(convertMonsterToProto b)
    )

    pbSCMain.ToByteArray()
    |> ByteSegment


//
let buildClientId (ip : string) (port : string) (salt : byte[]) =
    use hash = SHA256.Create()

    (System.Convert.ToBase64String(salt)) + ":" + ip + ":" + port
    |> Encoding.ASCII.GetBytes
    |> hash.ComputeHash
    |> System.Convert.ToBase64String
    

//
type NetworkConnMsg =
    | AddConnection of (WebSocket * NetworkClientId)
    | RemoveConnection of (WebSocket * NetworkClientId)
    | ReceivedData of (WebSocket * NetworkClientId * CS_Main)
    | BroadcastData of ByteSegment


let networkConnections (gameState : MailboxProcessor<GameStateMsg>) =
    MailboxProcessor<NetworkConnMsg>.Start(fun inbox ->
        let rec loop (conns : (WebSocket * string) list) =
            async {
                let! msg = inbox.Receive()
                match msg with
                | AddConnection (ws, clientId) ->
                    let newPlayer = { initPlayer with networkClientId = clientId }
                    //networkWorldState.Post(AddPlayer (clientId, newPlayer))
                    gameState.Post (GameState.AddPlayer newPlayer)
                    return! loop ((ws, clientId) :: conns)

                | RemoveConnection (ws, clientId) ->
                    //networkWorldState.Post(RemovePlayer clientId)
                    gameState.Post (GameState.RemovePlayer clientId)
                    let newConnsList =
                        conns
                        |> List.filter (fun (w, _) -> w <> ws)

                    return! loop newConnsList

                | ReceivedData (ws, clientId, pbCSMain) ->
                    let sendFunc (data : SC_Main) =
                        let d =
                            data.ToByteArray()
                            |> ByteSegment

                        ws.send Binary d true
                        |> Async.map (fun f -> ())  // TODO: This currently ignores any errors


                    //networkWorldState.Post(ReceivedClientData (sendFunc, clientId, pbCSMain))
                    handleClientMessage clientId gameState pbCSMain

                    return! loop conns

                | BroadcastData data ->
                    printfn "Sending %i bytes to %i connections" data.Count conns.Length

                    for (w, _) in conns do
                        let! _ = w.send Binary data true
                        ()

                    return! loop conns
            }

        loop []
    )
