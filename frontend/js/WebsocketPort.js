//
// Ports
//

app.ports.wsConnect.subscribe((message) => {
    startWebsocketConnection(message);
})

app.ports.wsSend.subscribe((base64message) => {
    const ab = Uint8Array.from(atob(base64message), c => c.charCodeAt(0))

    // Convert Base64 back into an array buffer so we can send binary data through websocket
    sendWebsocketData(ab);
})
