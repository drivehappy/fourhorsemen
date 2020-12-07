
//
function connectWebSocket(url) {
    return new Promise(function (resolve, reject) {
        // Connect to the websocket server
        try {
            var ws = new WebSocket(url)
            ws.binaryType = 'arraybuffer'

            ws.addEventListener('close', function (event) {
                //store.dispatch('setWebsocketConnected', false)
            })
            ws.addEventListener('error', function (event) {
                reject(event)
            })
            ws.addEventListener('open', function (event) {
                app.ports.wsConnected.send("TODO");
                resolve(ws)
            })
        } catch (err) {
            console.error('Could not connect to websocket server: ', url)
            app.ports.wsError.send("Failed to connect to server")
            reject()
        }
    })
}

// TODO: Global
let gConnectedWebSocket = null;

// Begins a connection to the server, if the connection can't be established
// or is disconnected, then it will automatically attempt to retry the connection.
//
// TODO: Readd: This uses an exponential backoff to stagger server load
function startWebsocketConnection(url) {
    gConnectedWebSocket = connectWebSocket(url)

    gConnectedWebSocket
        .then(function (socket) {
            //gConnectionBackoff.reset()
            return socket
        }).then(function (socket) {
            createReceiveEvent(socket)
            return socket
        }).catch(e => {
            app.ports.wsError.send("Failed to connect to server")
            //window.setTimeout(startWebsocketConnection, gConnectionBackoff.next())
        })
}

function createReceiveEvent(socket) {
    socket.onmessage = function (msgEvent) {
        let base64Data = btoa(msgEvent.data);
        app.ports.wsReceivedMsg.send(base64Data);
        //deserializeMessage(msgEvent)
    }
    socket.onclose = function (msgEvent) {
        app.ports.wsDisconnected.send("TODO");
    }
}

function sendWebsocketData(data) {
    gConnectedWebSocket
        .then(function (socket) {
            socket.send(data)
        }, function (error) {
            console.error('Could not send data on websocket: ', error)
        })
}
