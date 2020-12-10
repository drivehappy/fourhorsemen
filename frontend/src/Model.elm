module Model exposing (..)


import PortFunnels exposing (State)
import GameModel exposing (..)


type alias Model =
    { isConnected : Bool
    , playerName : String
    , bosses : EncounterBosses
    }


initModel : Model
initModel =
    { isConnected = False
    , playerName = ""
    , bosses = initBossEncounters
    }
