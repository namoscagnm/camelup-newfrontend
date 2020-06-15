module GameTable exposing (Model, Msg, initState, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Html exposing (Html)
import Html.Events exposing (..)


type alias Model =
    { state : State }


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


initState : Model
initState =
    { state = Q0 }


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
            [ viewGameTable model.state
            , showStatus
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


showStatus : Element Msg
showStatus =
    column []
        [ paragraph [] [ text "Marina: 5 money, 5 on gren, 3 on blue" ]
        , paragraph [] [ text "Paulo: 5 money, 5 on gren, 3 on blue" ]
        , paragraph [] [ text "Sarra: 5 money, 5 on gren, 3 on blue" ]
        , paragraph [] [ text "Gustavo: 5 money, 5 on gren, 3 on blue" ]
        , paragraph [] [ text "Marua: 5 money, 5 on gren, 3 on blue" ]
        , paragraph [] [ text "Diego: 5 money, 5 on gren, 3 on blue" ]
        , paragraph [] [ text "Talita: 5 money, 5 on gren, 3 on blue" ]
        , paragraph [] [ text "Thiago: 5 money, 5 on gren, 3 on blue" ]
        ]


viewGameTable : State -> Element Msg
viewGameTable state =
    case state of
        Q0 ->
            viewStateQ0

        Q0_passive ->
            viewStateQ0_passive

        Q1 ->
            viewStateQ1

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


viewStateQ0 : Element Msg
viewStateQ0 =
    Element.column [ width fill ]
        [ Element.paragraph []
            [ Element.text "Q0: All five camels are sleeping and you have to wake them up. Roll the dices until they arent asleep anymore. Please, hurry up! Other players are waiting for you :)"
            ]
        , Element.paragraph [] [ text "Simulate user command" ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just Warmup
            , label = el [] <| text "Warm camel up"
            }
        , paragraph [] [ text "Simulate a server command" ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Just Start
            , label = el [] <| text "Start"
            }
        ]


viewStateQ0_passive : Element msg
viewStateQ0_passive =
    text "Workflow view Q0 passive"



{--div []
        [ text "Other player is waking up the camels. Please, have a little patience"
        ]
        --}


viewStateQ1 : Element Msg
viewStateQ1 =
    Element.column [ spacingXY 0 10 ]
        [ Element.paragraph []
            [ Element.text "Q1: You can now get a point by shaking the dice, or get no points now and try to bet in a camel for the current leg, or put a mirage tile to annoy other camels and get some money if they fall there. You can also put a oasis tile to help some camel (you also get a point if he lands there), or bet on the final winner or looser"
            ]
        , paragraph [] [ text "Simulate an user command" ]
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Nothing
            , label = el [] <| text "Shake a dice"
            }
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Nothing
            , label = el [] <| text "Put a desert tile"
            }
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Nothing
            , label = el [] <| text "Bet on legs winner"
            }
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Nothing
            , label = el [] <| text "Bet on final winner"
            }
        , Input.button
            [ Background.color (rgb255 0 255 0)
            ]
            { onPress = Nothing
            , label = el [] <| text "Bet on final looser"
            }
        , paragraph [] [ text "Simulate a server command" ]
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
