module World

open Monster
open Player
open Entity


type World = {
    bosses : Monster[]
    players : Ref<Player> list

    dimensions : Dimensions
}

let initWorld = {
    bosses = [| initMograine; initThane; initZeliek; initBlaumeux |]
    players = []

    // Estimates
    dimensions = { width = 120.0f; height = 120.0f }
}


// Helper actions
let playerMove (p : Player) =
    ()

let playerAttackTarget (p : Player, t : Monster) =
    ()
