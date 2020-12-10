// Taken from: https://stackoverflow.com/a/18053642

function getCursorPosition(canvas, event) {
    const rect = canvas.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    
    return [Math.round(x), Math.round(y)];
}

const canvas = document.querySelector('canvas');
canvas.addEventListener('mousedown', function(e) {
    const pos = getCursorPosition(canvas, e);

    app.ports.canvasClicked.send(pos);
})
