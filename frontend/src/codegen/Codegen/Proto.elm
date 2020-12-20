{- !!! DO NOT EDIT THIS FILE MANUALLY !!! -}


module Codegen.Proto exposing
    ( PlayerClass(..), BossType(..), CSPlayerActionType(..), CSMainType(..), SCGameStateType(..), SCBossAbilityType(..), SCMainType(..), Vec2, Debuff, Debuffs, Player, Boss, CSNewPlayerJoin, CSPlayerAction, CSMain, SCGameState, SCBossAbility, SCMain
    , vec2Decoder, debuffDecoder, debuffsDecoder, playerDecoder, bossDecoder, cSNewPlayerJoinDecoder, cSPlayerActionDecoder, cSMainDecoder, sCGameStateDecoder, sCBossAbilityDecoder, sCMainDecoder
    , toVec2Encoder, toDebuffEncoder, toDebuffsEncoder, toPlayerEncoder, toBossEncoder, toCSNewPlayerJoinEncoder, toCSPlayerActionEncoder, toCSMainEncoder, toSCGameStateEncoder, toSCBossAbilityEncoder, toSCMainEncoder
    )

{-| ProtoBuf module: `Codegen.Proto`

This module was generated automatically using

  - [`protoc-gen-elm`](https://www.npmjs.com/package/protoc-gen-elm) 1.0.0-beta-2
  - `protoc` 3.14.0
  - the following specification file: `root.proto`

To run it use [`elm-protocol-buffers`](https://package.elm-lang.org/packages/eriktim/elm-protocol-buffers/1.1.0) version 1.1.0 or higher.


# Model

@docs PlayerClass, BossType, CSPlayerActionType, CSMainType, SCGameStateType, SCBossAbilityType, SCMainType, Vec2, Debuff, Debuffs, Player, Boss, CSNewPlayerJoin, CSPlayerAction, CSMain, SCGameState, SCBossAbility, SCMain


# Decoder

@docs vec2Decoder, debuffDecoder, debuffsDecoder, playerDecoder, bossDecoder, cSNewPlayerJoinDecoder, cSPlayerActionDecoder, cSMainDecoder, sCGameStateDecoder, sCBossAbilityDecoder, sCMainDecoder


# Encoder

@docs toVec2Encoder, toDebuffEncoder, toDebuffsEncoder, toPlayerEncoder, toBossEncoder, toCSNewPlayerJoinEncoder, toCSPlayerActionEncoder, toCSMainEncoder, toSCGameStateEncoder, toSCBossAbilityEncoder, toSCMainEncoder

-}

import Protobuf.Decode as Decode
import Protobuf.Encode as Encode



-- MODEL


{-| `PlayerClass` enumeration
-}
type PlayerClass
    = Tank
    | Healer
    | RangedDps
    | MeleeDps
    | PlayerClassUnrecognized_ Int


{-| `BossType` enumeration
-}
type BossType
    = Mograine
    | Thane
    | Blaumeux
    | Zeliek
    | BossTypeUnrecognized_ Int


{-| `CSPlayerActionType` enumeration
-}
type CSPlayerActionType
    = Taunt
    | Heal
    | RangedAttack
    | MeleeAttack
    | CSPlayerActionTypeUnrecognized_ Int


{-| `CSMainType` enumeration
-}
type CSMainType
    = PlayerJoin
    | PlayerMove
    | PlayerDirection
    | RequestGameStart
    | RequestGamePause
    | RequestGameReset
    | CSMainTypeUnrecognized_ Int


{-| `SCGameStateType` enumeration
-}
type SCGameStateType
    = Lobby
    | Running
    | Paused
    | SCGameStateTypeUnrecognized_ Int


{-| `SCBossAbilityType` enumeration
-}
type SCBossAbilityType
    = RighteousFire
    | Meteor
    | HolyWrath
    | VoidZone
    | SCBossAbilityTypeUnrecognized_ Int


{-| `SCMainType` enumeration
-}
type SCMainType
    = InitialState
    | AssignPlayerId
    | GameStepUpdate
    | SCMainTypeUnrecognized_ Int


{-| `Vec2` message
-}
type alias Vec2 =
    { positionX : Float
    , positionY : Float
    }


{-| `Debuff` message
-}
type alias Debuff =
    { stackCount : Int
    , remainingMs : Int
    }


{-| `Debuffs` message
-}
type alias Debuffs =
    { markMograine : Maybe Debuff
    , markThane : Maybe Debuff
    , markBlaumeux : Maybe Debuff
    , markZeliek : Maybe Debuff
    }


{-| `Player` message
-}
type alias Player =
    { name : String
    , class : PlayerClass
    , position : Maybe Vec2
    , direction : Float
    , currentHealth : Int
    , maxHealth : Int
    , debuffs : Maybe Debuffs
    , guid : String
    , targetGuid : String
    }


{-| `Boss` message
-}
type alias Boss =
    { type_ : BossType
    , name : String
    , position : Maybe Vec2
    , direction : Float
    , currentHealth : Int
    , maxHealth : Int
    , isSpirit : Bool
    , shieldWallActive : Bool
    , guid : String
    }


{-| `CSNewPlayerJoin` message
-}
type alias CSNewPlayerJoin =
    { playerName : String
    }


{-| `CSPlayerAction` message
-}
type alias CSPlayerAction =
    { type_ : CSPlayerActionType
    , guidTarget : Int
    }


{-| `CSMain` message
-}
type alias CSMain =
    { type_ : CSMainType
    , playerJoin : Maybe CSNewPlayerJoin
    , playerMove : Maybe Vec2
    , playerDirection : Float
    }


{-| `SCGameState` message
-}
type alias SCGameState =
    { type_ : SCGameStateType
    }


{-| `SCBossAbility` message
-}
type alias SCBossAbility =
    { type_ : SCBossAbilityType
    , playerGuidAffected : List Int
    }


{-| `SCMain` message
-}
type alias SCMain =
    { type_ : SCMainType
    , assignedPlayerId : String
    , bulkPlayerUpdate : List Player
    , bulkBossUpdate : List Boss
    , bossAbilityPerformed : List SCBossAbility
    }



-- DECODER


playerClassDecoder : Decode.Decoder PlayerClass
playerClassDecoder =
    Decode.int32
        |> Decode.map
            (\value ->
                case value of
                    0 ->
                        Tank

                    1 ->
                        Healer

                    2 ->
                        RangedDps

                    3 ->
                        MeleeDps

                    v ->
                        PlayerClassUnrecognized_ v
            )


bossTypeDecoder : Decode.Decoder BossType
bossTypeDecoder =
    Decode.int32
        |> Decode.map
            (\value ->
                case value of
                    0 ->
                        Mograine

                    1 ->
                        Thane

                    2 ->
                        Blaumeux

                    3 ->
                        Zeliek

                    v ->
                        BossTypeUnrecognized_ v
            )


cSPlayerActionTypeDecoder : Decode.Decoder CSPlayerActionType
cSPlayerActionTypeDecoder =
    Decode.int32
        |> Decode.map
            (\value ->
                case value of
                    0 ->
                        Taunt

                    1 ->
                        Heal

                    2 ->
                        RangedAttack

                    3 ->
                        MeleeAttack

                    v ->
                        CSPlayerActionTypeUnrecognized_ v
            )


cSMainTypeDecoder : Decode.Decoder CSMainType
cSMainTypeDecoder =
    Decode.int32
        |> Decode.map
            (\value ->
                case value of
                    0 ->
                        PlayerJoin

                    1 ->
                        PlayerMove

                    2 ->
                        PlayerDirection

                    3 ->
                        RequestGameStart

                    4 ->
                        RequestGamePause

                    5 ->
                        RequestGameReset

                    v ->
                        CSMainTypeUnrecognized_ v
            )


sCGameStateTypeDecoder : Decode.Decoder SCGameStateType
sCGameStateTypeDecoder =
    Decode.int32
        |> Decode.map
            (\value ->
                case value of
                    0 ->
                        Lobby

                    1 ->
                        Running

                    2 ->
                        Paused

                    v ->
                        SCGameStateTypeUnrecognized_ v
            )


sCBossAbilityTypeDecoder : Decode.Decoder SCBossAbilityType
sCBossAbilityTypeDecoder =
    Decode.int32
        |> Decode.map
            (\value ->
                case value of
                    0 ->
                        RighteousFire

                    1 ->
                        Meteor

                    2 ->
                        HolyWrath

                    3 ->
                        VoidZone

                    v ->
                        SCBossAbilityTypeUnrecognized_ v
            )


sCMainTypeDecoder : Decode.Decoder SCMainType
sCMainTypeDecoder =
    Decode.int32
        |> Decode.map
            (\value ->
                case value of
                    0 ->
                        InitialState

                    1 ->
                        AssignPlayerId

                    2 ->
                        GameStepUpdate

                    v ->
                        SCMainTypeUnrecognized_ v
            )


{-| `Vec2` decoder
-}
vec2Decoder : Decode.Decoder Vec2
vec2Decoder =
    Decode.message (Vec2 0 0)
        [ Decode.optional 1 Decode.float setPositionX
        , Decode.optional 2 Decode.float setPositionY
        ]


{-| `Debuff` decoder
-}
debuffDecoder : Decode.Decoder Debuff
debuffDecoder =
    Decode.message (Debuff 0 0)
        [ Decode.optional 1 Decode.int32 setStackCount
        , Decode.optional 2 Decode.int32 setRemainingMs
        ]


{-| `Debuffs` decoder
-}
debuffsDecoder : Decode.Decoder Debuffs
debuffsDecoder =
    Decode.message (Debuffs Nothing Nothing Nothing Nothing)
        [ Decode.optional 1 (Decode.map Just debuffDecoder) setMarkMograine
        , Decode.optional 2 (Decode.map Just debuffDecoder) setMarkThane
        , Decode.optional 3 (Decode.map Just debuffDecoder) setMarkBlaumeux
        , Decode.optional 4 (Decode.map Just debuffDecoder) setMarkZeliek
        ]


{-| `Player` decoder
-}
playerDecoder : Decode.Decoder Player
playerDecoder =
    Decode.message (Player "" Tank Nothing 0 0 0 Nothing "" "")
        [ Decode.optional 1 Decode.string setName
        , Decode.optional 2 playerClassDecoder setClass
        , Decode.optional 3 (Decode.map Just vec2Decoder) setPosition
        , Decode.optional 4 Decode.float setDirection
        , Decode.optional 5 Decode.int32 setCurrentHealth
        , Decode.optional 6 Decode.int32 setMaxHealth
        , Decode.optional 9 (Decode.map Just debuffsDecoder) setDebuffs
        , Decode.optional 10 Decode.string setGuid
        , Decode.optional 11 Decode.string setTargetGuid
        ]


{-| `Boss` decoder
-}
bossDecoder : Decode.Decoder Boss
bossDecoder =
    Decode.message (Boss Mograine "" Nothing 0 0 0 False False "")
        [ Decode.optional 1 bossTypeDecoder setType_
        , Decode.optional 2 Decode.string setName
        , Decode.optional 3 (Decode.map Just vec2Decoder) setPosition
        , Decode.optional 4 Decode.float setDirection
        , Decode.optional 5 Decode.int32 setCurrentHealth
        , Decode.optional 6 Decode.int32 setMaxHealth
        , Decode.optional 7 Decode.bool setIsSpirit
        , Decode.optional 8 Decode.bool setShieldWallActive
        , Decode.optional 10 Decode.string setGuid
        ]


{-| `CSNewPlayerJoin` decoder
-}
cSNewPlayerJoinDecoder : Decode.Decoder CSNewPlayerJoin
cSNewPlayerJoinDecoder =
    Decode.message (CSNewPlayerJoin "")
        [ Decode.optional 1 Decode.string setPlayerName
        ]


{-| `CSPlayerAction` decoder
-}
cSPlayerActionDecoder : Decode.Decoder CSPlayerAction
cSPlayerActionDecoder =
    Decode.message (CSPlayerAction Taunt 0)
        [ Decode.optional 1 cSPlayerActionTypeDecoder setType_
        , Decode.optional 2 Decode.int32 setGuidTarget
        ]


{-| `CSMain` decoder
-}
cSMainDecoder : Decode.Decoder CSMain
cSMainDecoder =
    Decode.message (CSMain PlayerJoin Nothing Nothing 0)
        [ Decode.optional 1 cSMainTypeDecoder setType_
        , Decode.optional 2 (Decode.map Just cSNewPlayerJoinDecoder) setPlayerJoin
        , Decode.optional 3 (Decode.map Just vec2Decoder) setPlayerMove
        , Decode.optional 4 Decode.float setPlayerDirection
        ]


{-| `SCGameState` decoder
-}
sCGameStateDecoder : Decode.Decoder SCGameState
sCGameStateDecoder =
    Decode.message (SCGameState Lobby)
        [ Decode.optional 1 sCGameStateTypeDecoder setType_
        ]


{-| `SCBossAbility` decoder
-}
sCBossAbilityDecoder : Decode.Decoder SCBossAbility
sCBossAbilityDecoder =
    Decode.message (SCBossAbility RighteousFire [])
        [ Decode.optional 1 sCBossAbilityTypeDecoder setType_
        , Decode.repeated 2 Decode.int32 .playerGuidAffected setPlayerGuidAffected
        ]


{-| `SCMain` decoder
-}
sCMainDecoder : Decode.Decoder SCMain
sCMainDecoder =
    Decode.message (SCMain InitialState "" [] [] [])
        [ Decode.optional 1 sCMainTypeDecoder setType_
        , Decode.optional 2 Decode.string setAssignedPlayerId
        , Decode.repeated 6 playerDecoder .bulkPlayerUpdate setBulkPlayerUpdate
        , Decode.repeated 7 bossDecoder .bulkBossUpdate setBulkBossUpdate
        , Decode.repeated 12 sCBossAbilityDecoder .bossAbilityPerformed setBossAbilityPerformed
        ]



-- ENCODER


toPlayerClassEncoder : PlayerClass -> Encode.Encoder
toPlayerClassEncoder value =
    Encode.int32 <|
        case value of
            Tank ->
                0

            Healer ->
                1

            RangedDps ->
                2

            MeleeDps ->
                3

            PlayerClassUnrecognized_ v ->
                v


toBossTypeEncoder : BossType -> Encode.Encoder
toBossTypeEncoder value =
    Encode.int32 <|
        case value of
            Mograine ->
                0

            Thane ->
                1

            Blaumeux ->
                2

            Zeliek ->
                3

            BossTypeUnrecognized_ v ->
                v


toCSPlayerActionTypeEncoder : CSPlayerActionType -> Encode.Encoder
toCSPlayerActionTypeEncoder value =
    Encode.int32 <|
        case value of
            Taunt ->
                0

            Heal ->
                1

            RangedAttack ->
                2

            MeleeAttack ->
                3

            CSPlayerActionTypeUnrecognized_ v ->
                v


toCSMainTypeEncoder : CSMainType -> Encode.Encoder
toCSMainTypeEncoder value =
    Encode.int32 <|
        case value of
            PlayerJoin ->
                0

            PlayerMove ->
                1

            PlayerDirection ->
                2

            RequestGameStart ->
                3

            RequestGamePause ->
                4

            RequestGameReset ->
                5

            CSMainTypeUnrecognized_ v ->
                v


toSCGameStateTypeEncoder : SCGameStateType -> Encode.Encoder
toSCGameStateTypeEncoder value =
    Encode.int32 <|
        case value of
            Lobby ->
                0

            Running ->
                1

            Paused ->
                2

            SCGameStateTypeUnrecognized_ v ->
                v


toSCBossAbilityTypeEncoder : SCBossAbilityType -> Encode.Encoder
toSCBossAbilityTypeEncoder value =
    Encode.int32 <|
        case value of
            RighteousFire ->
                0

            Meteor ->
                1

            HolyWrath ->
                2

            VoidZone ->
                3

            SCBossAbilityTypeUnrecognized_ v ->
                v


toSCMainTypeEncoder : SCMainType -> Encode.Encoder
toSCMainTypeEncoder value =
    Encode.int32 <|
        case value of
            InitialState ->
                0

            AssignPlayerId ->
                1

            GameStepUpdate ->
                2

            SCMainTypeUnrecognized_ v ->
                v


{-| `Vec2` encoder
-}
toVec2Encoder : Vec2 -> Encode.Encoder
toVec2Encoder model =
    Encode.message
        [ ( 1, Encode.float model.positionX )
        , ( 2, Encode.float model.positionY )
        ]


{-| `Debuff` encoder
-}
toDebuffEncoder : Debuff -> Encode.Encoder
toDebuffEncoder model =
    Encode.message
        [ ( 1, Encode.int32 model.stackCount )
        , ( 2, Encode.int32 model.remainingMs )
        ]


{-| `Debuffs` encoder
-}
toDebuffsEncoder : Debuffs -> Encode.Encoder
toDebuffsEncoder model =
    Encode.message
        [ ( 1, (Maybe.withDefault Encode.none << Maybe.map toDebuffEncoder) model.markMograine )
        , ( 2, (Maybe.withDefault Encode.none << Maybe.map toDebuffEncoder) model.markThane )
        , ( 3, (Maybe.withDefault Encode.none << Maybe.map toDebuffEncoder) model.markBlaumeux )
        , ( 4, (Maybe.withDefault Encode.none << Maybe.map toDebuffEncoder) model.markZeliek )
        ]


{-| `Player` encoder
-}
toPlayerEncoder : Player -> Encode.Encoder
toPlayerEncoder model =
    Encode.message
        [ ( 1, Encode.string model.name )
        , ( 2, toPlayerClassEncoder model.class )
        , ( 3, (Maybe.withDefault Encode.none << Maybe.map toVec2Encoder) model.position )
        , ( 4, Encode.float model.direction )
        , ( 5, Encode.int32 model.currentHealth )
        , ( 6, Encode.int32 model.maxHealth )
        , ( 9, (Maybe.withDefault Encode.none << Maybe.map toDebuffsEncoder) model.debuffs )
        , ( 10, Encode.string model.guid )
        , ( 11, Encode.string model.targetGuid )
        ]


{-| `Boss` encoder
-}
toBossEncoder : Boss -> Encode.Encoder
toBossEncoder model =
    Encode.message
        [ ( 1, toBossTypeEncoder model.type_ )
        , ( 2, Encode.string model.name )
        , ( 3, (Maybe.withDefault Encode.none << Maybe.map toVec2Encoder) model.position )
        , ( 4, Encode.float model.direction )
        , ( 5, Encode.int32 model.currentHealth )
        , ( 6, Encode.int32 model.maxHealth )
        , ( 7, Encode.bool model.isSpirit )
        , ( 8, Encode.bool model.shieldWallActive )
        , ( 10, Encode.string model.guid )
        ]


{-| `CSNewPlayerJoin` encoder
-}
toCSNewPlayerJoinEncoder : CSNewPlayerJoin -> Encode.Encoder
toCSNewPlayerJoinEncoder model =
    Encode.message
        [ ( 1, Encode.string model.playerName )
        ]


{-| `CSPlayerAction` encoder
-}
toCSPlayerActionEncoder : CSPlayerAction -> Encode.Encoder
toCSPlayerActionEncoder model =
    Encode.message
        [ ( 1, toCSPlayerActionTypeEncoder model.type_ )
        , ( 2, Encode.int32 model.guidTarget )
        ]


{-| `CSMain` encoder
-}
toCSMainEncoder : CSMain -> Encode.Encoder
toCSMainEncoder model =
    Encode.message
        [ ( 1, toCSMainTypeEncoder model.type_ )
        , ( 2, (Maybe.withDefault Encode.none << Maybe.map toCSNewPlayerJoinEncoder) model.playerJoin )
        , ( 3, (Maybe.withDefault Encode.none << Maybe.map toVec2Encoder) model.playerMove )
        , ( 4, Encode.float model.playerDirection )
        ]


{-| `SCGameState` encoder
-}
toSCGameStateEncoder : SCGameState -> Encode.Encoder
toSCGameStateEncoder model =
    Encode.message
        [ ( 1, toSCGameStateTypeEncoder model.type_ )
        ]


{-| `SCBossAbility` encoder
-}
toSCBossAbilityEncoder : SCBossAbility -> Encode.Encoder
toSCBossAbilityEncoder model =
    Encode.message
        [ ( 1, toSCBossAbilityTypeEncoder model.type_ )
        , ( 2, Encode.list Encode.int32 model.playerGuidAffected )
        ]


{-| `SCMain` encoder
-}
toSCMainEncoder : SCMain -> Encode.Encoder
toSCMainEncoder model =
    Encode.message
        [ ( 1, toSCMainTypeEncoder model.type_ )
        , ( 2, Encode.string model.assignedPlayerId )
        , ( 6, Encode.list toPlayerEncoder model.bulkPlayerUpdate )
        , ( 7, Encode.list toBossEncoder model.bulkBossUpdate )
        , ( 12, Encode.list toSCBossAbilityEncoder model.bossAbilityPerformed )
        ]



-- SETTERS


setPositionX : a -> { b | positionX : a } -> { b | positionX : a }
setPositionX value model =
    { model | positionX = value }


setPositionY : a -> { b | positionY : a } -> { b | positionY : a }
setPositionY value model =
    { model | positionY = value }


setStackCount : a -> { b | stackCount : a } -> { b | stackCount : a }
setStackCount value model =
    { model | stackCount = value }


setRemainingMs : a -> { b | remainingMs : a } -> { b | remainingMs : a }
setRemainingMs value model =
    { model | remainingMs = value }


setMarkMograine : a -> { b | markMograine : a } -> { b | markMograine : a }
setMarkMograine value model =
    { model | markMograine = value }


setMarkThane : a -> { b | markThane : a } -> { b | markThane : a }
setMarkThane value model =
    { model | markThane = value }


setMarkBlaumeux : a -> { b | markBlaumeux : a } -> { b | markBlaumeux : a }
setMarkBlaumeux value model =
    { model | markBlaumeux = value }


setMarkZeliek : a -> { b | markZeliek : a } -> { b | markZeliek : a }
setMarkZeliek value model =
    { model | markZeliek = value }


setName : a -> { b | name : a } -> { b | name : a }
setName value model =
    { model | name = value }


setClass : a -> { b | class : a } -> { b | class : a }
setClass value model =
    { model | class = value }


setPosition : a -> { b | position : a } -> { b | position : a }
setPosition value model =
    { model | position = value }


setDirection : a -> { b | direction : a } -> { b | direction : a }
setDirection value model =
    { model | direction = value }


setCurrentHealth : a -> { b | currentHealth : a } -> { b | currentHealth : a }
setCurrentHealth value model =
    { model | currentHealth = value }


setMaxHealth : a -> { b | maxHealth : a } -> { b | maxHealth : a }
setMaxHealth value model =
    { model | maxHealth = value }


setDebuffs : a -> { b | debuffs : a } -> { b | debuffs : a }
setDebuffs value model =
    { model | debuffs = value }


setGuid : a -> { b | guid : a } -> { b | guid : a }
setGuid value model =
    { model | guid = value }


setTargetGuid : a -> { b | targetGuid : a } -> { b | targetGuid : a }
setTargetGuid value model =
    { model | targetGuid = value }


setType_ : a -> { b | type_ : a } -> { b | type_ : a }
setType_ value model =
    { model | type_ = value }


setIsSpirit : a -> { b | isSpirit : a } -> { b | isSpirit : a }
setIsSpirit value model =
    { model | isSpirit = value }


setShieldWallActive : a -> { b | shieldWallActive : a } -> { b | shieldWallActive : a }
setShieldWallActive value model =
    { model | shieldWallActive = value }


setPlayerName : a -> { b | playerName : a } -> { b | playerName : a }
setPlayerName value model =
    { model | playerName = value }


setGuidTarget : a -> { b | guidTarget : a } -> { b | guidTarget : a }
setGuidTarget value model =
    { model | guidTarget = value }


setPlayerJoin : a -> { b | playerJoin : a } -> { b | playerJoin : a }
setPlayerJoin value model =
    { model | playerJoin = value }


setPlayerMove : a -> { b | playerMove : a } -> { b | playerMove : a }
setPlayerMove value model =
    { model | playerMove = value }


setPlayerDirection : a -> { b | playerDirection : a } -> { b | playerDirection : a }
setPlayerDirection value model =
    { model | playerDirection = value }


setPlayerGuidAffected : a -> { b | playerGuidAffected : a } -> { b | playerGuidAffected : a }
setPlayerGuidAffected value model =
    { model | playerGuidAffected = value }


setAssignedPlayerId : a -> { b | assignedPlayerId : a } -> { b | assignedPlayerId : a }
setAssignedPlayerId value model =
    { model | assignedPlayerId = value }


setBulkPlayerUpdate : a -> { b | bulkPlayerUpdate : a } -> { b | bulkPlayerUpdate : a }
setBulkPlayerUpdate value model =
    { model | bulkPlayerUpdate = value }


setBulkBossUpdate : a -> { b | bulkBossUpdate : a } -> { b | bulkBossUpdate : a }
setBulkBossUpdate value model =
    { model | bulkBossUpdate = value }


setBossAbilityPerformed : a -> { b | bossAbilityPerformed : a } -> { b | bossAbilityPerformed : a }
setBossAbilityPerformed value model =
    { model | bossAbilityPerformed = value }
