port module Workflow exposing (Model, Msg, initState, subscriptions, update, view)

import GameTable exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode exposing (..)
import Json.Encode exposing (..)


initState : Model
initState =
    Q0 { name = "Yourname", totalPlayers = 0 }


type alias Q0Content =
    { name : String, totalPlayers : Int }


type alias Q1Content =
    { char : GameChar, playersOnTable : Int, otherChars : List GameChar }


type alias Q2Content =
    { text : String, gameTable : Maybe GameTable.Model }


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
    | GameTable GameTable.Msg
    | ConnectToRoom String
    | ReceiveGameTableFromServer Json.Encode.Value


update : Model -> Msg -> ( Model, Cmd Msg )
update state alphabet =
    case ( state, alphabet ) of
        ( Q0 _, ConnectToRoom room ) ->
            ( state, joinRoom room )

        ( Q0 _, JoinTable ) ->
            ( Q1 { char = PurpleWoman, playersOnTable = 0, otherChars = [ GreenMan, BrownMan ] }, Cmd.none )

        ( Q1 _, StartAndLock ) ->
            ( Q2 { text = "Workflow state Q2 generic message: You are now playing the game", gameTable = Just GameTable.initState }, Cmd.none )

        ( Q1 _, ConnectToRoom room ) ->
            ( state, joinRoom room )

        ( _, ReceiveGameTableFromServer incomingData ) ->
            let
                _ =
                    Debug.log "Inside update q1 rgtfs" 3
            in
            case Json.Decode.decodeValue GameTable.decodeGameTable incomingData of
                Ok gt ->
                    let
                        gt_base =
                            GameTable.initState

                        gt_final =
                            { gt_base | gameTable = gt }
                    in
                    ( Q2 { text = "Looking into sucessful gt taken from server", gameTable = Just gt_final }, Cmd.none )

                Err msg ->
                    let
                        _ =
                            Debug.log "Error trying to get gametable:" msg
                    in
                    ( state, Cmd.none )

        ( Q2 _, ShowRules ) ->
            ( Q3, Cmd.none )

        ( Q2 q2Content, GameTable msggt ) ->
            case q2Content.gameTable of
                Just gameTable ->
                    let
                        ( newGameTable, cmd ) =
                            GameTable.update gameTable msggt

                        model =
                            Q2 { text = "Weird. FEState should be delegating this to GameTable,", gameTable = Just newGameTable }
                    in
                    ( model, Cmd.map GameTable cmd )

                Nothing ->
                    ( Q2 { text = "Dummy game table from FEState", gameTable = Nothing }, Cmd.none )

        ( Q3, Resume ) ->
            ( Q2 { text = "Manual read, playing again", gameTable = Nothing }, Cmd.none )

        _ ->
            ( QError, Cmd.none )


view : Model -> Html Msg
view state =
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


viewStateQ0 : Q0Content -> Html Msg
viewStateQ0 content =
    div []
        [ p [] [ text "This is a camel race." ]
        , p [] [ text "You can bet on camels to get money, try to play tricks on camels you dont like, or even bet on different camels as the race progresses." ]
        , p [] [ text "The best: You also get money by betting right on the biggest looser on the end of the race" ]
        , p [] [ text "As the game progresses, you will get many different options. " ]
        , p [] [ text "First, enter your name and this screen and next well choose for you a character" ]
        , hr [] []
        , text ("Your current name:" ++ content.name)
        , p [] [ text ("current global players: " ++ String.fromInt content.totalPlayers) ]
        , button [ onClick JoinTable ] [ text "Join free table" ]
        , button [ onClick (ConnectToRoom "2") ] [ text "Join room 2" ]
        ]


viewStateQ1 : Q1Content -> Html Msg
viewStateQ1 content =
    div []
        [ p [] [ text ("Amount of players in this room: " ++ String.fromInt content.playersOnTable) ]
        , text ("Your current char:" ++ gameCharToString content.char)
        , p [] [ text "Other characters in this room:" ]
        , p [] [ text (List.foldl (\x y -> gameCharToString x ++ " | " ++ y) "" content.otherChars) ]
        , button [ onClick (ConnectToRoom "1") ] [ text "Ask to start and lock table (actually join room 1)" ]
        ]


viewStateQ2 : Q2Content -> Html Msg
viewStateQ2 content =
    case content.gameTable of
        Nothing ->
            div []
                [ text content.text
                ]

        Just gt ->
            Html.map GameTable (GameTable.view gt)


viewStateQ3 : Html Msg
viewStateQ3 =
    div []
        [ text "You are seeing the game rules"
        , button [ onClick Resume ] [ text "Go back to game" ]
        ]


viewNotImplemented : Html Msg
viewNotImplemented =
    text "View not implemented"


viewError : Html Msg
viewError =
    text "State transition error inside FEState logic"



---- SUBSCRIPTIONS ---


subscriptions : Model -> Sub Msg
subscriptions _ =
    let
        _ =
            Debug.log "Inside sub of workflow:" 2
    in
    receiveGameTableFromServer ReceiveGameTableFromServer


port receiveGameTableFromServer : (Json.Encode.Value -> msg) -> Sub msg



---- PORTS ----


port joinRoom : String -> Cmd msg
