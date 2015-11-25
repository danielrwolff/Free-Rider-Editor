class Powerup extends GameObject {
  color c;
  int posX, posY, size = 15;

  int cameraOffsetX, cameraOffsetY, angle;
  float cameraZoom;

  char type;

  Powerup(int _posX, int _posY) {
    super();
    posX = _posX;
    posY = _posY;
  }

  Powerup() {
    super();
  }

  void update() {
    cameraOffsetX = environment.getCameraOffsetX(); 
    cameraOffsetY = environment.getCameraOffsetY();
    cameraZoom = environment.getCameraZoom();
  }

  void draw() {
    fill(c);
    strokeWeight(2*cameraZoom);
    ellipse((posX + cameraOffsetX)*cameraZoom, (posY + cameraOffsetY)*cameraZoom, size*cameraZoom, size*cameraZoom);
  }

  boolean isOnScreen() {
    if (0 < (posX + cameraOffsetX)*cameraZoom && (posX + cameraOffsetX)*cameraZoom < width &&
      0 < (posY + cameraOffsetY)*cameraZoom && (posY + cameraOffsetY)*cameraZoom < height)
      return true;
    return false;
  }
}



class Goal extends Powerup {
  Goal(int _posX, int _posY) {
    super(_posX, _posY);
    c = color(255, 255, 0);
    type = 'T';
  }
}
class Boost extends Powerup {
  Boost(int _posX, int _posY, int _angle) {
    super(_posX, _posY);
    angle = _angle;
    c = color(0, 255, 0);
    type = 'B';
  }

  void draw() {
    fill(c);
    pushMatrix();
    translate((posX + cameraOffsetX)*cameraZoom, (posY + cameraOffsetY)*cameraZoom);
    rotate(radians(angle));
    triangle(0, -20*cameraZoom, -10*cameraZoom, 10*cameraZoom, 10*cameraZoom, 10*cameraZoom);
    popMatrix();
  }
}
class Gravity extends Powerup {
  Gravity(int _posX, int _posY, int _angle) {
    super(_posX, _posY);
    angle = _angle;
    c = color(0, 170, 255);
    type = 'G';
  }

  void draw() {
    fill(c);
    pushMatrix();
    translate((posX + cameraOffsetX)*cameraZoom, (posY + cameraOffsetY)*cameraZoom);
    rotate(radians(angle));
    triangle(0, -20*cameraZoom, -10*cameraZoom, 10*cameraZoom, 10*cameraZoom, 10*cameraZoom);
    popMatrix();
  }
}
class SlowMo extends Powerup {
  SlowMo(int _posX, int _posY) {
    super(_posX, _posY);
    c = color(225);
    type = 'S';
  }
}
class Bomb extends Powerup {
  Bomb(int _posX, int _posY) {
    super(_posX, _posY);
    c = color(255, 0, 0);
    type = 'O';
  }
}
class Checkpoint extends Powerup {
  Checkpoint(int _posX, int _posY) {
    super(_posX, _posY);
    c = color(0, 0, 255);
    type = 'C';
  }
}
class Vehicle extends Powerup {
  Vehicle(int _posX, int _posY) {
    super(_posX, _posY);
    c = color(255, 160, 0);
    type = 'V';
  }
}