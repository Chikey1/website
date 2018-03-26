var FPS = 30;
var firstGame = true;

var score = 0;
var player = {
  active: false,
  color: "#00A",
  x: 100,
  y: 270,
  width: 42,
  height: 38,
  right: false,
  left: false,
  up: false,
  left: false,
  speed: 5,
  horizontalSprite: Sprite("playerHorizontal"),
  verticalSprite: Sprite("playerVertical"),
  isVertical: true,
  draw: function() {
    this.verticalSprite.draw(canvas, this.x, this.y);
    /*
    if (this.isHorizontal) {
      this.width = 42,
      this.height = 38,
      this.horizontalSprite.draw(canvas, this.x, this.y);
    }
    else {
      this.width = 38,
      this.height = 42,
      this.verticalSprite.draw(canvas, this.x, this.y);
    } */
  }
};


var canvasElement = document.getElementById("myCanvas");
var canvas = canvasElement.getContext("2d");
var CANVAS_WIDTH = canvasElement.getAttribute( "width" );
var CANVAS_HEIGHT = canvasElement.getAttribute( "height" );
CANVAS_WIDTH = CANVAS_WIDTH.slice("px", -2);
CANVAS_HEIGHT = CANVAS_HEIGHT.slice("px", -2);

setInterval(function() {
  if(player.active) {
    updateGame();
    drawGame();
  }
  else {
    updateScreen();
    drawScreen();
  }

}, 1000/FPS);

trees = [];
var treeSpawn = 0.025;
var treeSpeed = 3;

function Tree(I) {
  I = I || {};

  I.active = true;

  I.color = "#A2B";

  I.x = Math.random() * CANVAS_WIDTH - 15;
  I.y = -40;
  I.xVelocity = 0;
  I.yVelocity = treeSpeed;

  switch(Math.floor(Math.random()*2)) {
    case 0:
      I.width = 26;
      I.height = 26;
      I.sprite = Sprite("tree26");
      break;
    case 1:
      I.width = 40;
      I.height = 40;
      I.sprite = Sprite("tree40");
      break;

    default:
      break;
  }

  I.inBounds = function() {
    return I.x >= -15 && I.x <= CANVAS_WIDTH &&
      I.y >= -40 && I.y <= CANVAS_HEIGHT;
  };



  I.draw = function() {
    this.sprite.draw(canvas, this.x, this.y);
  };

  I.update = function() {
    I.x += I.xVelocity;
    I.y += I.yVelocity;

    I.active = I.active && I.inBounds();
  };

  I.explode = function() {
    this.active = false;

  };

  return I;
};


player.explode = function() {
  this.active = false;
};

function handleCollisions() {
  trees.forEach(function(tree) {
    if (collides(tree, player)) {
      tree.explode();
      player.explode();
    }
  });
}

function updateGame() {
  score += 0.1;

  if (keydown.left || player.left) {
    player.x -= player.speed;
    //isHorizontal = true;
  }

  if (keydown.right || player.right) {
    player.x += player.speed;
    //isHorizontal = true;
  }

  if (keydown.up || player.up) {
    player.y -= player.speed;
    //isHorizontal = false;
  }

  if (keydown.down || player.down) {
    player.y += player.speed;
    //isHorizontal = false;
  }

  player.x = clamp(player.x, 0, CANVAS_WIDTH - player.width);
  player.y = clamp(player.y, 0, CANVAS_HEIGHT - player.height);

  trees.forEach(function(tree) {
    tree.update();
  });

  trees = trees.filter(function(tree) {
    return tree.active;
  });

  if(Math.random() < treeSpawn) {
    trees.push(Tree());
  }


  if (treeSpawn < 0.1) {
    treeSpawn += 0.0001;
  }

  if(treeSpeed < 10) {
    treeSpeed += 0.005;
  }

  handleCollisions();
}

function drawGame() {
  canvas.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
  canvas.fillStyle = "#F0F0F0";
  canvas.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
  player.draw();

  trees.forEach(function(tree) {
    tree.draw();
  });
}




function mouseUp () {
  player.up = true;
}

function mouseDown () {
  player.down = true;
}

function mouseLeft () {
  player.left = true;
}

function mouseRight () {
  player.right = true;
}

function stopMove () {
  player.up = false;
  player.down = false;
  player.left = false;
  player.right = false;
}

function collides(a, b) {
  return a.x < b.x + b.width &&
         a.x + a.width > b.x &&
         a.y < b.y + b.height &&
         a.y + a.height > b.y;
}

function clamp(num, min, max) {
  return num <= min ? min : num >= max ? max : num;
}

function updateScreen () {

}

function drawScreen () {
  canvas.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
  canvas.fillStyle = "#000";
  canvas.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);

  var play = canvasElement.getContext("2d");
  play.font = "30px Arial";
  play.fillStyle = "#fff" ;
  play.textAlign = "center";
  if(firstGame) {
    play.fillText("PLAY", 125,150);
  }
  else {
    play.fillText("SCORE: " + Math.floor(score), 125,140);
    play.fillText("REPLAY", 125, 175);
  }


}

canvasElement.addEventListener('click', function(event) {
  var x = event.screenX,
      y = event.screenY;
  var rect = canvasElement.getBoundingClientRect();

  // Collision detection between clicked offset and element.
  if (y > rect.top && y < rect.bottom*2
          && x > rect.left && x < rect.right && !player.active) {
          player.x = 100;
          player.y = 230;
          player.active = true;
          trees = [];
          treeSpawn = 0.025;
          treeSpeed = 3;
          score = 0;
          firstGame = false;
      }

}, false);


canvasElement.addEventListener('touchstart', function(event) {

  // Collision detection between clicked offset and element.
  if (!player.active) {
          player.x = 100;
          player.y = 230;
          player.active = true;
          trees = [];
          treeSpawn = 0.025;
          treeSpeed = 3;
          score = 0;
          firstGame = false;
      }

}, false);
