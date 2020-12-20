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
    , currentHealth : Int
    , maxHealth : Int
    , guid : String
    }

type alias EncounterBosses =
    { mograine : Boss
    , thane : Boss
    , zeliek : Boss
    , blaumeux : Boss
    }

type alias DebuffMark = (Float, Int)

type alias PlayerDebuffs =
    { mograineDebuff : DebuffMark
    , thaneDebuff : DebuffMark
    , zeliekDebuff : DebuffMark
    , blaumeuxDebuff : DebuffMark
    }

type alias Player =
    { position : Vec2
    , direction : Float   -- Radians
    , type_ : PlayerType
    , name : String
    , currentHealth : Int
    , maxHealth : Int
    , guid : String
    , targetGuid : Maybe String
    , debuffs : PlayerDebuffs
    }

type alias EntityTarget a =
    { a | name : String, currentHealth : Int, maxHealth : Int }

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
initPlayerDebuffs : PlayerDebuffs
initPlayerDebuffs = 
    { mograineDebuff = (0.0, 0)
    , thaneDebuff = (0.0, 0)
    , zeliekDebuff = (0.0, 0)
    , blaumeuxDebuff = (0.0, 0)
    }


--
initPlayer : Player
initPlayer =
    { position = { x = 0.5, y = 0.9 }
    , direction = 0
    , type_ = Tank
    , name = "PlayerName"
    , currentHealth = 0
    , maxHealth = 0
    , guid = "TODO_GUID"
    , targetGuid = Nothing
    , debuffs = initPlayerDebuffs
    }


-- Until we get the server hooked up to send us this, hardcode it
initBossEncounters : EncounterBosses
initBossEncounters =
    { mograine =
        { position = { x = 0.5, y = 0.5 }
        , direction = 0.0
        , name = "Mograine"
        , currentHealth = 0
        , maxHealth = 0
        , guid = "TODO_GUID"
        }
    , thane =
        { position = { x = 0.45, y = 0.5 }
        , direction = 0.0
        , name = "Thane"
        , currentHealth = 0
        , maxHealth = 0
        , guid = "TODO_GUID"
        }
    , zeliek =
        { position = { x = 0.40, y = 0.5 }
        , direction = 0.0
        , name = "Zeliek"
        , currentHealth = 0
        , maxHealth = 0
        , guid = "TODO_GUID"
        }
    , blaumeux =
        { position = { x = 0.55, y = 0.5 }
        , direction = 0.0
        , name = "Blaumeux"
        , currentHealth = 0
        , maxHealth = 0
        , guid = "TODO_GUID"
        }
    }
