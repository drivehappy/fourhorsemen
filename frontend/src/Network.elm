module Network exposing (..)

import Bytes exposing (..)
import Base64 exposing (..)
import Protobuf.Decode as PBD exposing (..)
import Protobuf.Encode as PBE exposing (..)

import WebsocketPort exposing (..)
import Message exposing (..)
import Model exposing (..)
import Codegen.Proto as PB exposing (..)


--
sendWebsocketData : PB.CSMain -> Cmd Msg
sendWebsocketData pbCSMain =
    let
        base64msg : Maybe String
        base64msg =
            pbCSMain
            |> PB.toCSMainEncoder
            |> PBE.encode
            |> Base64.fromBytes
    in
    case base64msg of
        Just m ->
            wsSend m

        Nothing ->
            -- TODO: log?
            Cmd.none


--
receiveWebsocketData : String -> Maybe PB.SCMain
receiveWebsocketData data =
    data
    |> Base64.toBytes
    |> Maybe.andThen (PBD.decode PB.sCMainDecoder)


--
handleServerData : PB.SCMain -> Cmd Msg
handleServerData pbSCMain =
    case pbSCMain.type_ of
        SCMainTypeUnrecognized_ _ ->
            -- TODO: log?
            Cmd.none

        InitialState ->
            let
                i = Debug.log "Received server initial state" pbSCMain.assignedPlayerId
            in
            Cmd.none

        GameStepUpdate ->
            Debug.log "Received server game step update" Cmd.none


--
-- Protobuf helpers
--

buildDefaultCSMain : CSMainType -> CSMain
buildDefaultCSMain type_ =
    { type_ = type_
    , playerJoin = Nothing
    , playerMove = Nothing
    , playerDirection = 0.0
    }
