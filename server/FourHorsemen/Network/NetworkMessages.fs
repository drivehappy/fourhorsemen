module NetworkMessages

open Codegen.Proto
open System.Security.Cryptography
open System.Text
open Suave.WebSocket
open Suave.Sockets
open GameState
open Player
open Google.Protobuf


//
let buildClientId (ip : string) (port : string) (salt : byte[]) =
    use hash = SHA256.Create()

    (System.Convert.ToBase64String(salt)) + ":" + ip + ":" + port
    |> Encoding.ASCII.GetBytes
    |> hash.ComputeHash
    |> System.Convert.ToBase64String
    

//
type NetworkConnMsg =
    | AddConnection of (WebSocket * string)
    | RemoveConnection of (WebSocket * string)
    | ReceivedData of (WebSocket * string * CS_Main)
    | BroadcastData of ByteSegment


let networkConnections (networkWorldState : MailboxProcessor<GameMsg>) =
    MailboxProcessor<NetworkConnMsg>.Start(fun inbox ->
        let rec loop (conns : (WebSocket * string) list) =
            async {
                let! msg = inbox.Receive()
                match msg with
                | AddConnection (ws, clientId) ->
                    let newPlayer = { initPlayer with networkClientId = clientId }
                    networkWorldState.Post(AddPlayer (clientId, newPlayer))
                    return! loop ((ws, clientId) :: conns)

                | RemoveConnection (ws, clientId) ->
                    networkWorldState.Post(RemovePlayer clientId)
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


                    networkWorldState.Post(ReceivedClientData (sendFunc, clientId, pbCSMain))
                    return! loop conns

                | BroadcastData data ->
                    for (w, _) in conns do
                        let! _ = w.send Binary data true
                        ()

                    return! loop conns
            }

        loop []
    )
