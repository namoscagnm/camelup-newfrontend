module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)



---- MODEL ----


type alias Model =
    { workflowState : FEState }


init : ( Model, Cmd Msg )
init =
    ( { workflowState = initState }, Cmd.none )



---- UPDATE ----


initState : FEState
initState =
    Q0 { name = "Yourname", totalPlayers = 0 }


type alias Q0Content =
    { name : String, totalPlayers : Int }


type alias Q1Content =
    { char : GameChar, playersOnTable : Int }


type GameChar
    = PurpleWoman
    | GreenMan


type FEState
    = Q0 Q0Content
    | Q1 Q1Content
    | Q2
    | Q3
    | QError


type FEAlphabet
    = Enter
    | StartAndLock
    | ShowRules
    | Resume
    | Restart


feTransition : FEState -> FEAlphabet -> FEState
feTransition state alphabet =
    case ( state, alphabet ) of
        ( Q0 _, Enter ) ->
            Q1 { char = PurpleWoman, playersOnTable = 0 }

        ( Q1 _, StartAndLock ) ->
            Q2

        ( Q2, ShowRules ) ->
            Q3

        ( Q2, Restart ) ->
            Q3

        ( Q3, Resume ) ->
            Q2

        _ ->
            QError


viewStateQ0 : Q0Content -> Html Msg
viewStateQ0 content =
    div []
        [ text ("Your current name:" ++ content.name)
        , p [] [ text ("current global players: " ++ String.fromInt content.totalPlayers) ]
        , button [] [ text "Join free table" ]
        ]


viewFEState : FEState -> Html Msg
viewFEState state =
    case state of
        Q0 q0Content ->
            viewStateQ0 q0Content

        _ ->
            viewError


viewError : Html Msg
viewError =
    text "FSM transition error"


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    viewFEState model.workflowState



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }