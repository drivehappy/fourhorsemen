module Main exposing (main)

import Browser
import Cmd.Extra exposing (withNoCmd)
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h1, input, p, span, text, table, tr, th, h2, h3, br)
import Html.Attributes exposing (checked, disabled, href, size, style, type_, value)
import Html.Events exposing (onClick, onInput)

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
                newCmd =
                    d
                    |> receiveWebsocketData
                    |> Maybe.map handleServerData
                    |> Maybe.withDefault
            in
            --(model, newCmd)
            (model, Cmd.none)

        WebsocketError e ->
            let
                i = Debug.log "Elm WS Received Error: " e
            in
            (model, Cmd.none)

        CanvasClick (x, y) ->
            let
                i = Debug.log "Canvas clickX: " x
                j = Debug.log "Canvas clickY: " y
            in
            (model, Cmd.none)

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
                    [ value ""
                    --, onInput (UpdateUrl >> Websocket)
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
                [ button [ ] [ text "Start Encounter" ]
                , button [ ] [ text "Reset Encounter" ]
                ]
        ,   div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "align-items" "center"
                ]
                [ GameView.view
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
        ]
