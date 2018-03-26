var backgroundElement = document.getElementById("background-canvas");
var background = backgroundElement.getContext("2d");

var FPS = 30;
var CIRCLE_SPAWN = 50;
var spawn = 0;

setInterval(function() {
  updateBackground();
  drawBackground();
}, 1000/FPS);

var circles = [];

function Circle(I) {
  I = I || {};

  I.active = true;
  I.size = 1;
  I.maxSize = Math.floor(Math.random()*100+100);
  I.growth = 0.05;
  I.centerX = Math.floor(Math.random()*(BACKGROUND_WIDTH+200))-100;
  I.centerY = Math.floor(Math.random()*(BACKGROUND_HEIGHT+200))-100;
  I.opacity = 1;
  switch(Math.floor(Math.random()*5)) {
    case 0:
      I.red = 3;
      I.green = 60;
      I.blue = 104;
      I.color = "#033268";
      break;
    case 1:
      I.red = 63;
      I.green = 63;
      I.blue = 63;
      I.color = "#3F3F3F";
      break;
    case 2:
      I.red = 245;
      I.green = 166;
      I.blue = 35;
      I.color = "#F5A623";
      break;
    case 3:
      I.red = 134;
      I.green = 187;
      I.blue = 216;
      I.color = "#86BBD8";
      break;
    case 4:
      I.red = 134;
      I.green = 187;
      I.blue = 216;
      I.color = "#86BBD8";
      break;
    default:
      I.active = false;
      break;
  }

  I.draw = function() {
    background.beginPath();
    background.fillStyle = "rgba(" + I.red + "," + I.green + "," + I.blue + "," + I.opacity + ")";
    /*background.strokeStyle = "#d6d6d6";*/
    background.arc(I.centerX,I.centerY,I.size,0,2*Math.PI);
    background.fill();
  };

  I.update = function() {
    I.size += I.growth;
    I.growth = 2*Math.cos((I.size/I.maxSize)*(1/2)*Math.PI)+1;
    I.opacity = 1-I.size/I.maxSize;
    I.active = I.active && (I.size < I.maxSize);
  };

  return I;
};

function updateBackground() {
  circles.forEach(function(circle) {
    circle.update();
  });

  circles = circles.filter(function(circle) {
    return circle.active;
  });

  if(Math.random()*1000 < spawn) {
    spawn = 0;
    circles.push(Circle());
  }
  else {
    spawn += 1.2;
  }
}

function drawBackground(){
  BACKGROUND_WIDTH = backgroundElement.offsetWidth;
  BACKGROUND_HEIGHT = backgroundElement.offsetHeight;
  backgroundElement.height = BACKGROUND_HEIGHT;
  backgroundElement.width = BACKGROUND_WIDTH;
  background.clearRect(0, 0, BACKGROUND_WIDTH, BACKGROUND_HEIGHT);

  circles.forEach(function(circle) {
    circle.draw();
  });
}

document.getElementById("jumbotron").addEventListener('click', function(event) {
  var x = event.pageX,
      y = event.pageY;
  var newCircle = Circle();
  newCircle.centerX = x;
  newCircle.centerY = y;
  circles.push(newCircle);

}, false);

document.getElementById("jumbotron").addEventListener('touchstart', function(event) {
  // Cache the client X/Y coordinates
  var x = event.touches[0].pageX,
      y = event.touches[0].pageY;
  var newCircle = Circle();
  newCircle.centerX = x;
  newCircle.centerY = y;
  circles.push(newCircle);

}, false);
