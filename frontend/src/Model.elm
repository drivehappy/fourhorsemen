module Model exposing (..)


import PortFunnels exposing (State)


type alias WebsocketModel =
    { send : String
    , log : List String
    , url : String
    , useSimulator : Bool
    , wasLoaded : Bool
    , state : State
    , key : String
    , error : Maybe String
    }


type alias Model =
    { websocketModel : WebsocketModel
    , isConnected : Bool
    }



defaultUrl : String
defaultUrl =
    "ws://localhost:8081/websocket"

initWebsocketModel =
    { send = "Hello World!"
    , log = []
    , url = defaultUrl
    , useSimulator = True
    , wasLoaded = False
    , state = PortFunnels.initialState
    , key = "socket"
    , error = Nothing
    }
