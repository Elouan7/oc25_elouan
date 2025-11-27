console.log("helllo");


const canvas_image = document.getElementById("canvas");
const ctx_image = canvas_image.getContext("2d");

const img = new Image();
img.onload = function() {
    ctx_image.drawImage(img, 150, 150, 100, 100);
}
img.src = "../images/fleche.svg";

function init() {
    img.src = "../images/fleche.svg";
    window.requestAnimationFrame(draw);
}

var i = 0;
function draw() {
    ctx_image.clearRect(0, 0, canvas_image.width, canvas_image.height);

    ctx_image.save();
    ctx_image.translate(200, 200);
    ctx_image.rotate(10000000000 * i * Math.PI / 180);
    ctx_image.drawImage(img, -50, -50, 100, 100);
    ctx_image.restore();

    i += 2;
    window.requestAnimationFrame(draw);
}

init();

