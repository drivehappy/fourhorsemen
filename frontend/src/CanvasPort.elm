port module CanvasPort exposing (..)


--
-- JS -> Elm
--

port canvasClicked : ((Int, Int) -> msg) -> Sub msg
