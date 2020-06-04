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
                newmodel =
                    { model | workflowState = FEState.feTransition model.workflowState feStateMsg }
            in
            ( newmodel, Cmd.none )

        _ ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.map FEState
        (viewFEState model.workflowState)



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
