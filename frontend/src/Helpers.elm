module Helpers exposing (..)



roomWidth = 800
roomHeight = 800

-- Converts (0-1) dimension into (0-roomWidth (or roomHeight))
denormalizeX x = roomWidth * x
denormalizeY y = roomWidth * y
denormalizePoint x y = (denormalizeX x, denormalizeY y)
denormalizeVec2 v = denormalizePoint v.x (v.y - 0.02)


-- Converts room dimensions into (0-1)
normalizeX x = x / roomWidth
normalizeY y = y / roomWidth
normalizeRadius r = r / roomWidth   -- Assume for now the room is square