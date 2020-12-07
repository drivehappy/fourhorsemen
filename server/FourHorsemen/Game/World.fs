module World

open Monster
open Player


type World = {
    bosses : Monster[]
    players : Player list

    worldWidth : float32
    worldHeight : float32
}

let initWorld = {
    bosses = [||]
    players = []

    // Estimates
    worldWidth = 200.0f
    worldHeight = 200.0f
}


// Helper actions
let playerMove (p : Player) =
    ()

let playerAttackTarget (p : Player, t : Monster) =
    ()
