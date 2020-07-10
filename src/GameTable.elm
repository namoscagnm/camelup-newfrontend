module GameTable exposing (Model, Msg, encodeGameTable, initState, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Input as Input
import Html exposing (Html)
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
    , bigWinnerBets : List String
    , bigLooserBets : List String
    }


type alias MenuState =
    { showStateDesc : Bool }


initState : Model
initState =
    { menuState = { showStateDesc = False }
    , gameTable =
        { state = Q0
        , circuit =
            [ { position = "6", items = "mirage from gustavo" }
            , { position = "4", items = "black, blue, green, yellow, orange" }
            , { position = "3", items = "oasis from paula" }
            ]
        , playerStatuses =
            [ { name = "Marina"
              , money = 5
              , legBets = [ { color = "green", value = 5 } ]
              }
            , { name = "Joao"
              , money = 4
              , legBets =
                    [ { color = "blue", value = 5 }
                    , { color = "green", value = 3 }
                    ]
              }
            ]
        , previousDices = [ "blue", "green", "red", "black" ]
        , avaiableLegBets = [ { color = "blue", value = 5 }, { color = "orange", value = 3 } ]
        , personalItems =
            { tiles =
                [ "Oasis", "Mirage" ]
            , bigWinnerBets = [ "black", "blue", "green", "orange" ]
            , bigLooserBets = [ "blue", "green", "orange" ]
            }
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
            ( { model | gameTable = newGameTableState Q0 }, Cmd.none )

        ( Q0, Start ) ->
            ( { model | gameTable = newGameTableState Q1 }, Cmd.none )

        ( Q1, LastDiceThrown ) ->
            ( { model | gameTable = newGameTableState Q2 }, Cmd.none )

        ( Q1, FinishedRace ) ->
            ( { model | gameTable = newGameTableState Q6 }, Cmd.none )

        ( Q0_passive, GoActive ) ->
            ( { model | gameTable = newGameTableState Q0 }, Cmd.none )

        ( Q0_passive, GoPassive ) ->
            ( { model | gameTable = newGameTableState Q0_passive }, Cmd.none )

        ( Q2, GotLegMoney ) ->
            ( { model | gameTable = newGameTableState Q1 }, Cmd.none )

        ( Q2, FinishedRace ) ->
            ( { model | gameTable = newGameTableState Q6 }, Cmd.none )

        ( Q3, GotFinalWinnerMoney ) ->
            ( { model | gameTable = newGameTableState Q4 }, Cmd.none )

        ( Q4, GotFinalLooserMoney ) ->
            ( { model | gameTable = newGameTableState Q5 }, Cmd.none )

        ( Q6, GotLegMoney ) ->
            ( { model | gameTable = newGameTableState Q3 }, Cmd.none )

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
        , Element.paragraph [] [ text "--- Simulate user command ---" ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just Warmup
            , label = el [] <| text "Warm camel up"
            }
        , paragraph [] [ text "--- Simulate a server command ---" ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just Start
            , label = el [] <| text "Start"
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
                        \person -> Element.text person.items
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
        , column [ width fill ]
            [ paragraph [] [ text "--- Simulate a server command ---" ]
            , Input.button
                [ Background.color (rgb255 0 255 0)
                ]
                { onPress = Just LastDiceThrown
                , label = el [] <| text "Leg finished"
                }
            , Input.button
                [ Background.color (rgb255 0 255 0)
                ]
                { onPress = Just FinishedRace
                , label = el [] <| text "Finish race"
                }
            ]
        ]


viewGlobalItems : List LegBet -> Element msg
viewGlobalItems avaiableLegBets =
    let
        betButton currentBet =
            Input.button []
                { onPress = Nothing
                , label = text (currentBet.color ++ "/" ++ String.fromInt currentBet.value ++ ", ")
                }

        allBetButtons =
            List.map betButton avaiableLegBets
    in
    column [ width fill ]
        [ paragraph [] [ text "--- Items avaiable to all ---" ]
        , paragraph [] [ text "Pyramid" ]
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

        bigWinnerBetsText =
            String.join "," personalItems.bigWinnerBets

        bigLooserBetsText =
            String.join "," personalItems.bigLooserBets
    in
    column [ width fill ]
        [ paragraph [] [ text "-- Items avaiable to you ---" ]
        , paragraph [] [ text ("Tiles: " ++ tilesText) ]
        , paragraph [] [ text ("Big winner bets: " ++ bigWinnerBetsText) ]
        , paragraph [] [ text ("Big looser bets: " ++ bigLooserBetsText) ]
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
        , paragraph [] [ text "Simulate an server command" ]
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
        , paragraph [] [ text "Simulate an server command" ]
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
        , paragraph [] [ text "Simulate an server command" ]
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
        , paragraph [] [ text "Simulate an server command" ]
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


encodeLegBet : LegBet -> Json.Encode.Value
encodeLegBet legBet =
    Json.Encode.object
        [ ( "color", Json.Encode.string legBet.color )
        , ( "value", Json.Encode.int legBet.value )
        ]


encodePlayerStatus : PlayerStatus -> Json.Encode.Value
encodePlayerStatus playerStatus =
    Json.Encode.object
        [ ( "name", Json.Encode.string playerStatus.name )
        , ( "money", Json.Encode.int playerStatus.money )
        , ( "bets", Json.Encode.list encodeLegBet playerStatus.legBets )
        ]


encodePreviousDices : List String -> Json.Encode.Value
encodePreviousDices previousDices =
    Json.Encode.list Json.Encode.string previousDices


encodePersonalItems : PersonalItems -> Json.Encode.Value
encodePersonalItems personalItems =
    Json.Encode.object
        [ ( "tiles", Json.Encode.list Json.Encode.string personalItems.tiles )
        , ( "bigWinnerBets", Json.Encode.list Json.Encode.string personalItems.bigWinnerBets )
        , ( "bigLooserBets", Json.Encode.list Json.Encode.string personalItems.bigLooserBets )
        ]


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
