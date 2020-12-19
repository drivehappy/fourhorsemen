module Player

open Microsoft.FSharp.Data.UnitSystems.SI.UnitSymbols
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

    meleeDamage : int
    meleeSwingTimer : float<s>

    debuffs : MonsterMarks
}


let playerResetSwingTimer = 2.0<s>

let initPlayer = {
    name = "Unknown"
    networkClientId = "Unknown"
    class_ = Healer
    direction = 0.0f
    position = { x = 0.0f; y = 0.0f }
    currentHealth = 10000
    maxHealth = 10000

    meleeDamage = 2000
    meleeSwingTimer = 0.0<s>

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
