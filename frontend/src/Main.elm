module Main exposing (main)

import Browser
import Cmd.Extra exposing (withNoCmd)
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h1, input, p, span, text, table, tr, th, h2, h3, br)
import Html.Attributes exposing (checked, disabled, href, size, style, type_, value)
import Html.Events exposing (onClick, onInput)

import GameModel exposing (..)
import GameView exposing (..)
--import Network exposing (..)
import Message exposing (..)
import Model exposing (..)
import WebsocketPort exposing (..)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    { websocketModel = initWebsocketModel
        
    , isConnected = False
    }
        |> withNoCmd


-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        (newWSModel, newCmd) = 
            case msg of
                --Websocket w ->
                --    Network.update w model.websocketModel

                NewWebsocketConnect ->
                    (model, wsConnect "Test")

                NewWebsocketConnected s ->
                    let
                        i = Debug.log "Elm WS Connected: " s
                    in
                    (model, wsSend "Hello Server")

                WebsocketDataReceived d ->
                    let
                        i = Debug.log "Elm WS Received data: " d
                    in
                    (model, Cmd.none)
    in
    {-
    ( { model | websocketModel = newWSModel
      }
    -}
    ( model
    , newCmd
    )




-- VIEW

view : Model -> Html Msg
view model =
    --
    -- maybe: Network.view model
    --

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
                , button [ onClick NewWebsocketConnect ] [ text "Join" ]
                , br [] []
                , text ("Server connection: " ++ (if model.isConnected then "true" else "false"))
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
    --Network.subscriptions m.websocketModel

    Sub.batch
        [ wsConnected NewWebsocketConnected
        , wsReceivedMsg WebsocketDataReceived
        ]

