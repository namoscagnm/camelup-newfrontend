module GameTable exposing (Model, Msg, initState, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Input as Input
import Html exposing (Html)


type alias Model =
    { state : State, menuState : MenuState, gameTable : GameTable }


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
    { circuit : List CircuitItem, playerStatuses : List PlayerStatus }


type CamelColor
    = Black
    | Blue
    | Green
    | Orange
    | Red


type DesertTile
    = Mirage
    | Oasis


type Decision
    = Pyramid
    | BetOnLegWinner CamelColor
    | BetOnBiggestLooser CamelColor
    | BetOnBiggestWinner CamelColor
    | PutTile DesertTile Int


type alias MenuState =
    { showStateDesc : Bool }


initState : Model
initState =
    { state = Q0
    , menuState = { showStateDesc = False }
    , gameTable =
        { circuit =
            [ { position = "6", items = "mirage from gustavo" }
            , { position = "4", items = "black, blue, green, yellow, orange" }
            , { position = "3", items = "oasis from paula" }
            ]
        , playerStatuses =
            [ { name = "Marina"
              , money = 5
              , bets = [ { color = "green", value = 5 } ]
              }
            , { name = "Joao"
              , money = 4
              , bets =
                    [ { color = "blue", value = 5 }
                    , { color = "green", value = 3 }
                    ]
              }
            ]
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
    case ( model.state, msg ) of
        ( Q0, GoActive ) ->
            ( { model | state = Q0 }, Cmd.none )

        ( Q0, GoPassive ) ->
            ( { model | state = Q0_passive }, Cmd.none )

        ( Q0, Warmup ) ->
            ( { model | state = Q0 }, Cmd.none )

        ( Q0, Start ) ->
            ( { model | state = Q1 }, Cmd.none )

        ( Q1, LastDiceThrown ) ->
            ( { model | state = Q2 }, Cmd.none )

        ( Q1, FinishedRace ) ->
            ( { model | state = Q6 }, Cmd.none )

        ( Q0_passive, GoActive ) ->
            ( { model | state = Q0 }, Cmd.none )

        ( Q0_passive, GoPassive ) ->
            ( { model | state = Q0_passive }, Cmd.none )

        ( Q2, GotLegMoney ) ->
            ( { model | state = Q1 }, Cmd.none )

        ( Q2, FinishedRace ) ->
            ( { model | state = Q6 }, Cmd.none )

        ( Q3, GotFinalWinnerMoney ) ->
            ( { model | state = Q4 }, Cmd.none )

        ( Q4, GotFinalLooserMoney ) ->
            ( { model | state = Q5 }, Cmd.none )

        ( Q6, GotLegMoney ) ->
            ( { model | state = Q3 }, Cmd.none )

        _ ->
            ( { model | state = QError }, Cmd.none )


view : Model -> Html Msg
view model =
    layout [] <|
        column []
            [ viewGameTable model.state model.menuState model.gameTable.circuit
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


type alias PlayerStatus =
    { name : String, money : Int, bets : List { color : String, value : Int } }


viewStatus : List PlayerStatus -> Element msg
viewStatus playerStatus =
    Element.column [ width fill ]
        [ paragraph [] [ text "--- Status view ---" ]
        , Element.table []
            { data = playerStatus
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


viewGameTable : State -> MenuState -> List CircuitItem -> Element Msg
viewGameTable state menuState circuitItems =
    case state of
        --Camels are sleeping and have to be woken up
        Q0 ->
            viewStateQ0 menuState circuitItems

        Q0_passive ->
            viewStateQ0_passive

        -- Typical game flow
        Q1 ->
            viewStateQ1 menuState circuitItems

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


viewStateQ1 : MenuState -> List CircuitItem -> Element Msg
viewStateQ1 menuState circuitItems =
    Element.column [ spacingXY 0 10, width fill ]
        [ viewStateDescription menuState.showStateDesc "Q1: You can now get a point by shaking the dice, or get no points now and try to bet in a camel for the current leg, or put a mirage tile to annoy other camels and get some money if they fall there. You can also put a oasis tile to help some camel (you also get a point if he lands there), or bet on the final winner or looser"
        , viewCircuit circuitItems
        , viewDiceRecord
        , viewGlobalItems
        , viewPersonalItems
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


viewGlobalItems : Element msg
viewGlobalItems =
    column [ width fill ]
        [ paragraph [] [ text "--- Items avaiable to all ---" ]
        , paragraph [] [ text "Pyramid" ]
        , paragraph [] [ text "Bets on leg winners: black/5, blue/3, green/5, orange/2, red/5" ]
        ]


viewPersonalItems : Element msg
viewPersonalItems =
    column [ width fill ]
        [ paragraph [] [ text "-- Items avaiable to you ---" ]
        , paragraph [] [ text "Tiles: Oasis, mirage" ]
        , paragraph [] [ text "Big winner bets: black, blue, green, orange, red" ]
        , paragraph [] [ text "Big looser bets: black, blue, green, orange, red" ]
        ]


viewDiceRecord : Element msg
viewDiceRecord =
    column [ width fill ]
        [ paragraph [] [ text "--- Camels already moved on this leg ---" ]
        , paragraph [] [ text "blue, green, red" ]
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
