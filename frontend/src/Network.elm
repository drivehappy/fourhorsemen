module Network exposing (..)

import Bytes exposing (..)
import Base64 exposing (..)
import Protobuf.Decode as PBD exposing (..)
import Protobuf.Encode as PBE exposing (..)
import List.Extra as ListE exposing (..)

import WebsocketPort exposing (..)
import Message exposing (..)
import Model exposing (..)
import Codegen.Proto as PB exposing (..)
import GameModel exposing (..)


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
pbVec2ToModel : PB.Vec2 -> GameModel.Vec2
pbVec2ToModel p = { x = p.positionX, y = p.positionY }


pbPositionToVec2 : Maybe PB.Vec2 -> GameModel.Vec2
pbPositionToVec2 v =
    v
        |> Maybe.map pbVec2ToModel
        |> Maybe.withDefault ({ x = 0, y = 0 })


vec2ToPB : GameModel.Vec2 -> PB.Vec2
vec2ToPB v =
    { positionX = v.x, positionY = v.y }


--
buildBossFromPB : PB.Boss -> GameModel.Boss
buildBossFromPB pb =
    let
        newPosition = pbPositionToVec2 pb.position
    in
    { position = newPosition
    , direction = pb.direction
    , name = pb.name
    }


--
buildPlayerFromPB : PB.Player -> GameModel.Player
buildPlayerFromPB pb =
    let
        newPosition = pbPositionToVec2 pb.position
    in
    { position = newPosition
    , direction = pb.direction
    , name = pb.name
    , guid = pb.guid
    }


--
handleServerData : Model -> PB.SCMain -> (Model, Cmd Msg)
handleServerData m pbSCMain =
    case pbSCMain.type_ of
        SCMainTypeUnrecognized_ _ ->
            (m, Debug.log "Unknown msg received" Cmd.none)

        InitialState ->
            let
                i = Debug.log "Received server initial state" pbSCMain.assignedPlayerId
            in
            (m, Cmd.none)

        AssignPlayerId ->
            let
                i = Debug.log "PlayerID " pbSCMain.assignedPlayerId

                currPlayer = m.currentPlayer
                newCurrentPlayer =
                    { currPlayer | guid = pbSCMain.assignedPlayerId }
                newModel =
                    { m | currentPlayer = newCurrentPlayer }
            in
            (newModel, Cmd.none)

        GameStepUpdate ->
            let
                
                -- For now we just make this super simple and replace our entire boss state with
                -- the one provided by the server
                newBossStates : EncounterBosses
                newBossStates =
                    { mograine =
                        pbSCMain.bulkBossUpdate
                            |> ListE.find (\b -> b.type_ == PB.Mograine)
                            |> Maybe.map buildBossFromPB
                            |> Maybe.withDefault m.bosses.mograine
                    , thane =
                        pbSCMain.bulkBossUpdate
                            |> ListE.find (\b -> b.type_ == PB.Thane)
                            |> Maybe.map buildBossFromPB
                            |> Maybe.withDefault m.bosses.thane
                    , zeliek =
                        pbSCMain.bulkBossUpdate
                            |> ListE.find (\b -> b.type_ == PB.Zeliek)
                            |> Maybe.map buildBossFromPB
                            |> Maybe.withDefault m.bosses.zeliek
                    , blaumeux =
                        pbSCMain.bulkBossUpdate
                            |> ListE.find (\b -> b.type_ == PB.Blaumeux)
                            |> Maybe.map buildBossFromPB
                            |> Maybe.withDefault m.bosses.blaumeux
                    }

                newPlayers : List GameModel.Player
                newPlayers =
                    Debug.log "Player list"
                    pbSCMain.bulkPlayerUpdate
                        |> List.map buildPlayerFromPB

                newModel =
                    { m | bosses = newBossStates, players = newPlayers }

            in
            (newModel, Cmd.none)


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
