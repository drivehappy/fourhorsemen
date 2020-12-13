port module CanvasPort exposing (..)

--
-- Elm -> JS
--

port canvasCreated : String -> Cmd msg


--
-- JS -> Elm
--

port canvasClicked : ((Int, Int) -> msg) -> Sub msg
