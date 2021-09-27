/* ======================= VARIABLES ======================= */

final int horizontalSide = 1500;
final int verticalSide = 800;
final float gravity = 3.0;

/* ======================== CLASSES ======================== */

class Slingshot {
  float x;          // X coordinate
  float y;          // Y coordinate
  float HEIGHT;     // Slingshot height
  float WIDTH;      // Slingshot width
  Stone stone;      // Stone for slingshot
  boolean shooting; // Whether the stone has been shot already or not

  float initialX;
  float initialY;

  Slingshot(float x, float y, float HEIGHT, float WIDTH, Stone stone) {
    this.x = x;
    this.y = y;
    this.HEIGHT = HEIGHT;
    this.WIDTH = WIDTH;
    this.stone = stone;
    this.shooting = false;
  }

  void shoot(float xCoord, float yCoord, Bird[] b) {
    this.shooting = true;

    if (this.stone.pos.x >= horizontalSide || this.stone.pos.y >= verticalSide) this.restart();

    for (int i = 0; i < b.length; i++)
      if (this.stone.collideWithBird(b[i])) {
        b[i].kill();
        this.restart();
      }

    this.stone.positions.add(new PVector(this.stone.pos.x, this.stone.pos.y));
    this.stone.drawTrail();

    float newX = xCoord-this.stone.positions.get(0).x;
    float newY = yCoord-this.stone.positions.get(0).y;
    this.stone.pos.x += newX/100 * this.stone.v;
    this.stone.pos.y += newY/100 * this.stone.v;

    stroke(255, 0, 0);
    strokeWeight(s.stone.r);
    point(this.stone.pos.x, this.stone.pos.y);
  }

  void restart() {
    if (shooting == true) {
      this.stone.pos.x = this.stone.positions.get(0).x;
      this.stone.pos.y = this.stone.positions.get(0).y;

      this.stone.positions.clear();
      frameCount = 0;
      this.shooting = false;
    }
  }

  void draw() {
    strokeWeight(15);
    stroke(184, 129, 73);
    line(x+WIDTH/2.0, y, x+WIDTH/2.0, y-((2.0/3.0)*HEIGHT));
    line(x+WIDTH/2.0, y-((2.0/3.0)*HEIGHT), x, y-HEIGHT);
    line(x+WIDTH/2.0, y-((2.0/3.0)*HEIGHT), x+WIDTH, y-HEIGHT);

    stone.draw();
  }
}


class Stone {
  PVector pos;              // Stone position
  float v;                  // Stone velocity
  float m;                  // Stone mass
  float r;                  // Stone radius
  ArrayList<PVector> positions = new ArrayList<PVector>(); // Tracking old positions to draw the trail

  Stone(PVector pos, float v, float m, float r) {
    this.pos = pos;
    this.v = v;
    this.m = m;
    this.r = r;
  }

  void drawTrail() {
    strokeWeight(r/2);
    stroke(255, 0, 0);

    for (int i = 0; i < positions.size(); i++)
      point(positions.get(i).x, positions.get(i).y);
  }

  boolean collideWithBird(Bird b) {
    return b.drawable && PVector.sub(pos, b.pos).magSq() < sq(r + b.size);
  }

  void draw() {
    strokeWeight(r*2);
    stroke(79, 79, 79);
    point(pos.x, pos.y);
  }
}

class Bird {
  PVector pos;   // Bird position
  float size;    // Bird radius, since it's a circle =)
  color c = color(floor(random(256)), floor(random(256)), floor(random(256))); // Bird color
  boolean drawable;

  Bird(float size) {
    this.pos = new PVector( random(horizontalSide/2, horizontalSide), random(0, verticalSide) );
    this.size = size;

    this.drawable = true;
  }

  void kill() {
    this.drawable = false;
  }

  void draw() {
    noStroke();
    fill(c);
    circle(pos.x, pos.y, size);
  }
}

/* ========================= FUNCS ========================= */

void drawBirds(Bird[] b) {
  for (int i = 0; i < b.length; i++)
    if (b[i].drawable) b[i].draw();
}

/* ======================== CONFIG ======================== */

float slingshotHeight = 100, slingshotWidth = 60;
float slingshotX = horizontalSide/8.0, slingshotY= verticalSide;
float stoneX = slingshotX + 0.5*slingshotWidth, stoneY = slingshotY - slingshotHeight; // Center the stone inside the slingshot
PVector sVector = new PVector(stoneX, stoneY);

Stone stone = new Stone(sVector, 1.25, 0.0, 10);

Bird b1 = new Bird(60);
Bird b2 = new Bird(60);
Bird b3 = new Bird(60);
Bird b4 = new Bird(60);
Bird b5 = new Bird(60);

Bird[] birds = {b1, b2, b3, b4, b5};

/* ========================= SETUP ========================= */

Slingshot s = new Slingshot(slingshotX, slingshotY, slingshotHeight, slingshotWidth, stone);
float xPos, yPos;

void keyPressed() {
  xPos = mouseX;
  yPos = mouseY;

  if (key == 's') s.shoot(xPos, yPos, birds);
  else if (key == 'r') s.restart();
}

void settings() {
  size(horizontalSide, verticalSide);
}

void setup() {
}

void draw() {
  background(46, 159, 240);

  if (s.shooting) s.shoot(xPos, yPos, birds);
  
  s.draw();

  // Add gravity
  yPos += gravity; // [TO-DO IMPROVEMENT]: The gravity should be calculated in the ball itself

  drawBirds(birds);
}
