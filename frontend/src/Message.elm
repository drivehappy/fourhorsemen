module Message exposing (..)

import Json.Encode exposing (Value)



type Msg
    = WebsocketConnect String
    | WebsocketConnected String
    | WebsocketClosed String
    | WebsocketError String
    | WebsocketDataReceived String
    
