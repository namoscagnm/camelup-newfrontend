module Tests exposing (..)

import Expect exposing (Expectation)
import GameTable exposing (decodeGameTable, encodeGameTable, sampleGameTable)
import Json.Decode exposing (decodeString)
import Json.Encode exposing (encode)
import Test exposing (..)



-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


encodeDecodeLoop : Test
encodeDecodeLoop =
    test "Tests encoder decoder loop"
        (\_ ->
            (Json.Encode.encode 0 <| GameTable.encodeGameTable GameTable.sampleGameTable)
                |> Json.Decode.decodeString GameTable.decodeGameTable
                |> Expect.equal (Ok GameTable.sampleGameTable)
        )
