/* ======================= VARIABLES ======================= */

final int horizontalSide = 1500;
final int verticalSide = 800;

/* ======================== CLASSES ======================== */

class Fish {
  float x;           // X coordinate
  float depth;       // Swimming depth
  float v;           // Velocity
  int direction;     // Fish swimming direction:   1=right,  -1=left
  color[] c;         // Colors:  1st=tail and head,  2nd=body
  float LENGTH;      // Fish length
  float HEIGHT;      // Fish height

  Fish(float x, float depth, float v, int direction, color[] c, float LENGTH, float HEIGHT) {
    //this.x = direction == 1 ? 0 : horizontalSide;
    this.x = x;
    this.depth = depth;
    this.v = v;
    this.direction = direction;
    this.c = c;
    this.LENGTH = LENGTH;
    this.HEIGHT = HEIGHT;
  }

  void draw() { // [TO-DO IMPROVEMENT]: Create a Fish#move() method and use the Fish#draw() method to draw the new position at (x + dx)
    noStroke();
    fill(c[0]);

    float movement = x + (frameCount % ((horizontalSide + LENGTH)/v))*direction*v;
    float dx = direction == 1 ? movement-LENGTH : movement;

    float k = LENGTH/2.5;

    if (direction == -1) { // Swimming to the left
      // Head
      fill(c[0]);
      triangle(dx, depth+HEIGHT/2.0, dx+k, depth, dx+k, depth+HEIGHT);

      // Body
      fill(c[1]);
      triangle(dx+k, depth, dx+k, depth+HEIGHT, dx + 2.0*k, depth+HEIGHT/2.0);

      // Tail
      fill(c[0]);
      triangle(dx+LENGTH, depth+HEIGHT/4.0, dx+LENGTH, depth+(3.0/4.0)*HEIGHT, dx+(2.0*k), depth+HEIGHT/2.0);

      // Eye
      fill(0, 0, 0);
      stroke(0);
      strokeWeight(13);
      point(dx + 0.5*k, depth + HEIGHT/4.0);
    } else {  // Swimming to the right
      // Tail
      fill(c[0]);
      triangle(dx, depth+HEIGHT/4.0, dx, depth+(3.0/4.0)*HEIGHT, dx+k/2.0, depth+HEIGHT/2.0);

      // Body
      fill(c[1]);
      triangle(dx+k/2.0, depth + HEIGHT/2.0, dx+1.5*k, depth, dx+1.5*k, depth+HEIGHT);

      // Head
      fill(c[0]);
      triangle(dx + 1.5*k, depth, dx + 1.5*k, depth + HEIGHT, dx + LENGTH, depth + HEIGHT/2.0);

      // Eye
      fill(0, 0, 0);
      stroke(0);
      strokeWeight(13);
      point(dx + 2*k, depth + HEIGHT/4.0);
    }
  }
}


class Bubble {
  float x;        // Center X coordinate
  float y;        // Center Y coordinate
  float radius;   // Radius

  Bubble(float x, float y, float radius) {
    this.x = x;
    this.y = y;
    this.radius = radius;
  }

  void draw() {
    noStroke();
    fill(58, 239, 252);

    float v = 50.0/radius;
    float movement = y - (frameCount % ((verticalSide + radius)/v))*v;

    circle(x, movement, radius);
  }
}


class Sardine extends Fish {
  float x;         // X coordinate
  float depth;     // Swimming depth
  float v;         // Velocity
  int direction;   // Fish swimming direction:   1=right,  -1=left
  color[] c;       // Colors:  1st=tail and head,  2nd=body
  float LENGTH;    // Fish length
  float HEIGHT;    // Fish height

  Sardine(float x, float depth, float v, int direction, color[] c, float LENGTH, float HEIGHT) {
    super(x, depth, v, direction, c, LENGTH, HEIGHT);
  }
}


class FishShoal {
  float x;               // X coordinate
  float y;               // Y coordinate
  float r;               // Radius
  int direction;         // Swimming direction
  float v;               // Swimming velocity
  Fish[] fishes = {};    // Fishes

  FishShoal(float x, float y, float r, int direction, float v) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.direction = direction;
    this.v = v;
  }

  void addFish(Fish f) {
    fishes = (Fish[]) append(fishes, f);
  }

  void placeFishes(int amount) {    
    for (int i = 0; i < amount; i++) {
      float radiusRandom = random(1);
      float thetaRandom = random(1);
            
      float radius = r * sin(radiusRandom);
      float theta = 2.0 * PI * thetaRandom;
      float X = x + radius*cos(theta);
      float Y = y + radius*sin(theta);
            
      color[] sardineColors = {color(145, 145, 145), color(204, 204, 204)};
      Sardine sardine = new Sardine(X, Y, v, direction, sardineColors, 80, 20);
      
      this.addFish(sardine);
    }
  }

  void draw() {
    for (int i = 0; i < this.fishes.length; i++)
      this.fishes[i].draw();
  }
}

/* ========================= FUNCTIONS ========================= */

void fishesDraw(Fish[] f) {
  for (int i = 0; i < f.length; i++)
    f[i].draw();
}

void bubblesDraw(Bubble[] b) {
  for (int i = 0; i < b.length; i++)
    b[i].draw();
}

/* ======================== CONFIG ======================== */

color[] colors1 = {color(237, 66, 66), color(106, 66, 237)}; // Red
color[] colors2 = {color(182, 106, 252), color(255, 150, 255)}; // Purple

Fish f1 = new Fish(0, 200, 3.9, 1, colors1, 200, 50);
Fish f2 = new Fish(horizontalSide, 450, 3.5, -1, colors2, 300, 300);

Fish fishes1[] = {f1, f2};

/* -------------------------------------------------------- */

color[] colors3 = {color(57, 212, 57), color(255, 255, 255)}; // Green
color[] colors4 = {color(255, 212, 54), color(255, 255, 255)}; // Yellow

Fish f3 = new Fish(0, 300, 10, 1, colors3, 200, 100);
Fish f4 = new Fish(horizontalSide, 30, 4, -1, colors4, 80, 55);

Fish fishes2[] = {f1, f2, f3, f4};

// Yeah, there might be a better way of doing this...
Bubble b1 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b2 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b3 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b4 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b5 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b6 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b7 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b8 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b9 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b10 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b11 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b12 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b13 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b14 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b15 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b16 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));
Bubble b17 = new Bubble(random(0, horizontalSide), verticalSide, random(10, 40));

Bubble[] bubbles = {b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17};

FishShoal shoal = new FishShoal(0, 300, 200, 1, 7.0);

/* ========================= SETUP ========================= */

void settings() {
  size(horizontalSide, verticalSide);
}

void setup() {
  shoal.placeFishes(35);
}

void draw() {
  background(46, 159, 240);

  // Same-speed fishes
  // fishesDraw(fishes1);


  // Different-speed fishes
  // fishesDraw(fishes2);


  // Different-speed fishes with bubbles
  // fishesDraw(fishes2);    
  // bubblesDraw(bubbles);


  // (NOT FINISHED) Shoal of fish with or without bubbles
  // shoal.draw();
  // bubblesDraw(bubbles);
}
