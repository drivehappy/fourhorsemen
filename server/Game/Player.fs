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
    class_ : Class
    direction : float   // Radians
    position : Vec2

    debuffs : MonsterMark list
}

let attackRange (c : Class) =
    match c with
    | Healer -> 0
    | Tank -> 5
    | MeleeDPS -> 5
    | RangedDPS -> 30
