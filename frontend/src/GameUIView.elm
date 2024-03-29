module GameUIView exposing (..)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Line exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Dict exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra as ListE exposing (..)

import GameModel exposing (..)
import Model exposing (..)
import Helpers exposing (..)



uiWidth = 40
uiHeight = 120


-- Common
headerText : String -> Point -> Renderable
headerText t p =
    Canvas.text
        [ font { size = 16, family = "sans-serif" }
        , Canvas.Settings.Text.align Left
        ]
        p t

standardText : String -> Point -> Renderable
standardText t p =
    Canvas.text
        [ font { size = 12, family = "sans-serif" }
        , Canvas.Settings.Text.align Left
        ]
        p t
        

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
        tanks = m.players |> Dict.filter (\ _ p -> p.type_ == Tank) |> Dict.values
        healers = m.players |> Dict.filter (\ _ p -> p.type_ == Healer) |> Dict.values
        melee = m.players |> Dict.filter (\ _ p -> p.type_ == MeleeDPS) |> Dict.values
        ranged = m.players |> Dict.filter (\ _ p -> p.type_ == RangedDPS) |> Dict.values

        renderPlayers : List Player -> Int -> List Renderable
        renderPlayers players startY =
            let
                l = ListE.initialize (players |> List.length) (\i -> startY + (i * 15))

                pl : List (Player, Int)
                pl = ListE.zip players l

            in
            pl
                |> List.map (\(p, i) ->
                    standardText p.name (15, (toFloat i))
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



-- UI View for the right-hand side
viewRHS : Model -> Html msg
viewRHS m =
    let
        clearScreen =
            shapes
                [ fill Color.white
                ]
                [ rect (0, 0) (uiWidth * viewZoomRatio) (uiHeight * viewZoomRatio)
                ]

        currentPlayer : Maybe Player
        currentPlayer = Dict.get m.currentPlayerGuid m.players

        targetEntity : Maybe (EntityTarget {})
        targetEntity =
            currentPlayer
                |> Maybe.andThen .targetGuid
                |> Maybe.andThen (\tg ->
                    -- Check our list of players for the target guid first
                    case Dict.get tg m.players of
                        Just t ->
                            Just { name = t.name, currentHealth = t.currentHealth, maxHealth = t.maxHealth }

                        _ ->
                            -- Check our bosses for the target guid
                            if tg == m.bosses.mograine.guid then
                                Just { name = m.bosses.mograine.name, currentHealth = m.bosses.mograine.currentHealth, maxHealth = m.bosses.mograine.maxHealth }
                            else if tg == m.bosses.thane.guid then
                                Just { name = m.bosses.thane.name, currentHealth = m.bosses.thane.currentHealth, maxHealth = m.bosses.thane.maxHealth }
                            else if tg == m.bosses.zeliek.guid then
                                Just { name = m.bosses.zeliek.name, currentHealth = m.bosses.zeliek.currentHealth, maxHealth = m.bosses.zeliek.maxHealth }
                            else if tg == m.bosses.blaumeux.guid then
                                Just { name = m.bosses.blaumeux.name, currentHealth = m.bosses.blaumeux.currentHealth, maxHealth = m.bosses.blaumeux.maxHealth }
                            else
                                Nothing
                )
    in
    Canvas.toHtml
        (uiWidth * viewZoomRatio, uiHeight * viewZoomRatio)
        [ style "border" "5px solid rgba(0,0,0,0.6)"
        ]
        ( [ clearScreen
          ]
          ++ viewRenderPlayerDebuffs m
          ++ (currentPlayer
                |> Maybe.map (viewRenderPlayerStats "You" 120)
                |> Maybe.withDefault []
             )
          ++ (targetEntity
                |> Maybe.map (viewRenderTargetStats "Target" 190)
                |> Maybe.withDefault []
             )
        )


--
viewRenderPlayerStats : String -> Float -> GameModel.Player -> List Renderable
viewRenderPlayerStats t posY p =
    let
        renderStats : Player -> Float -> List Renderable
        renderStats currentPlayer startY =
            [ standardText "Health: " (15, startY)
            , standardText (String.fromInt currentPlayer.currentHealth ++ " / " ++ String.fromInt currentPlayer.maxHealth) (80, startY)
            ]

        stats =
            renderStats p (posY + 20)
    in
    [ headerText t (6, posY) ]
    ++ stats


--
viewRenderTargetStats : String -> Float -> EntityTarget a -> List Renderable
viewRenderTargetStats t posY et =
    let
        percentHealth = round ((toFloat et.currentHealth / toFloat et.maxHealth) * 100.0)

        renderStats : Float -> List Renderable
        renderStats startY =
            [ standardText "Name: " (15, startY)
            , standardText et.name (80, startY)
            , standardText "Health: " (15, startY + 20)
            , standardText ("(" ++ String.fromInt percentHealth ++ "%)  " ++ String.fromInt et.currentHealth ++ " / " ++ String.fromInt et.maxHealth) (80, startY + 20)
            ]

        stats =
            renderStats (posY + 20)
    in
    [ headerText t (6, posY) ]
    ++ stats


--
viewRenderPlayerDebuffs : Model -> List Renderable
viewRenderPlayerDebuffs m =
    let
        renderDebuffs : Player -> Int -> List Renderable
        renderDebuffs currentPlayer startY =
            let
                mograineDebuff =
                    [ standardText "Mograine: " (15, toFloat startY)
                    , standardText (Tuple.second currentPlayer.debuffs.mograineDebuff |> String.fromInt) (80, toFloat startY)
                    , standardText (Tuple.first currentPlayer.debuffs.mograineDebuff |> String.fromFloat) (100, toFloat startY)
                    ]

                thaneDebuff =
                    [ standardText "Thane: " (15, toFloat startY + 15.0)
                    , standardText (Tuple.second currentPlayer.debuffs.thaneDebuff |> String.fromInt) (80, toFloat startY + 15.0)
                    , standardText (Tuple.first currentPlayer.debuffs.thaneDebuff |> String.fromFloat)  (100, toFloat startY + 15.0)
                    ]

                zeliekDebuff =
                    [ standardText "Zeliek: " (15, toFloat startY + 30.0)
                    , standardText (Tuple.second currentPlayer.debuffs.zeliekDebuff |> String.fromInt) (80, toFloat startY + 30.0)
                    , standardText (Tuple.first currentPlayer.debuffs.zeliekDebuff |> String.fromFloat)  (100, toFloat startY + 30.0)
                    ]
                    
                blaumeuxebuff =
                    [ standardText "Blaumeux: " (15, toFloat startY + 45.0)
                    , standardText (Tuple.second currentPlayer.debuffs.blaumeuxDebuff |> String.fromInt) (80, toFloat startY + 45.0)
                    , standardText (Tuple.first currentPlayer.debuffs.blaumeuxDebuff |> String.fromFloat)  (100, toFloat startY + 45.0)
                    ]
            in
            mograineDebuff
            ++ thaneDebuff
            ++ zeliekDebuff
            ++ blaumeuxebuff


        debuffs =
            let
                currentPlayer : Maybe Player
                currentPlayer = Dict.get m.currentPlayerGuid m.players
            in
            case currentPlayer of
                Just p ->
                    renderDebuffs p 40

                _ ->
                    []
    in
    [ headerText "Debuff Marks" (6, 20) ]
    ++ debuffs
