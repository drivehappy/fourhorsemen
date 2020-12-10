module GameView exposing (..)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Html exposing (..)
import Html.Attributes exposing (..)

import GameModel exposing (..)


-- View


roomWidth = 800
roomHeight = 800

-- Converts (0-1) dimension into (0-roomWidth (or roomHeight))
denormalizeX x = roomWidth * x
denormalizeY y = roomWidth * y
denormalizePoint x y = (denormalizeX x, denormalizeY y)
denormalizeVec2 v = denormalizePoint v.x (v.y - 0.02)



view : EncounterBosses -> Html msg
view bosses =
    let
        clearScreen =
            shapes [ fill Color.white ] [ rect (0, 0) roomWidth roomHeight ]
    in
    Canvas.toHtml
        (roomWidth, roomHeight)
        [ style "border" "10px solid rgba(0,0,0,0.6)"
        ]
        ( [ clearScreen
          ]
          ++ viewRenderPlatform
          ++ (viewRenderBosses bosses)
        )


viewRenderPlatform : List Renderable
viewRenderPlatform =
    let
        pillars =
            shapes [ fill (Color.rgba 0 0 0 0.75) ]
                [ rect (denormalizePoint 0.3 0.3) (denormalizeX 0.05) (denormalizeY 0.05)
                , rect (denormalizePoint 0.6 0.3) (denormalizeX 0.05) (denormalizeY 0.05)
                , rect (denormalizePoint 0.3 0.6) (denormalizeX 0.05) (denormalizeY 0.05)
                , rect (denormalizePoint 0.6 0.6) (denormalizeX 0.05) (denormalizeY 0.05)
                ]

        stairs =
            shapes [ fill (Color.rgba 0 0 0 0.25) ]
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
    Canvas.text [ font { size = 12, family = "sans-serif" }, Canvas.Settings.Text.align Center ]
        (denormalizeVec2 { x = charPos.x, y = charPos.y - 0.02 } )
        text


viewRenderBosses : EncounterBosses -> List Renderable
viewRenderBosses bosses =
    let
        renderBossIndicator : Boss -> Color.Color -> Renderable
        renderBossIndicator b c =
            shapes [ fill c ]
                [ circle (denormalizeVec2 b.position) 15
                ]

        renderBossNameplate : Boss -> Renderable
        renderBossNameplate b =
            renderTextAboveCharacter b.position b.name

    in
    [ renderBossIndicator bosses.mograine (Color.rgba 1 0 0 1)
    , renderBossIndicator bosses.thane (Color.rgba 1 0.6 0 1)
    , renderBossIndicator bosses.zeliek (Color.rgba 0 0 1 1)
    , renderBossIndicator bosses.blaumeux (Color.rgba 0.3 0.7 0.3 1)

    , renderBossNameplate bosses.mograine
    , renderBossNameplate bosses.thane
    , renderBossNameplate bosses.zeliek
    , renderBossNameplate bosses.blaumeux
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
