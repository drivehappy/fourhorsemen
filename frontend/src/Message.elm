module Message exposing (..)

import Json.Encode exposing (Value)


type WebsocketMsg
    = UpdateSend String
    | UpdateUrl String
    | ToggleUseSimulator
    | ToggleAutoReopen
    | Connect
    | Close
    | Send
    | Process Value


type Msg
    --= Websocket WebsocketMsg
    = NewWebsocketConnect
    | NewWebsocketConnected String
    | WebsocketDataReceived String
