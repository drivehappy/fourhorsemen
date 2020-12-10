module GameModel exposing (..)


type alias Vec2 =
    { x : Float
    , y : Float
    }


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
