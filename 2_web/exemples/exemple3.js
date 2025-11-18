console.log("Bonjour le monde !");


const status = document.getElementById("status");
const ctx_status = status.getContext("2d");


ctx_status.fillStyle = "lightgreen";
ctx_status.fillRect(0, 0, 300, 300);
ctx_status.fillStyle = "darkgreen";
ctx_status.fillRect(100, 100, 100, 100);


const dessin = document.getElementById("dessin");
const ctx_dessin = dessin.getContext("2d");


ctx_dessin.fillStyle = "black";
ctx_dessin.fillRect(200, 200, 100, 100);



for (var i = 0; i < 50; i++) {
    for (var j = 0; j < 50; j++) {
        if ((i + j) % 2 == 0) {
            ctx_dessin.fillStyle = "white";
        } else {
            ctx_dessin.fillStyle = "gray";
        }
        ctx_dessin.fillRect(i * 50, j * 50, 50, 50);
    }
}


for (var a = 0; a < 50; a++) {
    for (var b = 0; b < 50; b++) {
        if ((a + b) % 2 == 0) {
            ctx_status.fillStyle = "darkgreen";
        } else {
            ctx_status.fillStyle = "lightgreen";
        }
        ctx_status.fillRect(a * 50, b * 50, 50, 50);
    }
}