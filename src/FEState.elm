module FEState exposing (Model, Msg, feTransition, initState, viewFEState)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


initState : Model
initState =
    Q0 { name = "Yourname", totalPlayers = 0 }


type alias Q0Content =
    { name : String, totalPlayers : Int }


type alias Q1Content =
    { char : GameChar, playersOnTable : Int, otherChars : List GameChar }


type alias Q2Content =
    { text : String }


type GameChar
    = PurpleWoman
    | GreenMan
    | BrownMan


gameCharToString : GameChar -> String
gameCharToString char =
    case char of
        PurpleWoman ->
            "Purple woman"

        GreenMan ->
            "Green man"

        BrownMan ->
            "Brown man"


type Model
    = Q0 Q0Content
    | Q1 Q1Content
    | Q2 Q2Content
    | Q3
    | QError


type Msg
    = JoinTable
    | StartAndLock
    | ShowRules
    | Resume


feTransition : Model -> Msg -> Model
feTransition state alphabet =
    case ( state, alphabet ) of
        ( Q0 _, JoinTable ) ->
            Q1 { char = PurpleWoman, playersOnTable = 0, otherChars = [ GreenMan, BrownMan ] }

        ( Q1 _, StartAndLock ) ->
            Q2 { text = "You are now playing the game" }

        ( Q2 _, ShowRules ) ->
            Q3

        ( Q3, Resume ) ->
            Q2 { text = "Manual read, playing again" }

        _ ->
            QError


viewStateQ0 : Q0Content -> Html Msg
viewStateQ0 content =
    div []
        [ text ("Your current name:" ++ content.name)
        , p [] [ text ("current global players: " ++ String.fromInt content.totalPlayers) ]
        , button [ onClick JoinTable ] [ text "Join free table" ]
        ]


viewStateQ1 : Q1Content -> Html Msg
viewStateQ1 content =
    div []
        [ text ("Your current char:" ++ gameCharToString content.char)
        , p [] [ text ("current table players: " ++ String.fromInt content.playersOnTable) ]
        , p [] [ text "Other characters in this room:" ]
        , p [] [ text (List.foldl (\x y -> gameCharToString x ++ " | " ++ y) "" content.otherChars) ]
        , button [ onClick StartAndLock ] [ text "Ask to start and lock table" ]
        ]


viewStateQ2 : Q2Content -> Html Msg
viewStateQ2 content =
    div []
        [ text content.text
        , button [ onClick ShowRules ] [ text "See game rules" ]
        ]


viewStateQ3 : Html Msg
viewStateQ3 =
    div []
        [ text "You are seeing the game rules"
        , button [ onClick Resume ] [ text "Go back to game" ]
        ]


viewFEState : Model -> Html Msg
viewFEState state =
    case state of
        Q0 q0Content ->
            viewStateQ0 q0Content

        Q1 q1Content ->
            viewStateQ1 q1Content

        Q2 q2Content ->
            viewStateQ2 q2Content

        Q3 ->
            viewStateQ3

        QError ->
            viewError


viewNotImplemented : Html Msg
viewNotImplemented =
    text "View not implemented"


viewError : Html Msg
viewError =
    text "State transition error"
