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


let runWebSocket (webSocket : WebSocket) (context : HttpContext) =
    socket {
        let mutable loop = true

        // We wait for the client to send us a message after connecting
        while (loop) do
            let! msg = webSocket.read()

            match msg with
            | (Text, data, true) ->
                printfn "Received text data from client: %A" data

                // Build protobuf
                let root = new SC_Main()
                root.Type <- SC_Main.Types.Type.GameStepUpdate

                let str = UTF8.toString data
                let response =
                    root.ToByteArray()
                    |> ByteSegment

                (*
                let byteResponse =
                    response
                    |> System.Text.Encoding.ASCII.GetBytes
                    |> ByteSegment
                *)
                do! webSocket.send Text response true

            | (Binary, data, true) ->
                (*
                let pbCSMain = CS_Main.Parser.ParseFrom(data)

                match pbCSMain.Request with
                | CS_Main.Types.Request.Search ->
                    let q = pbCSMain.Search.SearchQuery
                    let pbSCMain = searchQuery q

                    let byteResponse =
                        (pbSCMain.ToByteArray())
                        |> ByteSegment

                    printfn "Sending data size: %i" byteResponse.Count
                    do! webSocket.send Binary byteResponse true

                | CS_Main.Types.Request.Item ->
                    let itemId = nullableToOption pbCSMain.RequestId
                    match itemId with
                    | Some id ->
                        let pbSCMain = itemRequest id

                        let byteResponse =
                            (pbSCMain.ToByteArray())
                            |> ByteSegment

                        printfn "Sending data size: %i" byteResponse.Count
                        do! webSocket.send Binary byteResponse true

                    | None ->
                        // TODO: Send back an error to the client?
                        ()

                | CS_Main.Types.Request.Npc ->
                    let npcId = nullableToOption pbCSMain.RequestId
                    match npcId with
                    | Some id ->
                        let pbSCMain = npcRequest id

                        let byteResponse =
                            (pbSCMain.ToByteArray())
                            |> ByteSegment

                        printfn "Sending data size: %i" byteResponse.Count
                        do! webSocket.send Binary byteResponse true

                    | None ->
                        // TODO: Send back an error to the client?
                        ()


                | _ ->
                    printfn "Received unknown request from client: %A" pbCSMain.Request
                *)

                printfn "Received binary data from client: %A" data

            | (Close, _, _) ->
                printfn "Client closed"
                let emptyResponse = [||] |> ByteSegment
                do! webSocket.send Close emptyResponse true
                loop <- false

            | (u, _, _) ->
                printfn "Received unknown data type from client: %A" u
        
    }

[<EntryPoint>]
let main argv = 

    let app : WebPart =
        choose [
            GET >=> choose [
                path "/websocket" >=> handShake runWebSocket
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