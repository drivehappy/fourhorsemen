port module WebsocketPort exposing (..)

--
-- Elm -> JS
--

port wsConnect : String -> Cmd msg

port wsSend : String -> Cmd msg


--
-- JS -> Elm
--

port wsConnected : (String -> msg) -> Sub msg

port wsReceivedMsg : (String -> msg) -> Sub msg

port wsError : (String -> msg) -> Sub msg
