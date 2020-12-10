open System
open Suave
open Suave.Filters
open Suave.Operators
open Suave.Successful
open Suave.WebSocket
open Suave.Sockets
open Suave.Sockets.Control
open Suave.Sockets.Control.SocketMonad
open System.Net
open System.IO
open Google.Protobuf

open Codegen.Proto
open NetworkMessages
open System.Security.Cryptography


// To throw in some more randomness into the hash since it's constructed of IP:Port
let generateSalt () =
    let salt : byte[] = Array.zeroCreate(256)
    use random = new RNGCryptoServiceProvider()
    random.GetNonZeroBytes(salt)
    salt


//
let runWebSocket (networkConns : MailboxProcessor<NetworkConnMsg>) (webSocket : WebSocket) (context : HttpContext) =
    socket {
        let clientSalt = generateSalt ()
        let clientId = buildClientId (context.connection.ipAddr.ToString()) (context.connection.port.ToString()) clientSalt
        let mutable loop = true

        // Add this new connection to our state of all of the connections we currently maintain
        networkConns.Post (AddConnection (webSocket, clientId))

        // We wait for the client to send us a message after connecting
        while (loop) do
            let! msg = webSocket.read()

            match msg with
            | (Binary, data, true) ->
                let csMain =
                    try
                        data
                        |> CS_Main.Parser.ParseFrom
                        |> Some
                    with
                    | e ->
                        None

                printfn "Received data: %A" csMain

                match csMain with
                | Some pbCSMain ->
                    networkConns.Post (ReceivedData (webSocket, clientId, pbCSMain))

                | None ->
                    ()

                (*
                let sendData =
                    csMain
                    |> Option.bind (handleClientMessage clientId)
                    |> Option.map (fun r ->
                        let response =
                            r.ToByteArray()
                            |> ByteSegment

                        response
                    )

                match sendData with
                | Some d ->
                    do! webSocket.send Binary d true

                | None ->
                    ()
                *)

            | (Close, _, _) ->
                printfn "Client closed"
                networkConns.Post (RemoveConnection (webSocket, clientId))
                let emptyResponse = [||] |> ByteSegment
                do! webSocket.send Close emptyResponse true
                loop <- false

            | (u, _, _) ->
                printfn "Received unknown data type from client: %A" u
        
    }

[<EntryPoint>]
let main argv = 

    let networkWorldState = GameState.networkWorldState()
    let networkConns = NetworkMessages.networkConnections networkWorldState

    //
    let app : WebPart =
        choose [
            GET >=> choose [
                path "/websocket" >=> handShake (runWebSocket networkConns)
                path "/" >=> Files.file "static/index.html"
                Files.browseHome
                RequestErrors.NOT_FOUND "Page not found."
            ]
        ]

    let port = 8081us
    let local = Suave.Http.HttpBinding.create HTTP IPAddress.Any port
    let config = { defaultConfig with bindings = [local]; homeFolder = Some (Path.GetFullPath "./static") }

    startWebServer config app
    0