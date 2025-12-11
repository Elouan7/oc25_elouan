// console.log("helllo");


// const canvas_image = document.getElementById("canvas");
// const ctx_image = canvas_image.getContext("2d");

// const img = new Image();
// img.onload = function() {
//     ctx_image.drawImage(img, 150, 150, 100, 100);
// }
// img.src = "../images/fleche.svg";

// function init() {
//     img.src = "../images/fleche.svg";
//     window.requestAnimationFrame(draw);
// }

// var i = 0;
// function draw() {
//     ctx_image.clearRect(0, 0, canvas_image.width, canvas_image.height);

//     ctx_image.save();
//     ctx_image.translate(200, 200);
//     ctx_image.rotate(10000000000 * i * Math.PI / 180);
//     ctx_image.drawImage(img, -50, -50, 100, 100);
//     ctx_image.restore();

//     i += 2;
//     window.requestAnimationFrame(draw);
// }

// init();


const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

canvas.width = 400;
canvas.height = 400;

const centerX = canvas.width / 2;
const centerY = canvas.height / 2;
const radius = 150;

let angle = 0;

// Génération aléatoire de points fixes
const points = [];
for (let i = 0; i < 10; i++) {
    points.push({
        x: centerX + (Math.random() - 0.5) * radius * 1.5,
        y: centerY + (Math.random() - 0.5) * radius * 1.5
    });
}

function drawRadar() {
    // Fond noir
    ctx.fillStyle = "#000000";
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Cercles concentriques
    for (let i = 1; i <= 4; i++) {
        ctx.beginPath();
        ctx.arc(centerX, centerY, (radius / 4) * i, 0, 2 * Math.PI);
        ctx.strokeStyle = "#00FF00";
        ctx.lineWidth = 1;
        ctx.stroke();
    }

    // Lignes de repère (quartiers)
    for (let i = 0; i < 360; i += 45) {
        const rad = i * Math.PI / 180;
        ctx.beginPath();
        ctx.moveTo(centerX, centerY);
        ctx.lineTo(centerX + radius * Math.cos(rad), centerY + radius * Math.sin(rad));
        ctx.strokeStyle = "#00FF0033";
        ctx.stroke();
    }

    // Scanner : un simple trait qui tourne
    ctx.save();
    ctx.translate(centerX, centerY);
    ctx.rotate(angle);
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(radius, 0);
    ctx.strokeStyle = "#00FF00";
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.restore();

    // Points fixes
    points.forEach(p => {
        ctx.beginPath();
        ctx.arc(p.x, p.y, 5, 0, 2 * Math.PI);
        ctx.fillStyle = "#00FF00";
        ctx.fill();
    });

    angle += 0.02; // vitesse de rotation du trait
    requestAnimationFrame(drawRadar);
}

drawRadar();






