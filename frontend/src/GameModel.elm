module GameModel exposing (..)


type alias Vec2 =
    { x : Float
    , y : Float
    }

type PlayerType
    = Tank
    | Healer
    | MeleeDPS
    | RangedDPS


type alias Boss =
    { position : Vec2
    , direction : Float   -- Radians
    , name : String
    }

type alias EncounterBosses =
    { mograine : Boss
    , thane : Boss
    , zeliek : Boss
    , blaumeux : Boss
    }

type alias Player =
    { position : Vec2
    , direction : Float   -- Radians
    , type_ : PlayerType
    , name : String
    , guid : String
    }

-- We have to track whether each key is pressed and released
type alias KeyState =
    { left : Bool
    , right : Bool
    , up : Bool
    , down : Bool
    , useAbility1 : Bool
    , useAbility2 : Bool
    }


--
initKeyState : KeyState
initKeyState =
    { left = False
    , right = False
    , up = False
    , down = False
    , useAbility1 = False
    , useAbility2 = False
    }


--
initPlayer : Player
initPlayer =
    { position = { x = 0.5, y = 0.9 }
    , direction = 0
    , type_ = Tank
    , name = "PlayerName"
    , guid = "TODO_GUID"
    }


-- Until we get the server hooked up to send us this, hardcode it
initBossEncounters : EncounterBosses
initBossEncounters =
    { mograine =
        { position = { x = 0.5, y = 0.5 }
        , direction = 0.0
        , name = "Mograine"
        }
    , thane =
        { position = { x = 0.45, y = 0.5 }
        , direction = 0.0
        , name = "Thane"
        }
    , zeliek =
        { position = { x = 0.40, y = 0.5 }
        , direction = 0.0
        , name = "Zeliek"
        }
    , blaumeux =
        { position = { x = 0.55, y = 0.5 }
        , direction = 0.0
        , name = "Blaumeux"
        }
    }
