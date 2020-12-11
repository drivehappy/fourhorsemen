module Message exposing (..)

import Json.Encode exposing (Value)


type KeyDirection
    = Left
    | Right
    | Up
    | Down
    | Unknown String


type Msg
    = WebsocketRequestConnect String
    | WebsocketConnected String
    | WebsocketClosed String
    | WebsocketError String
    | WebsocketDataReceived String

    | CanvasClick (Int, Int)
    | KeyDown KeyDirection
    | KeyUp KeyDirection

    | UpdateServerCode String
    | UpdatePlayerName String
