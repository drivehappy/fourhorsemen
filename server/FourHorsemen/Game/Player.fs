module Player

open Entity


type Class =
    | Healer
    | Tank
    | MeleeDPS
    | RangedDPS

type Player = {
    // TODO: Tie this to a websocket connection

    name : string
    networkClientId : string
    class_ : Class
    direction : float32   // Radians
    position : Vec2

    debuffs : MonsterMark list
}

let initPlayer = {
    name = "Unknown"
    networkClientId = "Unknown"
    class_ = Healer
    direction = 0.0f
    position = { x = 0.0f; y = 0.0f }
    debuffs = []
}

let attackRange (c : Class) =
    match c with
    | Healer -> 0
    | Tank -> 5
    | MeleeDPS -> 5
    | RangedDPS -> 30
