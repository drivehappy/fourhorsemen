module Model exposing (..)


import PortFunnels exposing (State)
import GameModel exposing (..)


type alias Model =
    { isConnected : Bool
    , serverCode : String
    , playerName : String
    , bosses : EncounterBosses
    , players : List Player
    , currentPlayer : Player
    , keyState : KeyState
    }


initModel : Model
initModel =
    { isConnected = False
    , serverCode = ""
    , playerName = "Unknown"
    , bosses = initBossEncounters
    , players = []
    , currentPlayer = initPlayer
    , keyState = initKeyState
    }
