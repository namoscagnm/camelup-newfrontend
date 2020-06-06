module Main exposing (..)

import Browser
import FEState exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)



---- MODEL ----


type alias Model =
    { workflowState : FEState.Model }


init : ( Model, Cmd Msg )
init =
    ( { workflowState = FEState.initState }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | FEState FEState.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FEState feStateMsg ->
            let
                ( workflowState, newcmd ) =
                    FEState.update model.workflowState feStateMsg
            in
            ( { model | workflowState = workflowState }, Cmd.map FEState newcmd )

        _ ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.map FEState
        (FEState.view model.workflowState)



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
