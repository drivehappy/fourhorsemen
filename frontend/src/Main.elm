module Main exposing (main)

import Browser
import Browser.Events as Events
import Cmd.Extra exposing (withNoCmd)
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h1, input, p, span, text, table, tr, th, h2, h3, br)
import Html.Attributes exposing (attribute, class, checked, disabled, hidden, href, size, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode

import GameModel exposing (..)
import GameView exposing (..)
import GameUIView exposing (..)
import Message exposing (..)
import Model exposing (..)
import WebsocketPort exposing (..)
import CanvasPort exposing (..)
import Network exposing (..)
import Helpers exposing (..)

import Bytes exposing (..)
import Bytes.Decode as BD
import Bytes.Encode as BE
import Base64
import Protobuf.Decode as PBDecode
import Protobuf.Encode as PBEncode

import Codegen.Proto as PB exposing (..)



main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    initModel
        |> withNoCmd


-- Update


moveSpeed = 0.1


--
updatePlayerPos : Float -> GameModel.Player -> KeyState -> GameModel.Player
updatePlayerPos dt p k =
    let
        x =
            let
                x1 = if k.left then (-moveSpeed * dt) else 0
                x2 = if k.right then (moveSpeed * dt) else 0
            in
            x1 + x2
            
        y =
            let
                y1 = if k.up then (-moveSpeed * dt) else 0
                y2 = if k.down then (moveSpeed * dt) else 0
            in
            y1 + y2

        finalX =
            let
                newX = p.position.x + x
            in
            if newX > 1 then 1
            else if newX < 0 then 0
            else newX

        finalY =
            let
                newY = p.position.y + y
            in
            if newY > 1 then 1
            else if newY < 0 then 0
            else newY

        newCurrPlayerPos : GameModel.Vec2
        newCurrPlayerPos = { x = finalX, y = finalY }

        newCurrPlayer =
            { p | position = newCurrPlayerPos }
    in
    newCurrPlayer


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WebsocketRequestConnect url ->
            (model, wsConnect url)

        WebsocketConnected s ->
            let
                pbCSNewPlayerJoin : PB.CSNewPlayerJoin
                pbCSNewPlayerJoin = { playerName = model.playerName }

                initPlayerJoin : PB.CSMain
                initPlayerJoin = buildDefaultCSMain PlayerJoin

                pbCSMain : PB.CSMain
                pbCSMain =
                    { initPlayerJoin | playerJoin = Just pbCSNewPlayerJoin }
            in
            ( { model | isConnected = True }
            , sendWebsocketData pbCSMain
            )

        WebsocketClosed s ->
            ( { model | isConnected = False }
            , Cmd.none
            )

        WebsocketDataReceived d ->
            let
                (newModel, newCmd) =
                    case receiveWebsocketData d of
                        Just d2 ->
                            handleServerData model d2

                        Nothing ->
                            (model, Cmd.none)
            in
            (newModel, newCmd)

        WebsocketError e ->
            let
                i = Debug.log "Elm WS Received Error: " e
            in
            (model, Cmd.none)

        RequestStartGame ->
            let
                pbCSMain : PB.CSMain
                pbCSMain = buildDefaultCSMain RequestGameStart
            in
            ( model
            , sendWebsocketData pbCSMain
            )

        RequestResetGame ->
            let
                pbCSMain : PB.CSMain
                pbCSMain = buildDefaultCSMain RequestGameReset
            in
            ( model
            , sendWebsocketData pbCSMain
            )

        KeyDown k ->
            let
                newKeyState : KeyState
                newKeyState =
                    let
                        currKeyState = model.keyState
                    in 
                    case k of
                        Up ->
                            { currKeyState | up = True }

                        Down ->
                            { currKeyState | down = True }

                        Left ->
                            { currKeyState | left = True }

                        Right ->
                            { currKeyState | right = True }

                        UseAbility1 ->
                            { currKeyState | useAbility1 = True }
                        
                        UseAbility2 ->
                            { currKeyState | useAbility2 = True }

                        _ ->
                            model.keyState

                newModel =
                    { model | keyState = newKeyState }
            in
            (newModel, Cmd.none)

        KeyUp k ->
            let
                newKeyState : KeyState
                newKeyState =
                    let
                        currKeyState = model.keyState
                    in 
                    case k of
                        Up ->
                            { currKeyState | up = False }

                        Down ->
                            { currKeyState | down = False }

                        Left ->
                            { currKeyState | left = False }

                        Right ->
                            { currKeyState | right = False }

                        UseAbility1 ->
                            { currKeyState | useAbility1 = False }
                        
                        UseAbility2 ->
                            { currKeyState | useAbility2 = False }

                        _ ->
                            model.keyState

                newModel =
                    { model | keyState = newKeyState }
            in
            (newModel, Cmd.none)

        FrameUpdate frameInt ->
            let
                dt = (frameInt / 1000.0)

                oldCurrentPlayer : Maybe GameModel.Player
                oldCurrentPlayer = Dict.get model.currentPlayerGuid model.players

                updatedCurrPlayer : Dict String GameModel.Player
                updatedCurrPlayer =
                    Dict.get model.currentPlayerGuid model.players
                        |> Maybe.map (\p -> updatePlayerPos dt p model.keyState)
                        |> Maybe.map (\p -> Dict.insert model.currentPlayerGuid p model.players)
                        |> Maybe.withDefault model.players

                newModel =
                    { model | players = updatedCurrPlayer }

                newCurrentPlayer : Maybe GameModel.Player
                newCurrentPlayer = Dict.get model.currentPlayerGuid updatedCurrPlayer

                -- Send the move command to the server
                -- Note: This might be pretty spammy, once every frame, may need
                --       to just track the direction and whether play is moving.
                newCmd =
                    case newCurrentPlayer of
                        Just ncp ->
                            let
                                pbCSMain : PB.CSMain
                                pbCSMain =
                                    let
                                        p = buildDefaultCSMain PlayerMove
                                    in
                                    { p | playerMove = Just (vec2ToPB ncp.position) }

                                oldPos =
                                    oldCurrentPlayer
                                        |> Maybe.map (\p -> p.position)

                                newPos = ncp.position
                            in
                            if (Just newPos) /= oldPos then
                                -- Only send this if our player position changed
                                sendWebsocketData pbCSMain
                            else
                                Cmd.none

                        _ ->
                            Cmd.none

            in
            (newModel, newCmd)

        CanvasClick (x, y) ->
            let
                drawRadiusSizeSquared = 15 * 15

                calcDistSq : Float -> Float -> Float
                calcDistSq px py = (px * px) + (py * py)

                calcDistPosSq : GameModel.Vec2 -> Float
                calcDistPosSq v =
                    calcDistSq
                        (toFloat x - denormalizeX v.x)
                        (toFloat y - denormalizeY v.y) 


                -- Check each boss
                dM = calcDistPosSq model.bosses.mograine.position
                dT = calcDistPosSq model.bosses.thane.position
                dZ = calcDistPosSq model.bosses.zeliek.position
                dB = calcDistPosSq model.bosses.blaumeux.position

                --
                p = Debug.log "DebugSelect0 " drawRadiusSizeSquared
                k = Debug.log "DebugSelect1 " (x, y)
                a = Debug.log "DebugSelect3 " (denormalizeX model.bosses.mograine.position.x, denormalizeY model.bosses.mograine.position.y)

                newTargetGuid =
                    if dM <= drawRadiusSizeSquared then
                        Debug.log "Selected mograine" (Just model.bosses.mograine.guid)
                    else if dT <= drawRadiusSizeSquared then
                        Debug.log "Selected thane" (Just model.bosses.thane.guid)
                    else if dZ <= drawRadiusSizeSquared then
                        Debug.log "Selected zeliek" (Just model.bosses.zeliek.guid)
                    else if dB <= drawRadiusSizeSquared then
                        Debug.log "Selected blaumeux" (Just model.bosses.blaumeux.guid)
                    else
                        Debug.log "Did not select any bosses " Nothing

                currentPlayer : Maybe GameModel.Player
                currentPlayer =
                    Dict.get model.currentPlayerGuid model.players

                newPlayerModel : Maybe GameModel.Player
                newPlayerModel =
                    currentPlayer
                        |> Maybe.map (\cp -> { cp | targetGuid = newTargetGuid })

                updatedPlayers =
                    newPlayerModel
                        |> Maybe.map (\p2 -> Dict.insert model.currentPlayerGuid p2 model.players)
                        |> Maybe.withDefault model.players
            in
            -- TODO: Send msg to server with new target
            ( { model | players = updatedPlayers }
            , Cmd.none
            )

        UpdateServerCode newServerCode ->
            let
                newModel =
                    { model | serverCode = newServerCode }
            in
            (newModel, Cmd.none)

        UpdatePlayerName newPlayerName ->
            let
                newModel =
                    { model | playerName = newPlayerName }
            in
            (newModel, Cmd.none)



defaultUrl : String
defaultUrl =
    "ws://localhost:8081/websocket"


-- VIEW

keyDecoder : Decode.Decoder KeyDirection
keyDecoder =
    let
        toDirection : String -> KeyDirection
        toDirection s =
            case s of
                "w" ->
                    Up

                "d" ->
                    Right

                "s" ->
                    Down

                "a" ->
                    Left

                "1" ->
                    UseAbility1

                "2" ->
                    UseAbility2

                k ->
                    Unknown k
    in
    Decode.map toDirection (Decode.field "key" Decode.string)


--
viewGame : Model -> Bool -> List (Html Msg)
viewGame model visible =
    [ div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "visibility" (if visible then "" else "hidden")
        ]
        [ button [ onClick RequestStartGame ] [ text "Start Encounter" ]
        , button [ onClick RequestResetGame ] [ text "Reset Encounter" ]
        ]
    , div
        [ class "container"
        , style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "visibility" (if visible then "" else "hidden")
        ]
        [
            div
                [ style "display" "flex"
                , style "justify-content" "left"
                , style "align-items" "center"
                ]
                [ GameUIView.viewLHS model
                ]
        ,   div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "align-items" "center"
                ]
                [ GameView.view model
                ]
        ,   div
                [ style "display" "flex"
                , style "justify-content" "right"
                , style "align-items" "center"
                ]
                [ GameUIView.viewRHS model
                ]
        ]
    ]


--
view : Model -> Html Msg
view model =
    let
        playAreaView : List (Html Msg)
        playAreaView =
            viewGame model model.isConnected
    in
    div []
        (
            [ div
                []
                [ h2 [] [ text "Boss Fight Sim" ]
                , text "Instance code required:"
                , br [] []
                , input
                    [ value model.serverCode
                    , onInput UpdateServerCode
                    , size 30
                    ]
                    []
                , br [] []
                , text "Player name:"
                , br [] []
                , input
                    [ value model.playerName
                    , onInput UpdatePlayerName
                    , size 30
                    ]
                    []
                , br [] []
                , button [ onClick (WebsocketRequestConnect defaultUrl) ] [ text "Join" ]
                , br [] []
                , text ("Server connection: " ++ (if model.isConnected then "True" else "False"))
                ]
            ]
            ++ playAreaView
        )


subscriptions : Model -> Sub Msg
subscriptions m =
    Sub.batch
        [ wsConnected WebsocketConnected
        , wsDisconnected WebsocketClosed
        , wsReceivedMsg WebsocketDataReceived
        , wsError WebsocketError
        , canvasClicked CanvasClick
        , Events.onKeyDown (Decode.map KeyDown keyDecoder)
        , Events.onKeyUp (Decode.map KeyUp keyDecoder)
        , Events.onAnimationFrameDelta FrameUpdate
        ]
