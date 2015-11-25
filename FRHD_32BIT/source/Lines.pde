class GameObject {
  GameObject() {
  }
}

class Line extends GameObject {
  int[] points;
  color c;

  int cameraOffsetX, cameraOffsetY;
  float cameraZoom;

  Line(int[] _points) {
    points = _points;
  }

  Line(int x1, int y1, int x2, int y2) {
    super();
    points = new int[4];
    points[0] = x1; 
    points[1] = y1; 
    points[2] = x2; 
    points[3] = y2;
  }

  Line(String _points) {
    super();
    points = new int[4];
    for (int i = 0; i < 4; i++) {
      points[i] = int((split(_points, " "))[i]);
    }
  }

  void update() {
    cameraOffsetX = environment.getCameraOffsetX(); 
    cameraOffsetY = environment.getCameraOffsetY();
    cameraZoom = environment.getCameraZoom();
  }

  void draw() {
    stroke(c);
    strokeWeight(2*cameraZoom);
    line((points[0] + cameraOffsetX)*cameraZoom, (points[1] + cameraOffsetY)*cameraZoom, 
    (points[2] + cameraOffsetX)*cameraZoom, (points[3] + cameraOffsetY)*cameraZoom);
  }

  boolean isOnScreen() {
    if (0 > (points[0] + cameraOffsetX)*cameraZoom && 0 > (points[2] + cameraOffsetX)*cameraZoom ||
      width < (points[0] + cameraOffsetX)*cameraZoom && width < (points[2] + cameraOffsetX)*cameraZoom)
      return false;

    if (0 > (points[1] + cameraOffsetY)*cameraZoom && 0 > (points[3] + cameraOffsetY)*cameraZoom ||
      height < (points[1] + cameraOffsetY)*cameraZoom && height < (points[3] + cameraOffsetY)*cameraZoom)
      return false;
    return true;
  }
}

class PhysicalLine extends Line {

  PhysicalLine(int[] _points) {
    super(_points);
    c = color(0);
  }

  PhysicalLine(String _points) {
    super(_points);
    c = color(0);
  }

  PhysicalLine(int x1, int y1, int x2, int y2) {
    super(x1, y1, x2, y2);
    c = color(0);
  }
}

class SceneryLine extends Line {

  SceneryLine(int[] _points) {
    super(_points);
    c = color(150);
  }

  SceneryLine(String _points) {
    super(_points);
    c = color(150);
  }

  SceneryLine(int x1, int y1, int x2, int y2) {
    super(x1, y1, x2, y2);
    c = color(150);
  }
}