module Helpers exposing (..)

import Html exposing (Html, text)

import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)


viewZoomRatio = 6

roomWidth = 120
roomHeight = 120

-- Converts (0-1) dimension into (0-roomWidth (or roomHeight))
denormalizeX x = roomWidth * x * viewZoomRatio
denormalizeY y = roomWidth * y * viewZoomRatio
denormalizePoint x y = (denormalizeX x, denormalizeY y)
denormalizeVec2 v = denormalizePoint v.x (v.y - 0.02)


-- Converts room dimensions into (0-1)
normalizeX x = x / (roomWidth * viewZoomRatio)
normalizeY y = y / (roomWidth * viewZoomRatio)
normalizeRadius r = r / (roomWidth * viewZoomRatio)   -- Assume for now the room is square


--
htmlNone : Html msg
htmlNone = text ""


--
zoomSetting : Setting
zoomSetting = transform [ Scale viewZoomRatio viewZoomRatio ]