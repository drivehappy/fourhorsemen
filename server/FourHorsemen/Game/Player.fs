module Player

open Entity


type Class =
    | Healer
    | Tank
    | MeleeDPS
    | RangedDPS


type Player = {
    name : string
    networkClientId : string
    class_ : Class
    direction : float32   // Radians
    position : Vec2
    currentHealth : int
    maxHealth : int

    debuffs : MonsterMarks
}

let initPlayer = {
    name = "Unknown"
    networkClientId = "Unknown"
    class_ = Healer
    direction = 0.0f
    position = { x = 0.0f; y = 0.0f }
    currentHealth = 10000
    maxHealth = 10000
    debuffs = {
        mograineMark = None
        thaneMark = None
        blaumeuxMark = None
        zeliekMark = None
    }
}

let attackRange (c : Class) =
    match c with
    | Healer -> 0
    | Tank -> 5
    | MeleeDPS -> 5
    | RangedDPS -> 30
