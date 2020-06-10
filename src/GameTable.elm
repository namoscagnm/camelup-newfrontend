module GameTable exposing (Model, Msg, initState, update, view)

import Html exposing (..)
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
    div []
        [ viewGameTable model.state
        , hr [] []
        , p [] [ text "Switch role" ]
        , button [ onClick GoPassive ] [ text "Go passive" ]
        , button [ onClick GoActive ] [ text "Go active" ]
        ]


viewGameTable : State -> Html Msg
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


viewStateQ0 : Html Msg
viewStateQ0 =
    div []
        [ text "All five camels are sleeping and you have to wake them up. Roll the dices until they arent asleep anymore. Please, hurry up! Other players are waiting for you :)"
        , hr [] []
        , p [] [ text "Simulate user command" ]
        , button [ onClick Warmup ] [ text "Warm a camel up" ]
        , hr [] []
        , p [] [ text "Simulate a server command" ]
        , button [ onClick Start ] [ text "Start" ]
        ]


viewStateQ0_passive : Html msg
viewStateQ0_passive =
    div []
        [ text "Other player is waking up the camels. Please, have a little patience"
        ]


viewStateQ1 : Html Msg
viewStateQ1 =
    div []
        [ text "You can now get a point by shaking the dice, or get no points now and try to bet in a camel for the current leg, or put a mirage tile to annoy other camels and get some money if they fall there. You can also put a oasis tile to help some camel (you also get a point if he lands there), or bet on the final winner or looser"
        , hr [] []
        , p [] [ text "Simulate a server command" ]
        , button [ onClick LastDiceThrown ] [ text "Leg finished" ]
        , button [ onClick FinishedRace ] [ text "Finish race" ]
        ]


viewStateQ2 : Html Msg
viewStateQ2 =
    div []
        [ text "That was an amazing race and you can now get money for your bets on the previous leg!"
        , hr [] []
        , p [] [ text "Simulate server command:" ]
        , button [ onClick GotLegMoney ] [ text "Got leg money" ]
        ]


viewStateQ3 : Html Msg
viewStateQ3 =
    div []
        [ text "You got some money, but now as I said its time go get much more!! Who bet corretly on the first winner? Better yet, who was the FIRST to bet correctly? You can get up to 8 points if you were the earliest lucky one!"
        , hr [] []
        , p [] [ text "Simulate server command:" ]
        , button [ onClick GotFinalWinnerMoney ] [ text "Got final winner money" ]
        ]


viewStateQ4 : Html Msg
viewStateQ4 =
    div []
        [ text "Maybe you got money,maybe you didnt. But as far as good news go, you have yet one chance more! Because betting on the final looser can also give you great mone!"
        , hr [] []
        , p [] [ text "Simulate server command:" ]
        , button [ onClick GotFinalLooserMoney ] [ text "Got final looser money" ]
        ]


viewStateQ5 : Html Msg
viewStateQ5 =
    div []
        [ text "Ha!! Great game, isnt it? I hope you enjoyed! Tell to your friends about it and see you next time!"
        ]


viewStateQ6 : Html Msg
viewStateQ6 =
    div []
        [ text "After many ups and downs, the race is finally finished! After collecing this legs money, bigger prizes are to come! If you got the final winner or final looser right, your pocket will leave you feeling you carry a stone of gold :)"
        , hr [] []
        , p [] [ text "Simulate server command:" ]
        , button [ onClick GotLegMoney ] [ text "Got leg money" ]
        ]


viewStateQError : Html msg
viewStateQError =
    div [] [ text "Error state reached inside GameTable" ]


viewNotImplemented : Html msg
viewNotImplemented =
    div [] [ text "View not implemented" ]
