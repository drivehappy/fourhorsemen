module GameUIView exposing (..)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Line exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra as ListE exposing (..)

import GameModel exposing (..)
import Model exposing (..)
import Helpers exposing (..)



uiWidth = 60
uiHeight = 120


-- UI View for the left-hand side
viewLHS : Model -> Html msg
viewLHS m =
    let
        clearScreen =
            shapes
                [ fill Color.white
                ]
                [ rect (0, 0) (uiWidth * viewZoomRatio) (uiHeight * viewZoomRatio)
                ]

    in
    Canvas.toHtml
        (uiWidth * viewZoomRatio, uiHeight * viewZoomRatio)
        [ style "border" "5px solid rgba(0,0,0,0.6)"
        ]
        ( [ clearScreen
          ]
          ++ viewRenderPlayerList m
        )


viewRenderPlayerList : Model -> List Renderable
viewRenderPlayerList m =
    let
        tanks = m.players |> List.filter (\p -> p.type_ == Tank)
        healers = m.players |> List.filter (\p -> p.type_ == Healer)
        melee = m.players |> List.filter (\p -> p.type_ == MeleeDPS)
        ranged = m.players |> List.filter (\p -> p.type_ == RangedDPS)


        headerText : String -> Point -> Renderable
        headerText t p =
            Canvas.text
                [ font { size = 16, family = "sans-serif" }
                , Canvas.Settings.Text.align Left
                ]
                p t

        playerText : String -> Point -> Renderable
        playerText t p =
            Canvas.text
                [ font { size = 12, family = "sans-serif" }
                , Canvas.Settings.Text.align Left
                ]
                p t

        renderPlayers : List Player -> Int -> List Renderable
        renderPlayers players startY =
            let
                l = ListE.initialize (players |> List.length) (\i -> startY + (i * 15))

                pl : List (Player, Int)
                pl = ListE.zip players l

            in
            pl
                |> List.map (\(p, i) ->
                    playerText p.name (15, (toFloat i))
                )
    in
    [ headerText "Tanks" (6, 20) ]
    ++ renderPlayers tanks 40
    ++ [ headerText "Healers" (6, 100) ]
    ++ renderPlayers healers 120
    ++ [ headerText "Melee DPS" (6, 180) ]
    ++ renderPlayers melee 200
    ++ [ headerText "Ranged DPS" (6, 260) ]
    ++ renderPlayers ranged 280
