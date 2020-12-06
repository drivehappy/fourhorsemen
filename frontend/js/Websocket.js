
url = "ws://localhost:8081/websocket"

//
function connectWebSocket() {
    return new Promise(function (resolve, reject) {
        // Connect to the websocket server
        try {
            console.log("Attempting to connect to " + url);

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
            reject()
        }
    })
}

// TODO: Global
gConnectedWebSocket;

// Begins a connection to the server, if the connection can't be established
// or is disconnected, then it will automatically attempt to retry the connection.
//
// TODO: Readd: This uses an exponential backoff to stagger server load
function startWebsocketConnection() {
    console.log("Start WS debug 0");

    gConnectedWebSocket = connectWebSocket()

    gConnectedWebSocket
        .then(function (socket) {
            //gConnectionBackoff.reset()
            console.log("Start WS debug 1");
            return socket
        }).then(function (socket) {
            console.log("Start WS debug 2");
            createReceiveEvent(socket)
            return socket
        }).catch(e => {
            console.log("Start WS debug 3: " + e);
            window.setTimeout(startWebsocketConnection, gConnectionBackoff.next())
        })
}

function createReceiveEvent(socket) {
    socket.onmessage = function (msgEvent) {
        console.log('onmessage: ', msgEvent)

        app.ports.wsReceivedMsg.send(msgEvent.data);
        //deserializeMessage(msgEvent)
    }
    socket.onclose = function (msgEvent) {
        store.dispatch('setWebsocketConnected', false)
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
