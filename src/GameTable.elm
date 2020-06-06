module GameTable exposing (Model, Msg, initState, update, view)

import Html exposing (..)
import Html.Events exposing (..)


type alias Model =
    { state : State }


type State
    = Q0
    | Q1
    | Q2
    | Q3
    | Q4
    | Q5
    | Q6
    | Q0_passive
    | QError


initState : Model
initState =
    { state = Q0 }


type Msg
    = NoOp
    | GoActive
    | GoPassive


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case ( model.state, msg ) of
        ( Q0, GoActive ) ->
            ( { model | state = Q0 }, Cmd.none )

        ( Q0, GoPassive ) ->
            ( { model | state = Q0_passive }, Cmd.none )

        ( Q0_passive, GoActive ) ->
            ( { model | state = Q0 }, Cmd.none )

        ( Q0_passive, GoPassive ) ->
            ( { model | state = Q0_passive }, Cmd.none )

        _ ->
            ( { model | state = QError }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ viewGameTable model.state
        , button [ onClick GoPassive ] [ text "Go passive" ]
        , button [ onClick GoActive ] [ text "Go active" ]
        ]


viewGameTable : State -> Html msg
viewGameTable state =
    case state of
        Q0 ->
            viewStateQ0

        Q0_passive ->
            viewStateQ0_passive

        QError ->
            viewStateQError

        _ ->
            viewNotImplemented


viewStateQ0 : Html msg
viewStateQ0 =
    div []
        [ text "All five camels are sleeping and you have to wake them up. Roll the dices until they arent asleep anymore. Please, hurry up! Other players are waiting for you :)"
        , hr [] []
        , button [] [ text "Roll dice" ]
        ]


viewStateQ0_passive : Html msg
viewStateQ0_passive =
    div []
        [ text "Other player is waking up the camels. Please, have a little patience"
        ]


viewStateQError : Html msg
viewStateQError =
    div [] [ text "Error state reached inside GameTable" ]


viewNotImplemented : Html msg
viewNotImplemented =
    div [] [ text "View not implemented" ]
