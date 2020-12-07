module Message exposing (..)

import Json.Encode exposing (Value)



type Msg
    = WebsocketRequestConnect String
    | WebsocketConnected String
    | WebsocketClosed String
    | WebsocketError String
    | WebsocketDataReceived String
