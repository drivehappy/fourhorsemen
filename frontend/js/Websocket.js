
// TODO: Global
let gConnectedWebSocket = null;

// Begins a connection to the server, if the connection can't be established
// or is disconnected, then it will automatically attempt to retry the connection.
//
// TODO: Readd: This uses an exponential backoff to stagger server load
function startWebsocketConnection(url) {
    if (gConnectedWebSocket !== null) {
        // We issue the Elm event here, if we tie it to the 'close' event, there appears to be a race
        // sometimes where it gets applied _after_ a new open event.
        app.ports.wsDisconnected.send("TODO");
        gConnectedWebSocket.close();
    }

    // Start a new connection
    gConnectedWebSocket = new WebSocket(url)
    gConnectedWebSocket.binaryType = 'arraybuffer'

    gConnectedWebSocket.addEventListener('close', function (event) {
        //app.ports.wsDisconnected.send("TODO");
    })
    gConnectedWebSocket.addEventListener('error', function (event) {
        //reject(event);
    })
    gConnectedWebSocket.addEventListener('open', function (event) {
        app.ports.wsConnected.send("TODO");
    })

    //
    createReceiveEvent(gConnectedWebSocket);

    return gConnectedWebSocket;
}

// Taken from: https://stackoverflow.com/a/9458996
function _arrayBufferToBase64( buffer ) {
    var binary = '';
    var bytes = new Uint8Array( buffer );
    var len = bytes.byteLength;
    for (var i = 0; i < len; i++) {
        binary += String.fromCharCode( bytes[ i ] );
    }
    return window.btoa( binary );
}

function createReceiveEvent(socket) {
    socket.onmessage = function (msgEvent) {
        let base64Data = _arrayBufferToBase64(msgEvent.data);
        app.ports.wsReceivedMsg.send(base64Data);
    }
    socket.onclose = function (msgEvent) {
        app.ports.wsDisconnected.send("TODO");
    }
}

function sendWebsocketData(data) {
    if (gConnectedWebSocket) {
        gConnectedWebSocket.send(data);
    }
}
