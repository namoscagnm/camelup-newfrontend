module Main exposing (..)

import Browser
import GameTable exposing (decodeGameTable)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (..)
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

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ Html.map Workflow
            (Workflow.view model.workflowState)
        ]



---- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        _ =
            Debug.log "Inside sub of man " 1
    in
    Sub.map Workflow (Workflow.subscriptions model.workflowState)



---- PORTS ----
---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
