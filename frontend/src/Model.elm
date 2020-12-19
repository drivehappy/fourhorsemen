module Model exposing (..)

import Dict exposing (..)

import PortFunnels exposing (State)
import GameModel exposing (..)


type alias Model =
    { isConnected : Bool
    , serverCode : String
    , playerName : String
    , bosses : EncounterBosses
    , players : Dict String Player
    , currentPlayerGuid : String
    , keyState : KeyState
    }


initModel : Model
initModel =
    { isConnected = False
    , serverCode = ""
    , playerName = "Unknown"
    , bosses = initBossEncounters
    , players = Dict.empty
    , currentPlayerGuid = ""
    , keyState = initKeyState
    }
