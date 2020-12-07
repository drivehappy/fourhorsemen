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

import Bytes exposing (..)
import Bytes.Decode as BD
import Base64
import Protobuf.Decode as PBDecode
import Protobuf.Encode as PBEncode

import Proto exposing (..)



main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    { isConnected = False
    }
        |> withNoCmd


-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WebsocketRequestConnect url ->
            (model, wsConnect url)

        WebsocketConnected s ->
            ( { isConnected = True }
            , wsSend "Hello Server"
            )

        WebsocketClosed s ->
            ( { isConnected = False }
            , Cmd.none
            )

        WebsocketDataReceived d ->
            let
                -- Base64 decode string data
                result : Maybe Bytes
                result = Base64.toBytes d

                newCmd =
                    result
                        -- |> Maybe.andThen (\bytes -> BD.decode (BD.string (Bytes.width bytes)) bytes)
                        |> Maybe.map (\data ->
                            -- TODO decode Protobuf here
                            let
                                pbSCMain =
                                    PBDecode.decode Proto.sCMainDecoder data

                                i = Debug.log "Elm Data Received" pbSCMain
                            in
                            Cmd.none
                        )
                        |> Maybe.withDefault Cmd.none
            in
            (model, newCmd)

        WebsocketError e ->
            let
                i = Debug.log "Elm WS Received Error: " e
            in
            (model, Cmd.none)


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
        ]
