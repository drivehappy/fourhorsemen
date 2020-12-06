module Main exposing (main)

import Browser
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Cmd.Extra exposing (withNoCmd)
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h1, input, p, span, text, table, tr, th, h3)
import Html.Attributes exposing (checked, disabled, href, size, style, type_, value)
import Html.Events exposing (onClick, onInput)

import GameModel exposing (..)
import GameView exposing (..)
import Network exposing (..)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    { send = "Hello World!"
    , log = []
    , url = defaultUrl
    , useSimulator = True
    , wasLoaded = False
    , state = Network.initState
    , key = "socket"
    , error = Nothing
    }
        |> withNoCmd


-- VIEW


view : Model -> Html Msg
view model =
    --
    -- TODO: Network.view model
    --

    div []
        [
            div
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

