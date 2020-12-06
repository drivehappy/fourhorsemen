
app.ports.wsConnect.subscribe((message) => {
    console.log("Elm request WS connect");

    startWebsocketConnection(message);
})

app.ports.wsSend.subscribe((message) => {
    console.log("Elm request WS send");

    sendWebsocketData(message);
})
