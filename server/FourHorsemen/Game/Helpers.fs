module Helpers

open Entity
open Codegen


let vec2ToPB (v : Entity.Vec2) : Proto.Vec2 =
    Proto.Vec2(PositionX = v.x, PositionY = v.y)

//
let pbToVec2 (v : Proto.Vec2) : Entity.Vec2 =
    { x = v.PositionX; y = v.PositionY }

// This is the more common one, as we expect to receive normalized data points from the client currently (0,1)
let denormPBtoVec2 (d : Dimensions) (v : Proto.Vec2) : Entity.Vec2 =
    { x = v.PositionX * d.width; y = v.PositionY * d.height }

// Convert our absolute position into a normalized position
let normalizePos (d : Dimensions) (p : Entity.Vec2) : Entity.Vec2 =
    { x = p.x / d.width; y = p.y / d.height }

// Convert normalized position into absolute
let denormalizePos (d : Dimensions) (p : Entity.Vec2) : Entity.Vec2 =
    { x = p.x * d.width; y = p.y * d.height }
