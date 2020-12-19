module Network exposing (..)

import Bytes exposing (..)
import Base64 exposing (..)
import Dict exposing (..)
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
buildPlayerDebuffsFromPB : PB.Debuffs -> PlayerDebuffs
buildPlayerDebuffsFromPB pb =
    let
        debuffFromPB : Maybe PB.Debuff -> DebuffMark
        debuffFromPB =
            Maybe.map (\m -> (toFloat m.remainingMs, m.stackCount))
                >> Maybe.withDefault (0, 0)
    in
    { mograineDebuff = debuffFromPB pb.markMograine
    , thaneDebuff = debuffFromPB pb.markThane
    , zeliekDebuff = debuffFromPB pb.markZeliek
    , blaumeuxDebuff = debuffFromPB pb.markBlaumeux
    }


--
buildPlayerFromPB : PB.Player -> GameModel.Player
buildPlayerFromPB pb =
    let
        newPosition = pbPositionToVec2 pb.position

        newType =
            case pb.class of
                PB.Tank -> GameModel.Tank
                PB.Healer -> GameModel.Healer
                PB.RangedDps -> GameModel.RangedDPS
                PB.MeleeDps -> GameModel.MeleeDPS
                _ -> GameModel.Tank

        -- Transform debuffs
        newPlayerDebuffs : PlayerDebuffs
        newPlayerDebuffs =
            case pb.debuffs of
                Just db ->
                    buildPlayerDebuffsFromPB db

                _ ->
                    initPlayerDebuffs

    in
    { position = newPosition
    , direction = pb.direction
    , type_ = newType
    , name = pb.name
    , currentHealth = pb.currentHealth
    , maxHealth = pb.maxHealth
    , guid = pb.guid
    , debuffs = newPlayerDebuffs
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

                -- Assume we build our player at this point too
                j = Debug.log "UpdaterPlayerName" ()

                currPlayer = Just initPlayer

                newModel =
                    { m | currentPlayerGuid = pbSCMain.assignedPlayerId }
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

                newPlayers : Dict String GameModel.Player
                newPlayers =
                    pbSCMain.bulkPlayerUpdate
                        |> List.map buildPlayerFromPB
                        |> List.filterMap (\p ->
                            -- Update all players that are not the current player
                            if p.guid /= m.currentPlayerGuid then
                                Just (p.guid, p)
                            else
                                -- If we are the current player, update everything but the position, otherwise we get janky behavior
                                -- from the server trying to update our position to an old one.
                                let
                                    clientPlayerPos : Maybe GameModel.Vec2
                                    clientPlayerPos =
                                        Dict.get m.currentPlayerGuid m.players
                                            |> Maybe.map (\player -> player.position)

                                    newPlayer : Maybe GameModel.Player
                                    newPlayer =
                                        clientPlayerPos
                                            |> Maybe.map (\pos -> { p | position = pos })
                                in
                                newPlayer
                                    |> Maybe.map (\player -> (player.guid, player))
                        )
                        |> Dict.fromList

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
