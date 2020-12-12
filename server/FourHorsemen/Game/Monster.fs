module Monster

open Entity
open Player
open System


type MonsterType =
    | Mograine
    | Thane
    | Blaumeux
    | Zeliek

type Monster = {
    name : string
    type_ : MonsterType
    direction : float32   // Radians
    speed : float       //
    position : Vec2
    maxHealth : int
    curHealth : int

    // Shield wall at 50% and 20% states
    shieldWall50Used : bool
    shieldWall20Used : bool

    // Quick is dead state - still send out marks, but doesn't perform other actions
    isSpirit : bool

    // Target and threat list
    target : Ref<Player> option
    threat : (Ref<Player> * int) list
}

let markRange = 65.0f   // 65-70 yards?'
let initMarkTimer = 75.0<milli second>


let initMograine = {
    name = "Mograine"
    type_ = Mograine
    direction = 0.0f
    speed = 15.0
    position = { x = 60.0f; y = 67.5f }
    maxHealth = 530000
    curHealth = 530000

    shieldWall50Used = false
    shieldWall20Used = false

    isSpirit = false

    target = None
    threat = []
}

let initThane = {
    name = "Thane"
    type_ = Thane
    direction = 0.0f
    speed = 15.0
    position = { x = 52.5f; y = 67.5f }
    maxHealth = 590000
    curHealth = 590000

    shieldWall50Used = false
    shieldWall20Used = false

    isSpirit = false
    
    target = None
    threat = []
}

let initZeliek = {
    name = "Zeliek"
    type_ = Zeliek
    direction = 0.0f
    speed = 15.0
    position = { x = 67.5f; y = 67.5f }
    maxHealth = 230000
    curHealth = 230000

    shieldWall50Used = false
    shieldWall20Used = false

    isSpirit = false
    
    target = None
    threat = []
}

let initBlaumeux = {
    name = "Blaumeux"
    type_ = Blaumeux
    direction = 0.0f
    speed = 15.0
    position = { x = 45.0f; y = 67.5f }
    maxHealth = 290000
    curHealth = 290000

    shieldWall50Used = false
    shieldWall20Used = false

    isSpirit = false
    
    target = None
    threat = []
}
