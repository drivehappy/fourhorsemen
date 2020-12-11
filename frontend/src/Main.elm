module Main exposing (main)

import Browser
import Browser.Events as Events
import Cmd.Extra exposing (withNoCmd)
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h1, input, p, span, text, table, tr, th, h2, h3, br)
import Html.Attributes exposing (checked, disabled, href, size, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode

import GameModel exposing (..)
import GameView exposing (..)
import Message exposing (..)
import Model exposing (..)
import WebsocketPort exposing (..)
import CanvasPort exposing (..)
import Network exposing (..)

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

        newCurrPlayerPos : GameModel.Vec2
        newCurrPlayerPos = { x = p.position.x + x, y = p.position.y + y }

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

                        _ ->
                            model.keyState

                newModel =
                    { model | keyState = newKeyState }
            in
            (newModel, Cmd.none)

        FrameUpdate frameInt ->
            let
                dt = (frameInt / 1000.0)

                newCurrPlayer =
                    updatePlayerPos dt model.currentPlayer model.keyState

                newModel =
                    { model | currentPlayer = newCurrPlayer }
            in
            (newModel, Cmd.none)

        CanvasClick (x, y) ->
            let
                i = Debug.log "Canvas clickX: " x
                j = Debug.log "Canvas clickY: " y
            in
            (model, Cmd.none)

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

                k ->
                    Unknown k
    in
    Decode.map toDirection (Decode.field "key" Decode.string)


view : Model -> Html Msg
view model =
    div []
        [
            div
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
        ,   div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "align-items" "center"
                ]
                [ button [ onClick RequestStartGame ] [ text "Start Encounter" ]
                , button [ onClick RequestResetGame ] [ text "Reset Encounter" ]
                ]
        ,   div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "align-items" "center"
                ]
                [ GameView.view model
                ]
        ,   div
                []
                [ h3 [] [ Html.text "Characters" ]
                , viewRaidTable
                ]
        ]


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
