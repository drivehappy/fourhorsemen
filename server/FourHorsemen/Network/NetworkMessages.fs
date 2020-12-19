module NetworkMessages

open Microsoft.FSharp.Data.UnitSystems.SI.UnitSymbols
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
open Entity
open Helpers


//
let normalizeVec2ToPB (d : Dimensions) (v : Entity.Vec2) : Proto.Vec2 =
    normalizePos d v
    |> vec2ToPB


// Main handler for incoming network messages from the client
let handleClientMessage (sendFunc : SC_Main -> Async<unit>) (clientId : NetworkClientId) (gameState : MailboxProcessor<GameStateMsg>) (pbCSMain : CS_Main) =
    match pbCSMain.Type with
    | CS_Main.Types.Type.PlayerJoin ->
        let pj = if (isNull pbCSMain.PlayerJoin) then None else Some pbCSMain.PlayerJoin
        pj
        |> Option.iter (fun playerJoin ->
            gameState.Post (RunPlayerAction (PlayerSetName (clientId, playerJoin.PlayerName)))
        )

        // Send back the assigned client ID to the client
        let pbSCMain = new SC_Main()
        pbSCMain.Type <- SC_Main.Types.Type.AssignPlayerId
        pbSCMain.AssignedPlayerId <- clientId

        pbSCMain
        |> sendFunc
        |> Async.Start

        ()

    | CS_Main.Types.Type.PlayerMove ->
        gameState.Post (RunPlayerAction (PlayerMove (clientId, pbCSMain.PlayerMove)))
        //printfn "Received player move: %A" pbCSMain.PlayerMove
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


// Build a server -> client message from the provided world state,
// this will just send everything.
let buildSCWorldState (world : World) : ByteSegment =
    let pbSCMain = SC_Main()
    pbSCMain.Type <- SC_Main.Types.Type.GameStepUpdate

    // Build player message
    world.players
    |> List.iter (fun p ->
        let buildSCPlayer (p : Player.Player) : Proto.Player =
            let pb = Proto.Player()
            pb.Guid <- p.networkClientId
            pb.Position <- normalizeVec2ToPB world.dimensions p.position
            pb.Direction <- p.direction
            pb.Name <- p.name
            pb.CurrentHealth <- p.currentHealth
            pb.MaxHealth <- p.maxHealth

            let debuffs = Debuffs()
            p.debuffs.mograineMark
            |> Option.iter (fun m ->
                debuffs.MarkMograine <- Debuff()
                debuffs.MarkMograine.RemainingMs <- int ((fst m) / 1.0<milli s>)
                debuffs.MarkMograine.StackCount <- (snd m)
            )
            p.debuffs.thaneMark
            |> Option.iter (fun m ->
                debuffs.MarkThane <- Debuff()
                debuffs.MarkThane.RemainingMs <- int ((fst m) / 1.0<milli s>)
                debuffs.MarkThane.StackCount <- (snd m)
            )
            p.debuffs.zeliekMark
            |> Option.iter (fun m ->
                debuffs.MarkZeliek <- Debuff()
                debuffs.MarkZeliek.RemainingMs <- int ((fst m) / 1.0<milli s>)
                debuffs.MarkZeliek.StackCount <- (snd m)
            )
            p.debuffs.blaumeuxMark
            |> Option.iter (fun m ->
                debuffs.MarkBlaumeux <- Debuff()
                debuffs.MarkBlaumeux.RemainingMs <- int ((fst m) / 1.0<milli s>)
                debuffs.MarkBlaumeux.StackCount <- (snd m)
            )
            pb.Debuffs <- debuffs

            pb

        pbSCMain.BulkPlayerUpdate.Add(buildSCPlayer !p)
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
            pb.Position <- normalizeVec2ToPB world.dimensions m.position
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
                        |> Async.map (fun f ->
                            match f with
                            | Choice1Of2 () -> ()
                            | Choice2Of2 e ->
                                printfn "Error: %A" e
                        )


                    //networkWorldState.Post(ReceivedClientData (sendFunc, clientId, pbCSMain))
                    handleClientMessage sendFunc clientId gameState pbCSMain

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
