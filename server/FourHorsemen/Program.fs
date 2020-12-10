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

    let gameState = GameState.gameState()
    let networkConns = NetworkMessages.networkConnections gameState

    // Bridge our network connection back to game state to support the game state broadcasting updates to the network
    gameState.Post (GameState.RegisterBroadcast (buildSCWorldState >> NetworkMessages.BroadcastData >> networkConns.Post >> Async.result))

    // Start the game loop
    let loop = GameState.gameLoop gameState
    loop
    |> Async.Start

    // Start the webserver/websocket server
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