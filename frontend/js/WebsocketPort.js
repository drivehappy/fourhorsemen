
app.ports.wsConnect.subscribe((message) => {
    startWebsocketConnection(message);
})

app.ports.wsSend.subscribe((message) => {
    sendWebsocketData(message);
})
