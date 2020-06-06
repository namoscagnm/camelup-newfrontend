module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Workflow exposing (..)



---- MODEL ----


type alias Model =
    { workflowState : Workflow.Model }


init : ( Model, Cmd Msg )
init =
    ( { workflowState = Workflow.initState }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Workflow Workflow.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Workflow workFlowMsg ->
            let
                ( workflowState, newcmd ) =
                    Workflow.update model.workflowState workFlowMsg
            in
            ( { model | workflowState = workflowState }, Cmd.map Workflow newcmd )

        _ ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.map Workflow
        (Workflow.view model.workflowState)



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
