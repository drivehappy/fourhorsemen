module Monster

open Microsoft.FSharp.Data.UnitSystems.SI.UnitSymbols
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
    speed : float<m/s>
    position : Vec2
    maxHealth : int
    curHealth : int

    // Melee damage
    meleeDamage : int
    meleeSwingTimer : float<s>

    // Mark timer
    markTimer : float<s>

    // Shield wall at 50% and 20% states
    shieldWall50Used : bool
    shieldWall20Used : bool

    // Quick is dead state - still send out marks, but doesn't perform other actions
    isSpirit : bool

    // Target and threat list
    target : Ref<Player> option
    threat : (Ref<Player> * int) list
}

// We'll estimate the boss hits the player every 2 seconds
let monsterResetSwingTimer = 2.0<s>

// First mark waits until 20 seconds after start of encounter
let initMarkTimer = 20.0<s>

// After the first mark goes out, each mark is every 12 seconds
let markTimerFreq = 12.0<s>


let initMograine = {
    name = "Mograine"
    type_ = Mograine
    direction = 0.0f
    speed = 15.0<m/s>
    position = { x = 60.0f; y = 67.5f }
    maxHealth = 530000
    curHealth = 530000

    meleeDamage = 1600
    meleeSwingTimer = 0.0<s>

    markTimer = initMarkTimer

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
    speed = 15.0<m/s>
    position = { x = 52.5f; y = 67.5f }
    maxHealth = 590000
    curHealth = 590000
    
    meleeDamage = 1600
    meleeSwingTimer = 0.0<s>

    markTimer = initMarkTimer

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
    speed = 15.0<m/s>
    position = { x = 67.5f; y = 67.5f }
    maxHealth = 230000
    curHealth = 230000
    
    meleeDamage = 1600
    meleeSwingTimer = 0.0<s>

    markTimer = initMarkTimer

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
    speed = 15.0<m/s>
    position = { x = 45.0f; y = 67.5f }
    maxHealth = 290000
    curHealth = 290000
    
    meleeDamage = 1600
    meleeSwingTimer = 0.0<s>

    markTimer = initMarkTimer

    shieldWall50Used = false
    shieldWall20Used = false

    isSpirit = false
    
    target = None
    threat = []
}
