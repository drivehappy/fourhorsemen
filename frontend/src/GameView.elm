module GameView exposing (..)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Line exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Html exposing (..)
import Html.Attributes exposing (..)

import GameModel exposing (..)
import Model exposing (..)
import Helpers exposing (..)



-- View
zoomSetting : Setting
zoomSetting = transform [ Scale viewZoomRatio viewZoomRatio ]


view : Model -> Html msg
view m =
    let
        clearScreen =
            shapes
                [ fill Color.white
                , zoomSetting
                ]
                [ rect (0, 0) (roomWidth * viewZoomRatio) (roomHeight * viewZoomRatio)
                ]
    in
    Canvas.toHtml
        (roomWidth * viewZoomRatio, roomHeight * viewZoomRatio)
        [ style "border" "10px solid rgba(0,0,0,0.6)"
        ]
        ( [ clearScreen
          ]
          ++ viewRenderPlatform
          ++ (viewRenderBosses m.bosses)
          ++ (viewCurrentPlayer m.currentPlayer)
        )


viewRenderPlatform : List Renderable
viewRenderPlatform =
    let
        pillars =
            shapes
                [ fill (Color.rgba 0 0 0 0.75)
                ]
                [ rect (denormalizePoint 0.3 0.3) (denormalizeX 0.05) (denormalizeY 0.05)
                , rect (denormalizePoint 0.6 0.3) (denormalizeX 0.05) (denormalizeY 0.05)
                , rect (denormalizePoint 0.3 0.6) (denormalizeX 0.05) (denormalizeY 0.05)
                , rect (denormalizePoint 0.6 0.6) (denormalizeX 0.05) (denormalizeY 0.05)
                ]

        stairs =
            shapes
                [ fill (Color.rgba 0 0 0 0.25)
                ]
                [ rect (denormalizePoint 0.325 0.325) (denormalizeX 0.3) (denormalizeY 0.025)
                , rect (denormalizePoint 0.325 0.325) (denormalizeX 0.025) (denormalizeY 0.3)
                , rect (denormalizePoint 0.6 0.325) (denormalizeX 0.025) (denormalizeY 0.3)
                , rect (denormalizePoint 0.325 0.6) (denormalizeX 0.3) (denormalizeY 0.025)
                ]
    in
        [ pillars
        , stairs
        ]



renderTextAboveCharacter : Vec2 -> String -> Renderable
renderTextAboveCharacter charPos text =
    Canvas.text
        [ font { size = 12, family = "sans-serif" }
        , Canvas.Settings.Text.align Center
        ]
        (denormalizeVec2 { x = charPos.x, y = charPos.y - 0.01 } )
        text


viewCircleRadius = (2.25 * viewZoomRatio)
aggroCircleRadius = (65 * viewZoomRatio)


-- This function corrects the circle rendering from the bottom of the circle to the center
renderCirclePosition : Vec2 -> Point
renderCirclePosition v =
    let
        (newX, newY) = denormalizeVec2 v
    in
    (newX, newY + viewCircleRadius)



viewRenderBosses : EncounterBosses -> List Renderable
viewRenderBosses bosses =
    let
        renderBossIndicator : Boss -> Color.Color -> Renderable
        renderBossIndicator b c =
            shapes
                [ fill c
                , stroke Color.black
                , lineWidth 3.0
                , lineJoin BevelJoin
                , lineDash [ 4, 2 ]
                ]
                [ circle (renderCirclePosition b.position) viewCircleRadius
                ]

        renderBossNameplate : Boss -> Renderable
        renderBossNameplate b =
            renderTextAboveCharacter b.position b.name


        -- For debugging, maybe more, render the aggro radius
        renderBossAggroRange : Boss -> Renderable
        renderBossAggroRange b =
            shapes
                [ stroke Color.grey
                , lineWidth 1.0
                , lineJoin BevelJoin
                , lineDash [ 4, 2 ]
                ]
                [ circle (renderCirclePosition b.position) aggroCircleRadius
                ]

    in
    [ renderBossIndicator bosses.mograine (Color.rgba 1 0 0 1)
    , renderBossIndicator bosses.thane (Color.rgba 1 0.6 0 1)
    , renderBossIndicator bosses.zeliek (Color.rgba 0 0 1 1)
    , renderBossIndicator bosses.blaumeux (Color.rgba 0.3 0.7 0.3 1)

    , renderBossNameplate bosses.mograine
    , renderBossNameplate bosses.thane
    , renderBossNameplate bosses.zeliek
    , renderBossNameplate bosses.blaumeux

    , renderBossAggroRange bosses.mograine
    , renderBossAggroRange bosses.thane
    , renderBossAggroRange bosses.zeliek
    , renderBossAggroRange bosses.blaumeux
    ]


viewCurrentPlayer : Player -> List Renderable
viewCurrentPlayer p =
    let
        renderPlayerIndicator : Player -> Color.Color -> Renderable
        renderPlayerIndicator player c =
            shapes
                [ fill c
                ]
                [ circle (renderCirclePosition player.position) viewCircleRadius
                ]

        renderPlayerNameplate : Player -> Renderable
        renderPlayerNameplate player =
            renderTextAboveCharacter player.position player.name
    in
    [ renderPlayerIndicator p (Color.rgba 0.5 0.5 0.5 1)
    , renderPlayerNameplate p
    ]


viewRaidTable =
    table [ style "border" "1px" ]
        [ tr []
            [ th [] [ Html.text "Tanks" ]
            , th [] [ Html.text "Healers" ]
            , th [] [ Html.text "Melee DPS" ]
            , th [] [ Html.text "Ranged DPS" ]
            ]
        , tr []
            [ Html.text "Deceit"
            ]
        ]
