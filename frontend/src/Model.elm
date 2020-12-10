module Model exposing (..)


import PortFunnels exposing (State)


type alias Model =
    { isConnected : Bool
    , playerName : String
    }


initModel =
    { isConnected = False
    , playerName = ""
    }