module GameState

open World




let gameTick (world : World) =
    // Run boss actions
    world.bosses
    |> Array.iter (fun b ->
        let healthPercent = (float32 b.curHealth) / (float32 b.maxHealth)

        if healthPercent < 0.50f && not b.shieldWall50Used then
            // TODO: Use ShieldWall 50%
            ()
        if healthPercent < 0.20f && not b.shieldWall20Used then
            // TODO: Use ShieldWall 20%
            ()
    )
