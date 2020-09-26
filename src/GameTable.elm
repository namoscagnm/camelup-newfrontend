port module GameTable exposing (Model, Msg, decodeGameTable, encodeGameTable, initState, sampleGameTable, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Input as Input
import Html exposing (Html)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (required)
import Json.Encode exposing (..)
import List exposing (..)


type alias Model =
    { menuState : MenuState, gameTable : GameTable }


type State
    = Q0
    | Q0_passive
    | Q1
    | Q2
    | Q4
    | Q5
    | Q6
    | Q3
    | QError


type alias GameTable =
    { state : State
    , circuit : List CircuitItem
    , playerStatuses : List PlayerStatus
    , previousDices : List String
    , avaiableLegBets : List LegBet
    , personalItems : PersonalItems
    }


type alias PlayerStatus =
    { name : String, money : Int, legBets : List LegBet }


type alias LegBet =
    { color : String, value : Int }


type alias PersonalItems =
    { tiles : List String
    , finalLegBets : List String
    }


type alias MenuState =
    { showStateDesc : Bool }


initState : Model
initState =
    { menuState = { showStateDesc = False }
    , gameTable = sampleGameTable
    }


sampleGameTable : GameTable
sampleGameTable =
    { state = Q1
    , circuit =
        [ { position = "9", items = "green" }
        , { position = "7", items = "black" }
        , { position = "5", items = "orange, red" }
        , { position = "2", items = "blue" }
        ]
    , playerStatuses =
        [ { name = "ana"
          , money = 1
          , legBets = [ { color = "black", value = 5 } ]
          }
        , { name = "bob"
          , money = 1
          , legBets = []
          }
        , { name = "charlie"
          , money = 3
          , legBets = [ { color = "green", value = 5 } ]
          }
        ]
    , previousDices = [ "green", "black" ]
    , avaiableLegBets = [ { color = "black", value = 3 }, { color = "blue", value = 5 }, { color = "green", value = 3 }, { color = "orange", value = 5 }, { color = "red", value = 5 } ]
    , personalItems =
        { tiles =
            [ "Oasis", "Mirage" ]
        , finalLegBets = [ "black", "green", "orange", "red" ]
        }
    }


type Msg
    = NoOp
    | GoActive
    | GoPassive
    | Warmup
    | Start
    | GotLegMoney
    | LastDiceThrown
    | FinishedRace
    | GotFinalWinnerMoney
    | GotFinalLooserMoney
    | UsePyramid
    | SendBet LegBet


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    let
        oldGameTable =
            model.gameTable

        newGameTableState newState =
            { oldGameTable | state = newState }
    in
    case ( model.gameTable.state, msg ) of
        ( Q0, GoActive ) ->
            ( { model | gameTable = newGameTableState Q0 }, Cmd.none )

        ( Q0, GoPassive ) ->
            ( { model | gameTable = newGameTableState Q0_passive }, Cmd.none )

        ( Q0, Warmup ) ->
            ( { model | gameTable = newGameTableState Q0 }, sendDecision { first = "warmup", second = Nothing, third = Nothing } )

        ( Q0, Start ) ->
            ( { model | gameTable = newGameTableState Q1 }, sendDecision { first = "start", second = Nothing, third = Nothing } )

        ( Q1, SendBet legBet ) ->
            ( model, sendDecision { first = "bet_on_leg", second = Just legBet.color, third = Nothing } )

        ( Q1, UsePyramid ) ->
            ( model, sendDecision { first = "shake", second = Nothing, third = Nothing } )

        ( Q1, LastDiceThrown ) ->
            ( { model | gameTable = newGameTableState Q2 }, Cmd.none )

        ( Q1, FinishedRace ) ->
            ( { model | gameTable = newGameTableState Q6 }, Cmd.none )

        ( Q0_passive, GoActive ) ->
            ( { model | gameTable = newGameTableState Q0 }, Cmd.none )

        ( Q0_passive, GoPassive ) ->
            ( { model | gameTable = newGameTableState Q0_passive }, Cmd.none )

        ( Q2, GotLegMoney ) ->
            ( model, sendDecision { first = "get_leg_money", second = Nothing, third = Nothing } )

        ( Q2, FinishedRace ) ->
            ( { model | gameTable = newGameTableState Q6 }, Cmd.none )

        ( Q3, GotFinalWinnerMoney ) ->
            ( model, sendDecision { first = "get_final_winner_money", second = Nothing, third = Nothing } )

        ( Q4, GotFinalLooserMoney ) ->
            ( model, sendDecision { first = "get_final_looser_money", second = Nothing, third = Nothing } )

        ( Q6, GotLegMoney ) ->
            ( model, sendDecision { first = "get_leg_money", second = Nothing, third = Nothing } )

        _ ->
            ( { model | gameTable = newGameTableState QError }, Cmd.none )


view : Model -> Html Msg
view model =
    layout [] <|
        column []
            [ viewGameTable model.gameTable.state model.menuState model.gameTable.circuit model.gameTable.previousDices model.gameTable.avaiableLegBets model.gameTable.personalItems
            , viewStatus model.gameTable.playerStatuses
            ]



{--
    div []
        [ viewGameTable model.state
        , hr [] []
        , p [] [ text "Switch role" ]
        , button [ onClick GoPassive ] [ text "Go passive" ]
        , button [ onClick GoActive ] [ text "Go active" ]
        ]
        --}


viewStatus : List PlayerStatus -> Element msg
viewStatus playerStatuses =
    Element.column [ width fill ]
        [ paragraph [] [ text "--- Status view ---" ]
        , Element.table []
            { data = playerStatuses
            , columns =
                [ { header = Element.text "Name"
                  , width = fill
                  , view =
                        \person ->
                            Element.text person.name
                  }
                , { header = Element.text "Money"
                  , width = fill
                  , view =
                        \person -> Element.text (String.fromInt person.money)
                  }
                , { header = Element.text "Bets"
                  , width = fill
                  , view =
                        \person -> Element.text "TBD"
                  }
                ]
            }
        ]


viewGameTable : State -> MenuState -> List CircuitItem -> List String -> List LegBet -> PersonalItems -> Element Msg
viewGameTable state menuState circuitItems previousDices avaiableLegBets personalItems =
    case state of
        --Camels are sleeping and have to be woken up
        Q0 ->
            viewStateQ0 menuState circuitItems

        Q0_passive ->
            viewStateQ0_passive

        -- Typical game flow
        Q1 ->
            viewStateQ1 menuState circuitItems previousDices avaiableLegBets personalItems

        Q2 ->
            viewStateQ2

        Q3 ->
            viewStateQ3

        Q4 ->
            viewStateQ4

        Q5 ->
            viewStateQ5

        Q6 ->
            viewStateQ6

        QError ->
            viewStateQError



{--_ ->
            viewNotImplemented
--}


viewStateQ0 : MenuState -> List CircuitItem -> Element Msg
viewStateQ0 menuState circuitItems =
    Element.column [ width fill ]
        [ viewStateDescription menuState.showStateDesc "Q0: All five camels are sleeping and you have to wake them up. Roll the dices until they arent asleep anymore. Please, hurry up! Other players are waiting for you :)"
        , viewCircuit circuitItems
        , Element.paragraph [] [ text "--- User command ---" ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just Warmup
            , label = el [] <| text "Warm camel up"
            }
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just Start
            , label = el [] <| text "Start race!"
            }
        ]


type alias CircuitItem =
    { position : String, items : String }


viewCircuit : List CircuitItem -> Element msg
viewCircuit circuitItems =
    Element.column []
        [ paragraph [] [ text "--- Circuit view---" ]
        , Element.table []
            { data = circuitItems
            , columns =
                [ { header = Element.text "Position"
                  , width = fill
                  , view =
                        \person ->
                            Element.text person.position
                  }
                , { header = Element.text "Items"
                  , width = fill
                  , view =
                        \person -> paragraph [] [ el [ alignRight ] (Element.text (person.items ++ "|ground")) ]
                  }
                ]
            }
        ]


viewStateQ0_passive : Element msg
viewStateQ0_passive =
    text "Workflow view Q0 passive"



{--div []
        [ text "Other player is waking up the camels. Please, have a little patience"
        ]
        --}


viewStateDescription : Bool -> String -> Element Msg
viewStateDescription isActive description =
    case isActive of
        False ->
            Element.paragraph []
                [ Element.text ""
                ]

        True ->
            Element.paragraph []
                [ Element.text description
                ]


viewStateQ1 : MenuState -> List CircuitItem -> List String -> List LegBet -> PersonalItems -> Element Msg
viewStateQ1 menuState circuitItems previousDices avaiableLegBets personalItems =
    Element.column [ spacingXY 0 10, width fill ]
        [ viewStateDescription menuState.showStateDesc "Q1: You can now get a point by shaking the dice, or get no points now and try to bet in a camel for the current leg, or put a mirage tile to annoy other camels and get some money if they fall there. You can also put a oasis tile to help some camel (you also get a point if he lands there), or bet on the final winner or looser"
        , viewCircuit circuitItems
        , viewDiceRecord previousDices
        , viewGlobalItems avaiableLegBets
        , viewPersonalItems personalItems
        ]


viewGlobalItems : List LegBet -> Element Msg
viewGlobalItems avaiableLegBets =
    let
        betButton currentBet =
            Input.button [ Background.color (rgb255 0 255 0) ]
                { onPress = Just (SendBet currentBet)
                , label = text (currentBet.color ++ "/" ++ String.fromInt currentBet.value ++ ", ")
                }

        allBetButtons =
            List.map betButton avaiableLegBets
    in
    column [ width fill ]
        [ paragraph [] [ text "--- Items avaiable to all ---" ]
        , Input.button [ Background.color (rgb255 0 255 0) ]
            { onPress = Just UsePyramid
            , label = el [] <| text "Pyramid"
            }
        , paragraph []
            ([ text "Bets on leg winners:"
             ]
                ++ allBetButtons
            )
        ]


viewPersonalItems : PersonalItems -> Element msg
viewPersonalItems personalItems =
    let
        tilesText =
            String.join "," personalItems.tiles

        finalLegBetsText =
            String.join "," personalItems.finalLegBets
    in
    column [ width fill ]
        [ paragraph [] [ text "-- Items avaiable to you ---" ]
        , paragraph [] [ text ("Tiles: " ++ tilesText) ]
        , paragraph [] [ text ("Big winner bets: " ++ finalLegBetsText) ]
        , paragraph [] [ text ("Big looser bets: " ++ finalLegBetsText) ]
        ]


viewDiceRecord : List String -> Element msg
viewDiceRecord previousDices =
    let
        myString =
            String.join "," previousDices
    in
    column [ width fill ]
        [ paragraph [] [ text "--- Camels already moved on this leg ---" ]
        , paragraph [] [ text myString ]
        ]


viewStateQ2 : Element Msg
viewStateQ2 =
    Element.column [ spacingXY 0 10 ]
        [ Element.paragraph []
            [ Element.text "Q2: That was an amazing race and you can now get money for your bets on the previous leg!"
            ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just GotLegMoney
            , label = el [] <| text "Got leg money"
            }
        ]


viewStateQ3 : Element Msg
viewStateQ3 =
    Element.column [ spacingXY 0 10 ]
        [ Element.paragraph []
            [ Element.text "Q3: You got some money, but now as I said its time go get much more!! Who bet corretly on the first winner? Better yet, who was the FIRST to bet correctly? You can get up to 8 points if you were the earliest lucky one!"
            ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just GotFinalWinnerMoney
            , label = el [] <| text "Got final winner money"
            }
        ]


viewStateQ4 : Element Msg
viewStateQ4 =
    Element.column [ spacingXY 0 10 ]
        [ Element.paragraph []
            [ Element.text "Q4: Maybe you got money,maybe you didnt. But as far as good news go, you have yet one chance more! Because betting on the final looser can also give you great mone!"
            ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just GotFinalLooserMoney
            , label = el [] <| text "Got final looser money"
            }
        ]


viewStateQ5 : Element Msg
viewStateQ5 =
    Element.column [ spacingXY 0 10 ]
        [ Element.paragraph []
            [ Element.text "Q5: Ha!! Great game, isnt it? I hope you enjoyed! Tell to your friends about it and see you next time!"
            ]
        ]


viewStateQ6 : Element Msg
viewStateQ6 =
    Element.column [ spacingXY 0 10 ]
        [ Element.paragraph []
            [ Element.text "Q6: After many ups and downs, the race is finally finished! After collecing this legs money, bigger prizes are to come! If you got the final winner or final looser right, your pocket will leave you feeling you carry a stone of gold :)"
            ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just GotLegMoney
            , label = el [] <| text "Got leg money"
            }
        ]


viewStateQError : Element msg
viewStateQError =
    text "Error state reached inside GameTable"


viewNotImplemented : Element msg
viewNotImplemented =
    text "View not implemented on workflow"


encodeCircuit : CircuitItem -> Json.Encode.Value
encodeCircuit circuitItem =
    Json.Encode.object
        [ ( "position", Json.Encode.string circuitItem.position )
        , ( "items", Json.Encode.string circuitItem.items )
        ]


decodeCircuit : Json.Decode.Decoder CircuitItem
decodeCircuit =
    Json.Decode.succeed CircuitItem
        |> Json.Decode.Pipeline.required "position" Json.Decode.string
        |> Json.Decode.Pipeline.required "items" Json.Decode.string


encodeLegBet : LegBet -> Json.Encode.Value
encodeLegBet legBet =
    Json.Encode.object
        [ ( "color", Json.Encode.string legBet.color )
        , ( "value", Json.Encode.int legBet.value )
        ]


decodeLegBet : Json.Decode.Decoder LegBet
decodeLegBet =
    Json.Decode.succeed LegBet
        |> Json.Decode.Pipeline.required "color" Json.Decode.string
        |> Json.Decode.Pipeline.required "value" Json.Decode.int


encodePlayerStatus : PlayerStatus -> Json.Encode.Value
encodePlayerStatus playerStatus =
    Json.Encode.object
        [ ( "name", Json.Encode.string playerStatus.name )
        , ( "money", Json.Encode.int playerStatus.money )
        , ( "bets", Json.Encode.list encodeLegBet playerStatus.legBets )
        ]


decodePlayerStatus : Json.Decode.Decoder PlayerStatus
decodePlayerStatus =
    Json.Decode.succeed PlayerStatus
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "money" Json.Decode.int
        |> Json.Decode.Pipeline.required "bets" (Json.Decode.list decodeLegBet)


encodePreviousDices : List String -> Json.Encode.Value
encodePreviousDices previousDices =
    Json.Encode.list Json.Encode.string previousDices


decodePreviousDices : Json.Decode.Decoder (List String)
decodePreviousDices =
    Json.Decode.list Json.Decode.string


encodePersonalItems : PersonalItems -> Json.Encode.Value
encodePersonalItems personalItems =
    Json.Encode.object
        [ ( "tiles", Json.Encode.list Json.Encode.string personalItems.tiles )
        , ( "finalLegBets", Json.Encode.list Json.Encode.string personalItems.finalLegBets )
        ]


decodePersonalItems : Json.Decode.Decoder PersonalItems
decodePersonalItems =
    Json.Decode.succeed PersonalItems
        |> Json.Decode.Pipeline.required "tiles" (Json.Decode.list Json.Decode.string)
        |> Json.Decode.Pipeline.required "finalLegBets" (Json.Decode.list Json.Decode.string)


encodeState : State -> Json.Encode.Value
encodeState state =
    let
        stateString =
            case state of
                Q0 ->
                    "q0"

                Q0_passive ->
                    "q0_passive"

                Q1 ->
                    "q1"

                Q2 ->
                    "q"

                Q3 ->
                    "q3"

                Q4 ->
                    "q4"

                Q5 ->
                    "q5"

                Q6 ->
                    "q6"

                QError ->
                    "qerror"
    in
    Json.Encode.string stateString


decodeState : Json.Decode.Decoder State
decodeState =
    let
        strToState : String -> State
        strToState str =
            case str of
                "q0" ->
                    Q0

                "q0_passive" ->
                    Q0_passive

                "q1" ->
                    Q1

                "q2" ->
                    Q2

                "q3" ->
                    Q3

                "q4" ->
                    Q4

                "q5" ->
                    Q5

                "q6" ->
                    Q6

                "qerror" ->
                    QError

                _ ->
                    QError
    in
    Json.Decode.map strToState Json.Decode.string


encodeGameTable : GameTable -> Json.Encode.Value
encodeGameTable gameTable =
    Json.Encode.object
        [ ( "state", encodeState gameTable.state )
        , ( "circuit", Json.Encode.list encodeCircuit gameTable.circuit )
        , ( "playerStatuses", Json.Encode.list encodePlayerStatus gameTable.playerStatuses )
        , ( "previousDices", encodePreviousDices gameTable.previousDices )
        , ( "avaiableLegBets", Json.Encode.list encodeLegBet gameTable.avaiableLegBets )
        , ( "personalItems", encodePersonalItems gameTable.personalItems )
        ]


decodeGameTable : Json.Decode.Decoder GameTable
decodeGameTable =
    Json.Decode.succeed GameTable
        |> Json.Decode.Pipeline.required "state" decodeState
        |> Json.Decode.Pipeline.required "circuit" (Json.Decode.list decodeCircuit)
        |> Json.Decode.Pipeline.required "playerStatuses" (Json.Decode.list decodePlayerStatus)
        |> Json.Decode.Pipeline.required "previousDices" decodePreviousDices
        |> Json.Decode.Pipeline.required "avaiableLegBets" (Json.Decode.list decodeLegBet)
        |> Json.Decode.Pipeline.required "personalItems" decodePersonalItems



---- PORTS ----


type alias Decision =
    { first : String, second : Maybe String, third : Maybe Int }


port sendDecision : Decision -> Cmd msg
