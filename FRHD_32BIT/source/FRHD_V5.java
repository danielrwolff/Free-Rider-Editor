import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import g4p_controls.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class FRHD_V5 extends PApplet {



Environment environment;
GTextArea txtBox;
String defaultTrackData = "-18 1i 18 1i##";
String version = "V4.0";

public void setup() {
  
  ellipseMode(CENTER);
  strokeWeight(2);

  println("-=-=- FRHD Community Concept Editor " + version + " -=-=-");
  println("-=-=-         Developed by Sono          -=-=-");
  println("-=-=-                                    -=-=-");
  println("-=-=-        Libraries used: G4P         -=-=-");
  println();

  txtBox = new GTextArea (this, width/5, height/4, PApplet.parseInt(width/2), PApplet.parseInt(height/2), G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
  environment = new Environment();
}

public void draw() {
  background(255);

  //  stroke(255,0,0);
  //  line(0,0,width,height);
  //  stroke(0,255,0);
  //  line(width/4,0,width/4,height);
  //  line(width/2,0,width/2,height);
  //  line(width*0.75,0,width*0.75,height);

  environment.update();
  environment.draw();
}


public void mouseReleased() {
  if (mouseButton == RIGHT) {
    environment.resetCameraPivot();
  } else if (mouseButton == LEFT) {
    environment.onClick(mouseX, mouseY);
  }
}

public void mousePressed() {
  if (mouseButton == RIGHT) {
    environment.createCameraPivot(mouseX, mouseY);
  } else if (mouseButton == LEFT) {
    environment.onMouseDown(mouseX, mouseY);
  }
}

public void mouseDragged() {
  if (mouseButton == RIGHT) {
    environment.panCamera(mouseX, mouseY);
  } 
  if (mouseButton == LEFT) {
    environment.onMouseDragged(mouseX, mouseY);
  }
}

public void mouseWheel(MouseEvent event) {
  environment.setCameraZoom(event.getCount(), width, height);
}

public void keyPressed() {
  // Disable exit on ESC
  if (key == 27) {
    environment.onEscape();
    key = 0;
  }
  else if (key == 'z') {
    environment.undo(); 
  }
  else if (key == 'y') {
    environment.redo(); 
  }

  if (keyCode == SHIFT) {
    environment.shiftDown(true);
  }
}

public void keyReleased() {
  if (keyCode == SHIFT) {
    environment.shiftDown(false);
  }
}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) { /* code */}
class Camera {

  int posX, posY, pivotX, pivotY, changeX, changeY;
  float zoom;

  Camera(int _posX, int _posY, float _zoom) {
    posX = _posX;
    posY = _posY;
    zoom = _zoom;
  }

  public void update() {
    posX -= (pivotX - changeX)/zoom;
    posY -= (pivotY - changeY)/zoom;
    pivotX = changeX;
    pivotY = changeY;

  }

  public int getPosX() {
    return posX;
  }
  public int getPosY() {
    return posY;
  }
  public float getZoom() {
    return zoom;
  }

  public void createCameraPivot(int _x, int _y) {
    pivotX = _x;
    pivotY = _y;
    changeX = pivotX;
    changeY = pivotY;
  }

  public void resetCameraPivot() {
    pivotX = changeX;
    pivotY = changeY;
  }

  public void panCamera(int _changeX, int _changeY) {
    changeX = _changeX;
    changeY = _changeY;
  }

  public void setCameraZoom(int _inc, int _x, int _y) {
    
    if (_inc == -1) 
      zoom+=0.1f;
    else if (_inc == 1)
      zoom-=0.1f;
    if (zoom < 0.1f)
      zoom = 0.1f;
    else if (zoom > 3)
      zoom = 3.0f;
    
  }
}




Camera camera;
TrackData trackManager;
UserInterface ui;
UndoRedo ur;

class Environment {

  Environment() {
    camera = new Camera(width/2, height/2, 1.0f);
    trackManager = new TrackData("");
    ui = new UserInterface();
    ur = new UndoRedo(15);
  }

  public void update() {
    camera.update();
    trackManager.update();
    ui.update();
  }

  public void draw() {
    trackManager.draw();
    ui.draw();
  }

  private int getCameraOffsetX() {
    return camera.getPosX();
  }
  private int getCameraOffsetY() {
    return camera.getPosY();
  }
  private float getCameraZoom() {
    return camera.getZoom();
  }
  public void setCameraZoom(int _inc, int _x, int _y) {
    camera.setCameraZoom(_inc, _x, _y);
  }
  public void createCameraPivot(int _x, int _y) {
    camera.createCameraPivot(_x, _y);
  }
  public void panCamera(int _cx, int _cy) {
    camera.panCamera(_cx, _cy);
  }
  public void resetCameraPivot() {
    camera.resetCameraPivot();
  }

  public void onClick(int _x, int _y) {
    ui.onClick(_x, _y);
  }
  public void onMouseDown(int _x, int _y) {
    ui.onMouseDown(_x, _y);
  }
  public void onMouseDragged(int _x, int _y) {
    ui.onMouseDragged(_x, _y);
  }
  public void shiftDown(boolean _down) {
    ui.shiftDown(_down);
  }
  public void onEscape() {
    ui.onEscape();
  }

  public void addLine(int[] _line, boolean[] _activeTypes, boolean _addNewEvent) {
    trackManager.addLine(_line, _activeTypes, _addNewEvent);
  }
  public void addPowerup(int _x, int _y, int _angle, char _type, boolean _addNewEvent) {
    trackManager.addPowerup(_x, _y, _angle, _type, _addNewEvent);
  }
  public void removeLine(int[] _line, boolean[] _activeTypes, boolean _addNewEvent) {
    trackManager.removeLine(_line, _activeTypes, _addNewEvent);
  }
  public void removePowerup(int _x, int _y, int _angle, char _type, boolean _addNewEvent) {
    trackManager.removePowerup(_x, _y, _angle, _type, _addNewEvent);
  }
  public void addEvent(char _type, String _p, String _s, String _pu, String _prevP, String _prevS, String _prevPU) {
    ur.addEvent(_type, _p, _s, _pu, _prevP, _prevS, _prevPU);
  }

  public void undo() {
    ur.undo();
  }
  public void redo() {
    ur.redo();
  }

  public void setTrackData(String _data) {
    trackManager.setTrackData(_data);
  }
  public String getTrackData() {
    return trackManager.getTrackData();
  }

  public ArrayList<PhysicalLine> getAllPhysicalLines() {
    return trackManager.getAllPhysicalLines();
  }
  public ArrayList<SceneryLine> getAllSceneryLines() {
    return trackManager.getAllSceneryLines();
  }
  public ArrayList<Powerup> getAllPowerups() {
    return trackManager.getAllPowerups();
  }
}
class GameObject {
  GameObject() {
  }
}

class Line extends GameObject {
  int[] points;
  int c;

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
      points[i] = PApplet.parseInt((split(_points, " "))[i]);
    }
  }

  public void update() {
    cameraOffsetX = environment.getCameraOffsetX(); 
    cameraOffsetY = environment.getCameraOffsetY();
    cameraZoom = environment.getCameraZoom();
  }

  public void draw() {
    stroke(c);
    strokeWeight(2*cameraZoom);
    line((points[0] + cameraOffsetX)*cameraZoom, (points[1] + cameraOffsetY)*cameraZoom, 
    (points[2] + cameraOffsetX)*cameraZoom, (points[3] + cameraOffsetY)*cameraZoom);
  }

  public boolean isOnScreen() {
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
class Powerup extends GameObject {
  int c;
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

  public void update() {
    cameraOffsetX = environment.getCameraOffsetX(); 
    cameraOffsetY = environment.getCameraOffsetY();
    cameraZoom = environment.getCameraZoom();
  }

  public void draw() {
    fill(c);
    strokeWeight(2*cameraZoom);
    ellipse((posX + cameraOffsetX)*cameraZoom, (posY + cameraOffsetY)*cameraZoom, size*cameraZoom, size*cameraZoom);
  }

  public boolean isOnScreen() {
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

  public void draw() {
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

  public void draw() {
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
class Tool {

  int x, y, cameraOffsetX, cameraOffsetY;
  float cameraZoom;
  String status;
  boolean active;
  boolean[] activeLineTypes;

  int correctedMouseX, correctedMouseY, cursorX, cursorY;

  Tool(int _x, int _y, boolean _active) {
    x = _x;
    y = _y;
    active = _active;
    activeLineTypes = new boolean[0];
  }

  public void update() {
    cameraOffsetX = environment.getCameraOffsetX();
    cameraOffsetY = environment.getCameraOffsetY();
    cameraZoom = environment.getCameraZoom();
    activeLineTypes = ui.getLineTypes();
    cursorX = PApplet.parseInt((mouseX/cameraZoom)-cameraOffsetX);
    cursorY = PApplet.parseInt((mouseY/cameraZoom)-cameraOffsetY);
    correctedMouseX = PApplet.parseInt((cursorX + cameraOffsetX)*cameraZoom);
    correctedMouseY = PApplet.parseInt((cursorY + cameraOffsetY)*cameraZoom);
  }

  public void draw() {
  }
  public void displayImage() {
  }
  public String getStatus() {
    return status;
  }
  public boolean isClicked(int _x, int _y) {
    return false;
  }
  public void doClick(int _x, int _y) {
  }
  public void doMouseDown(int _x, int _y) {
  }
  public void doMouseDragged(int _x, int _y) {
  }
  public void setShiftDown(boolean _down) {
  }
  public void onEscape() {
  }
}

class SquareTool extends Tool {
  RectButton clickField;
  int w, h;
  SquareTool(int _x, int _y, int _w, int _h, boolean _active) {
    super(_x, _y, _active);
    w = _w;
    h = _h;
    clickField = new RectButton(x, y, w, h, active);
  }
  public boolean isClicked (int _x, int _y) {
    if (clickField.isClicked(_x, _y))
      return true;
    return false;
  }
  public void displayImage() {
    clickField.draw();
  }
}

class RoundTool extends Tool {
  CircButton clickField;
  int r;
  RoundTool(int _x, int _y, int _r, boolean _active) {
    super(_x, _y, _active);
    r = _r;
    clickField = new CircButton(x, y, r, active);
  }
  public boolean isClicked (int _x, int _y) {
    if (clickField.isClicked(_x, _y))
      return true;
    return false;
  }
  public void draw() {
    ellipse(x, y, 2*r, 2*r);
  }
}

//-----------------------------------------------------------------------\\

// // // // // // // // // // LINE TOOL CLASS \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

//-----------------------------------------------------------------------\\

class Line_Tool extends SquareTool {

  byte stage;
  IntList line;
  int prevLineX, prevLineY;
  boolean shiftDown = false;

  Line_Tool(int _x, int _y, int _w, int _h, boolean _active) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("lineTool.png");
    status = "";
    stage = 0;
    line = new IntList();
  }

  public void update() {
    super.update();
    if (shiftDown && stage != 0) 
      stage = 2;
    else if (stage == 2 && !shiftDown) {
      stage = 0;
      processLineData();
    }

    if (mouseX > 50 && mouseY < height-50) {
      switch (stage) {
      case 0:
        status = "First point: (" + cursorX + "," + cursorY + ")";
        break;
      case 1:
      case 2:
        status = "Next point: (" + cursorX + "," + cursorY + ") ; Line length: " + str(PApplet.parseInt(sqrt(sq(line.get(0) - cursorX) + sq(line.get(1) - cursorY)))) + " ; Angle: " + nf(degrees(atan2(line.get(1)-cursorY, line.get(0)-cursorX)), 0, 2);
        break;
      }
    }
  }

  public void draw() {
    super.draw();

    strokeWeight(2*cameraZoom);
    stroke(255, 0, 0);
    point(correctedMouseX, correctedMouseY);

    if (mouseX > 50 && mouseY < height-50) {
      switch(stage) {
      case 0:
        if (shiftDown) 
          line((prevLineX + cameraOffsetX)*cameraZoom, (prevLineY + cameraOffsetY)*cameraZoom, correctedMouseX, correctedMouseY);
        break;
      case 1:
      case 2:
        for (int i = 0; i < line.size (); i+=2) {
          if (i+3 < line.size())
            line((line.get(i) + cameraOffsetX)*cameraZoom, (line.get(i+1) + cameraOffsetY)*cameraZoom, (line.get(i+2) + cameraOffsetX)*cameraZoom, (line.get(i+3) + cameraOffsetY)*cameraZoom);
          else 
            line((line.get(i) + cameraOffsetX)*cameraZoom, (line.get(i+1) + cameraOffsetY)*cameraZoom, correctedMouseX, correctedMouseY);
        }
        break;
      }
    }
  }

  public void doMouseDown(int _x, int _y) {
    if (stage == 0) {
      if (shiftDown) {
        line.append(prevLineX);
        line.append(prevLineY);
        stage = 2;
      } else 
        stage = 1;
      line.append(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX));
      line.append(PApplet.parseInt((_y/cameraZoom)-cameraOffsetY));
    }
  }

  public void doClick(int _x, int _y) {
    switch (stage) {
    case 1:
      line.append(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX));
      line.append(PApplet.parseInt((_y/cameraZoom)-cameraOffsetY));
      stage = 0;
      processLineData();
      break;
    case 2:
      line.append(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX));
      line.append(PApplet.parseInt((_y/cameraZoom)-cameraOffsetY));
      break;
    }
  }


  public void setShiftDown(boolean _down) {
    shiftDown = _down;
  }

  public void onEscape() {
    stage = 0;
    line.clear();
  }

  public void processLineData() {
    environment.addLine(line.array(), activeLineTypes, true);
    prevLineX = line.get(line.size()-2);
    prevLineY = line.get(line.size()-1);
    line.clear();
  }
}

//-------------------------------------------------------------------------\\

// // // // // // // // // // ERASER TOOL CLASS \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

//-------------------------------------------------------------------------\\

class Eraser_Tool extends SquareTool {

  byte eraserSize = 5;
  float proj;
  ArrayList<PhysicalLine> removePhysicalLines;
  ArrayList<SceneryLine> removeSceneryLines;
  ArrayList<Powerup> removePowerups;

  Eraser_Tool(int _x, int _y, int _w, int _h, boolean _active) {
    super(_x, _y, _w, _h, _active); 
    clickField.setImage("eraserTool.png");
    removePhysicalLines = new ArrayList<PhysicalLine>();
    removeSceneryLines = new ArrayList<SceneryLine>();
    removePowerups = new ArrayList<Powerup>();
  }

  public void update() {
    super.update();

    if (mouseX > 50 && mouseY < height-50) 
      status = "Erase around point: (" + cursorX + "," + cursorY + ")";
  }

  public void draw() {
    fill(255);
    strokeWeight(1);
    stroke(0);
    ellipse(correctedMouseX, correctedMouseY, eraserSize*cameraZoom, eraserSize*cameraZoom);
  }

  public void doMouseDragged(int _x, int _y) {

    if (activeLineTypes[0]) {
      for (PhysicalLine i : environment.getAllPhysicalLines ()) {
        if (circleLineCollision(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), eraserSize/2, i.points)) 
          removePhysicalLines.add(i);
      }
    }
    if (activeLineTypes[1]) {
      for (SceneryLine i : environment.getAllSceneryLines ()) {
        if (circleLineCollision(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), eraserSize/2, i.points)) 
          removeSceneryLines.add(i);
      }
    }
    if (activeLineTypes[2]) {
      for (Powerup i : environment.getAllPowerups ()) {
        if (circleCircleCollision(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), eraserSize/2, i.posX, i.posY, PApplet.parseInt(i.size/cameraZoom))) {
          removePowerups.add(i);
        }
      }
    }

    for (PhysicalLine i : removePhysicalLines) {
      environment.removeLine(i.points, activeLineTypes, true);
    }
    for (SceneryLine i : removeSceneryLines) {
      environment.removeLine(i.points, activeLineTypes, true);
    }
    for (Powerup i : removePowerups) {
      environment.removePowerup(i.posX, i.posY, i.angle, i.type, true);
    }
    removePhysicalLines.clear();
    removeSceneryLines.clear();
    removePowerups.clear();
  }

  private boolean circleLineCollision(int _cx, int _cy, float _r, int[] _linePoints) {
    // vector 'a' = point 1 on line -> center point of circle
    // vector 'b' = line 
    // proj = (a DOT b)/|b|

    float lineLength = (sqrt(sq((_linePoints[0]-_linePoints[2])) + sq((_linePoints[1]-_linePoints[3]))));
    proj = ((_linePoints[0]-_cx)*(_linePoints[0]-_linePoints[2]) + (_linePoints[1]-_cy)*(_linePoints[1]-_linePoints[3]))/lineLength;

    if (proj < 0) {
      if (sqrt(sq((_linePoints[0]-_cx)) + sq((_linePoints[1]-_cy))) <= _r)
        return true;
    } else if (proj > lineLength) {
      if (sqrt(sq((_linePoints[2]-_cx)) + sq((_linePoints[3]-_cy))) <= _r)
        return true;
    } else {
      float dx, dy;
      dx = _linePoints[0] + (_linePoints[2]-_linePoints[0])*(proj/lineLength);
      dy = _linePoints[1] + (_linePoints[3]-_linePoints[1])*(proj/lineLength);
      if (sqrt(sq((dx-_cx)) + sq((dy-_cy))) <= _r)
        return true;
    }
    return false;
  }

  private boolean circleCircleCollision(int _x1, int _y1, int _r1, int _x2, int _y2, int _r2) {
    if (sqrt(sq(_x2-_x1) + sq(_y2-_y1)) <= _r1 + _r2)
      return true;
    return false;
  }
}

//----------------------------------------------------------------------\\

// // // // // // // // // // POWER UP CLASS \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

//----------------------------------------------------------------------\\

class Powerup_Tool extends SquareTool {

  SquareTool[] powerupTypes;
  byte currentType;

  Powerup_Tool (int _x, int _y, int _w, int _h, boolean _active) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    powerupTypes = new SquareTool[7];
    powerupTypes[0] = new PUGoal_Tool(x + w, y, w, h, true, 'T');
    powerupTypes[1] = new PUBoost_Tool(x + w, y + h, w, h, true, 'B');
    powerupTypes[2] = new PUGravity_Tool(x + w, y + 2*h, w, h, true, 'G');
    powerupTypes[3] = new PUSlowMo_Tool(x + w, y + 3*h, w, h, true, 'S');
    powerupTypes[4] = new PUBomb_Tool(x + w, y + 4*h, w, h, true, 'O');
    powerupTypes[5] = new PUCheckpoint_Tool(x + w, y + 5*h, w, h, true, 'C');
    powerupTypes[6] = new PUVehicle_Tool(x + w, y + 6*h, w, h, true, 'V');  

    currentType = 0;
  }

  public void update() {
    super.update();
    for (SquareTool i : powerupTypes) {
      i.update();
    }
  }

  public void draw() {
    stroke(200);
    fill(240, 200);
    rect(x + w, y, w, h*powerupTypes.length);

    for (SquareTool i : powerupTypes) {
      i.displayImage();
    }
    powerupTypes[currentType].draw();
  }

  public void doClick(int _x, int _y) {
    for (int i = 0; i < powerupTypes.length; i++) {
      if (powerupTypes[i].isClicked(_x, _y)) {
        currentType = PApplet.parseByte(i);
        return;
      }
    }
    powerupTypes[currentType].doClick(_x, _y);
  }
}

class PUGoal_Tool extends SquareTool {
  char type;
  PUGoal_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  public void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0, 150);
    fill(255, 255, 0, 150);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  public void doClick(int _x, int _y) {
    environment.addPowerup(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUBoost_Tool extends SquareTool {
  char type;
  PUBoost_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  public void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(0, 255, 0);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  public void doClick(int _x, int _y) {
    environment.addPowerup(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUGravity_Tool extends SquareTool {
  char type;
  PUGravity_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  public void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(0, 170, 255);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  public void doClick(int _x, int _y) {
    environment.addPowerup(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUSlowMo_Tool extends SquareTool {
  char type;
  PUSlowMo_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  public void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(225);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  public void doClick(int _x, int _y) {
    environment.addPowerup(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUBomb_Tool extends SquareTool {
  char type;
  PUBomb_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  public void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(255, 0, 0);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  public void doClick(int _x, int _y) {
    environment.addPowerup(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUCheckpoint_Tool extends SquareTool {
  char type;
  PUCheckpoint_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  public void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(0, 0, 255);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  public void doClick(int _x, int _y) {
    environment.addPowerup(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUVehicle_Tool extends SquareTool {
  char type;
  PUVehicle_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  public void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0, 150);
    fill(255, 160, 0, 150);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  public void doClick(int _x, int _y) {
    environment.addPowerup(PApplet.parseInt((_x/cameraZoom)-cameraOffsetX), PApplet.parseInt((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}

//-----------------------------------------------------------------------\\

// // // // // // // // // // TYPE TOOL CLASS \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

//-----------------------------------------------------------------------\\

class Type_Tool {
  RoundTool[] types;
  boolean[] typeStatus;
  boolean allowMulti, allowPower, allowNone;
  int x, y, r;
  String status;
  Type_Tool(int _x, int _y, int _r) {
    x = _x; 
    y = _y; 
    r = _r;
    types = new RoundTool[3];
    for (int i = 0; i < types.length; i++) {
      types[i] = new RoundTool(x + i*(2*r+5), y, r, true);
    }
    typeStatus = new boolean[types.length];
    allowMulti = false;
    allowPower = false;
    allowNone = false;
    status = "";
  }

  public void draw() {
    noStroke();
    fill(0);
    types[0].draw();
    fill(150);
    types[1].draw();
    fill(255, 0, 0);
    types[2].draw();

    noFill();
    strokeWeight(1);
    stroke(100);
    for (int i = 0; i < types.length; i++) {
      if (typeStatus[i])
        ellipse(types[i].x, types[i].y, 2*types[i].r + 5, 2*types[i].r + 5);
    }
  }

  public boolean doIsClicked(int _x, int _y) {
    for (int i = 0; i < types.length; i++) {
      if (types[i].isClicked(_x, _y)) {
        doClick(i);
        return true;
      }
    }
    return false;
  }

  private void doClick(int _type) {
    if (allowNone) {
      for (int i = 0; i < types.length; i++) {
        typeStatus[i] = false;
      }
      return;
    }
    if (!allowPower && _type == 2) {
      typeStatus[2] = false;
      return;
    }

    if (allowMulti) {
      typeStatus[_type] = !typeStatus[_type];
    } else {
      switch (_type) {
      case 0:
        typeStatus[0] = true;
        typeStatus[1] = false;
        typeStatus[2] = false;
        break;
      case 1:
        typeStatus[0] = false;
        typeStatus[1] = true;
        typeStatus[2] = false;
        break;
      case 2:
        typeStatus[0] = false;
        typeStatus[1] = false;
        typeStatus[2] = true;
        break;
      }
    }
  }

  public String getStatus() {
    status = "(";
    if (typeStatus[0]) 
      status += " Physical ";
    if (typeStatus[1]) 
      status += " Scenery ";
    if (typeStatus[2]) 
      status += " Powerup ";
    status += ")";
    if (status.equals("()"))
      return "";
    return status;
  }

  public boolean[] getLineTypes() {
    return typeStatus;
  }

  public void setMultiType(boolean _m) {
    allowMulti = _m;
    if (!allowMulti) {
      typeStatus[0] = true;
      typeStatus[1] = false;
      typeStatus[2] = false;
    }
  }
  public void setPowerType(boolean _p) {
    allowPower = _p;
    if (!allowPower)
      typeStatus[2] = false;
  }
  public void setAllowNone(boolean _n) {
    allowNone = _n; 
    if (!allowNone) {
      for (boolean i : typeStatus) {
        i = false;
      }
    }
  }
}

//-----------------------------------------------------------------------\\

// // // // // // // // // // IMPORTEXPORT TOOL CLASS \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

//-----------------------------------------------------------------------\\

class ImportExport_Tool {

  Button clickField;
  RectButton[] internalButtons;
  String[] internalButtonText;

  int x, y, w, h, offset = 10;
  boolean importingOrExporting;

  ImportExport_Tool(int _x, int _y, int _w, int _h, int _ibx, int _iby, int _ibw, int _ibh, boolean _initialState, PImage _image) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    importingOrExporting = _initialState;

    clickField = new RectButton(x, y, w, h, true, _image);
    internalButtons = new RectButton[4];
    for (int i = 0; i < internalButtons.length; i++) {
      internalButtons[i] = new RectButton(_ibx, _iby + i*(_ibh+10) + offset, _ibw, _ibh, true);
    }
    internalButtonText = new String[internalButtons.length];
    internalButtonText[0] = "Import";
    internalButtonText[1] = "Export";
    internalButtonText[2] = "Clear";
    internalButtonText[3] = "Cancel";

    txtBox.setPromptText("Enter your track code here:");
  }

  public void update() {
    txtBox.setVisible(importingOrExporting);
  }

  public void draw() {
    clickField.draw();
    if (!importingOrExporting)
      return;
    noStroke();
    fill(227, 230, 255);
    rect(internalButtons[0].x, internalButtons[0].y - offset, internalButtons[0].w + 25, height/2);
    strokeWeight(2);
    stroke(200);
    fill(240, 200);
    for (int i = 0; i < internalButtons.length; i++) {
      rect(internalButtons[i].x, internalButtons[i].y, internalButtons[i].w, internalButtons[i].h);
    }
    textAlign(CENTER);
    textSize(30);
    fill(0);
    for (int i = 0; i < internalButtons.length; i++) {
      text(internalButtonText[i], internalButtons[i].x + (internalButtons[i].w)/2, internalButtons[i].y + internalButtons[i].h*0.75f);
    }
  }

  public boolean isClicked(int _x, int _y) {
    if (clickField.isClicked(_x, _y)) {
      importingOrExporting = true;
      return true;
    } 
    return false;
  }

  public void doInternalClick(int _x, int _y) {
    if (internalButtons[0].isClicked(_x, _y))
      environment.setTrackData(join(txtBox.getTextAsArray(), " "));
    else if (internalButtons[1].isClicked(_x, _y))
      txtBox.setText(environment.getTrackData());
    else if (internalButtons[2].isClicked(_x, _y)) {
      txtBox.setText("");
      environment.setTrackData("");
    } else if (internalButtons[3].isClicked(_x, _y))
      importingOrExporting = false;
  }

  public void setImportingExporting(boolean _i) {
    importingOrExporting = _i;
  }
  public boolean getImportingExporting() {
    return importingOrExporting;
  }
}
class TrackData {

  String[] tempTrackData, physicalLineData, sceneryLineData, powerupData, givenData, newData;
  String physicalLineEvent = "", sceneryLineEvent = "";

  ArrayList<PhysicalLine> physicalLines = new ArrayList<PhysicalLine>();
  ArrayList<SceneryLine> sceneryLines = new ArrayList<SceneryLine>();
  ArrayList<Powerup> powerups = new ArrayList<Powerup>();

  char[] alphabet32 = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v'
  };

  TrackData(String _initialData) {
    processData(_initialData);
  }

  public void update() {
    for (SceneryLine i : sceneryLines) {
      i.update();
    }
    for (PhysicalLine i : physicalLines) {
      i.update();
    }
    try {
      for (Powerup i : powerups) {
        i.update();
      }
    } 
    catch (NullPointerException e) {
    }
  }

  public void draw() {
    for (SceneryLine i : sceneryLines) {
      if (i.isOnScreen())
        i.draw();
    }
    for (PhysicalLine i : physicalLines) {
      if (i.isOnScreen())
        i.draw();
    }
    try {
      for (Powerup i : powerups) {
        if (i.isOnScreen())
          i.draw();
      }
    } 
    catch (NullPointerException e) {
    }
  }

  public void setTrackData(String _data) {
    physicalLines.clear();
    sceneryLines.clear();
    powerups.clear();
    processData(_data);
  }

  //--------------------------------------------------------------------\\

  // // // // // // // // // // getTrackData \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //--------------------------------------------------------------------\\

  public String getTrackData() {

    physicalLineData = optimizePLineData(physicalLines);
    sceneryLineData = optimizeSLineData(sceneryLines);
    powerupData = new String[powerups.size()];

    for (int i = 0; i < powerupData.length; i++) {
      switch(powerups.get(i).type) {
      case 'T':
      case 'S':
      case 'O':
      case 'V':
      case 'C':
        powerupData[i] = powerups.get(i).type + " " + powerups.get(i).posX + " " + powerups.get(i).posY;
        break;
      case 'B':
      case 'G':
        powerupData[i] = powerups.get(i).type + " " + powerups.get(i).posX + " " + powerups.get(i).posY + " " + powerups.get(i).angle;
        break;
      }
    }

    //    println("Physical: ");
    //    for (int i = 0; i < physicalLineData.length; i++) {
    //      println(physicalLineData[i]);
    //    }

    String finalPhysicalData = "", finalSceneryData = "", finalPowerupData = "";

    for (int i = 0; i < physicalLineData.length; i++) {
      finalPhysicalData += decToBase32(physicalLineData[i]);
      if (i+1 != physicalLineData.length)
        finalPhysicalData += ",";
    }
    for (int i = 0; i < sceneryLineData.length; i++) {
      finalSceneryData += decToBase32(sceneryLineData[i]);
      if (i+1 != sceneryLineData.length)
        finalSceneryData += ",";
    }
    for (int i = 0; i < powerupData.length; i++) {
      finalPowerupData += decToBase32(powerupData[i]);
      if (i+1 != powerupData.length)
        finalPowerupData += ",";
    }

    return finalPhysicalData + "#" + finalSceneryData + "#" + finalPowerupData;
  }

  //------------------------------------------------------------------------\\

  // // // // // // // // // // optimizeLineData \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //------------------------------------------------------------------------\\

  private String[] optimizePLineData(ArrayList<PhysicalLine> _data) {
    boolean[] usedLines = new boolean[_data.size()];
    StringList newLineList = new StringList();
    IntList points = new IntList();

    for (int i = 0; i < _data.size (); i++) {
      if (usedLines[i])
        continue;
      usedLines[i] = true;
      points.append(_data.get(i).points[0]);
      points.append(_data.get(i).points[1]);
      points.append(_data.get(i).points[2]);
      points.append(_data.get(i).points[3]);
      for (int k = i; k <_data.size (); k++) {
        if (points.get(points.size()-2) == _data.get(k).points[0] && points.get(points.size()-1) == _data.get(k).points[1] && !usedLines[k]) {
          points.append(_data.get(k).points[2]);
          points.append(_data.get(k).points[3]);
          usedLines[k] = true;
        }
      } 
      newLineList.append(join(nf(points.array(), 0), " "));
      points.clear();
    }
    return newLineList.array();
  }

  private String[] optimizeSLineData(ArrayList<SceneryLine> _data) {
    boolean[] usedLines = new boolean[_data.size()];
    StringList newLineList = new StringList();
    IntList points = new IntList();

    for (int i = 0; i < _data.size (); i++) {
      if (usedLines[i])
        continue;
      usedLines[i] = true;
      points.append(_data.get(i).points[0]);
      points.append(_data.get(i).points[1]);
      points.append(_data.get(i).points[2]);
      points.append(_data.get(i).points[3]);
      for (int k = i; k <_data.size (); k++) {
        if (points.get(points.size()-2) == _data.get(k).points[0] && points.get(points.size()-1) == _data.get(k).points[1] && !usedLines[k]) {
          points.append(_data.get(k).points[2]);
          points.append(_data.get(k).points[3]);
          usedLines[k] = true;
        }
      } 
      newLineList.append(join(nf(points.array(), 0), " "));
      points.clear();
    }
    return newLineList.array();
  }


  //---------------------------------------------------------------\\

  // // // // // // // // // // addLine \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //---------------------------------------------------------------\\

  public void addLine(int[] _line, boolean[] _activeTypes, boolean _addNewEvent) {
    physicalLineEvent = ""; 
    sceneryLineEvent = "";

    if (_activeTypes[0]) {
      for (int i = 0; i < _line.length - 2; i+=2) {
        if (sqrt(sq(_line[i+2]-_line[i]) + sq(_line[i+3]-_line[i+1])) >= 2) {
          physicalLines.add(new PhysicalLine(_line[i], _line[i+1], _line[i+2], _line[i+3]));
          physicalLineEvent += _line[i] + " " + _line[i+1] + " " + _line[i+2] + " " + _line[i+3] + ",";
        }
      }
    } else {
      for (int i = 0; i < _line.length - 2; i+=2) {
        if (sqrt(sq(_line[i+2]-_line[i]) + sq(_line[i+3]-_line[i+1])) >= 2) {
          sceneryLines.add(new SceneryLine(_line[i], _line[i+1], _line[i+2], _line[i+3]));
          sceneryLineEvent += _line[i] + " " + _line[i+1] + " " + _line[i+2] + " " + _line[i+3] + ",";
        }
      }
    }

    if (_addNewEvent) {
      environment.addEvent('A', physicalLineEvent, sceneryLineEvent, "", null, null, null);
    }
  }

  //------------------------------------------------------------------\\

  // // // // // // // // // // removeLine \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //------------------------------------------------------------------\\

  public void removeLine(int[] _line, boolean[] _activeTypes, boolean _addNewEvent) {
    physicalLineEvent = ""; 
    sceneryLineEvent = "";

    if (_activeTypes[0]) {
      for (int i = 0; i < physicalLines.size (); i++) {
        if (physicalLines.get(i).points[0] == _line[0] && physicalLines.get(i).points[1] == _line[1] && physicalLines.get(i).points[2] == _line[2] && physicalLines.get(i).points[3] == _line[3]) {
          physicalLines.remove(i);
          physicalLineEvent += _line[0] + " " + _line[1] + " " + _line[2] + " " + _line[3] + ",";
        }
      }
    }
    if (_activeTypes[1]) {
      for (int i = 0; i < sceneryLines.size (); i++) {
        if (sceneryLines.get(i).points[0] == _line[0] && sceneryLines.get(i).points[1] == _line[1] && sceneryLines.get(i).points[2] == _line[2] && sceneryLines.get(i).points[3] == _line[3]) {
          sceneryLines.remove(i);
          sceneryLineEvent += _line[0] + " " + _line[1] + " " + _line[2] + " " + _line[3] + ",";
        }
      }
    }
    if (_addNewEvent) {
      environment.addEvent('E', physicalLineEvent, sceneryLineEvent, "", null, null, null);
    }
  }

  //------------------------------------------------------------------\\

  // // // // // // // // // // addPowerup \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //------------------------------------------------------------------\\

  public void addPowerup(int _x, int _y, int _angle, char _type, boolean _addNewEvent) {
    switch(_type) {
    case 'T':
      powerups.add(new Goal(_x, _y));
      break;
    case 'S':
      powerups.add(new SlowMo(_x, _y));
      break;
    case 'O':
      powerups.add(new Bomb(_x, _y));
      break;
    case 'C':
      powerups.add(new Checkpoint(_x, _y));
      break;
    case 'B':
      powerups.add(new Boost(_x, _y, _angle));
      break;
    case 'G':
      powerups.add(new Gravity(_x, _y, _angle));
      break;
    case 'V':
      powerups.add(new Vehicle(_x, _y));
      break;
    }
    
    if (_addNewEvent) 
      environment.addEvent('A', "", "", _type + " " + _x + " " + _y + " " + _angle, null, null, null);
  }

  //---------------------------------------------------------------------\\

  // // // // // // // // // // removePowerup \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //---------------------------------------------------------------------\\

  public void removePowerup(int _x, int _y, int _angle, char _type, boolean _addNewEvent) {
    for (int i = 0; i < powerups.size (); i++) {
      if (powerups.get(i).posX == _x && powerups.get(i).posY == _y && powerups.get(i).type == _type) {
        powerups.remove(i);
      }
    }
    if (_addNewEvent) 
      environment.addEvent('E', "", "", _type + " " + _x + " " + _y + " " + _angle, null, null, null);
  }

  //-------------------------------------------------------------------\\

  // // // // // // // // // // base32ToDec \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //-------------------------------------------------------------------\\

  private String base32ToDec(String _data) {

    givenData = split(trim(_data), " ");
    newData = new String[givenData.length];
    int value;
    char powerup;
    for (int i = 0; i < givenData.length; i++) {
      value = 0;
      powerup = 'n';
      for (int k = givenData[i].length () -1; k >= 0; k--) {

        switch(givenData[i].charAt(k)) {
        case '-':
          value *= -1;
          break;
        case 'T':
          powerup = 'T';
          break;
        case 'B':
          powerup = 'B';
          break;
        case 'G':
          powerup = 'G';
          break;
        case 'S':
          powerup = 'S';
          break;
        case 'O':
          powerup = 'O';
          break;
        case 'C':
          powerup = 'C';
          break;
        case 'V':
          powerup = 'V';
          break;
        default:
          value += (findIndex(alphabet32, givenData[i].charAt(k)))*pow(32, (givenData[i].length() - k-1));
          break;
        }
      }
      if (powerup == 'n')
        newData[i] = value + "";
      else
        newData[i] = powerup + "";
    }

    return join(newData, " ");
  }

  //-------------------------------------------------------------------\\

  // // // // // // // // // // decToBase32 \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //-------------------------------------------------------------------\\

  private String decToBase32(String _data) {

    givenData = split(trim(_data), " ");
    newData = new String[givenData.length];
    int value;
    String base32;

    for (int i = 0; i < givenData.length; i++) {
      base32 = "";
      switch (givenData[i].charAt(0)) {
      case 'T':
      case 'B':
      case 'G':
      case 'S':
      case 'O':
      case 'C':
      case 'V':
        newData[i] = givenData[i];
        break;
      case '-':
        base32 = "-";
      default:
        value = abs(PApplet.parseInt(givenData[i]));
        if (value == 0) {
          newData[i] = "0";
          break;
        }

        for (int k = floor (log (value)/log(32)); k >= 0; k--) {
          base32 += alphabet32[PApplet.parseInt(value / pow(32, k))];
          value = PApplet.parseInt(value % pow(32, k));
        }

        newData[i] = base32;
        break;
      }
    }

    return join(newData, " ");
  }

  private int findIndex(char[] a, char b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] == b) {
        return i;
      }
    } 
    return 0;
  }

  //-------------------------------------------------------------------\\

  // // // // // // // // // // processData \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //-------------------------------------------------------------------\\

  private void processData(String _data) {

    tempTrackData = split(fixTrackData(_data), "#");

    String[] tempLine;
    StringList tempPhysicalLineData = new StringList();
    StringList tempSceneryLineData = new StringList();

    physicalLineData = split(tempTrackData[0], ",");
    for (int i = 0; i < physicalLineData.length; i++) {
      tempLine = split(trim(physicalLineData[i]), " ");
      for (int k = 0; k < tempLine.length; k+=2) {
        try {
          tempPhysicalLineData.append(tempLine[k] + " " + tempLine[k+1] + " " + tempLine[k+2] + " " + tempLine[k+3]);
        } 
        catch (ArrayIndexOutOfBoundsException e) {
        }
      }
    }

    physicalLineData = tempPhysicalLineData.array();
    for (int i = 0; i < physicalLineData.length; i++) {
      physicalLineData[i] = base32ToDec(physicalLineData[i]);
    }


    sceneryLineData = split(tempTrackData[1], ",");
    for (int i = 0; i < sceneryLineData.length; i++) {
      tempLine = split(trim(sceneryLineData[i]), " ");
      for (int k = 0; k < tempLine.length; k+=2) {
        try {
          tempSceneryLineData.append(tempLine[k] + " " + tempLine[k+1] + " " + tempLine[k+2] + " " + tempLine[k+3]);
        } 
        catch (ArrayIndexOutOfBoundsException e) {
        }
      }
    }

    sceneryLineData = tempSceneryLineData.array();
    for (int i = 0; i < sceneryLineData.length; i++) {
      sceneryLineData[i] = base32ToDec(sceneryLineData[i]);
    }

    powerupData = split(tempTrackData[2], ",");
    for (int i = 0; i < powerupData.length; i++) {
      powerupData[i] = base32ToDec(powerupData[i]);
    }

    /*
  println("Raw: ");
     println("Physical: " + tempTrackData[0]);
     println("Scenery: " + tempTrackData[1]);
     println("Powerup: " + tempTrackData[2]);
     
     println();
     
     println("Converted: ");
     println("Physical: " + join(physicalLineData," "));
     println("Scenery: " + join(sceneryLineData," "));
     println("Powerup: " + join(powerupData, " "));
     */

    for (int i = 0; i < physicalLineData.length; i++) {
      physicalLines.add(new PhysicalLine(physicalLineData[i]));
    }

    for (int i = 0; i < sceneryLineData.length; i++) {
      sceneryLines.add(new SceneryLine(sceneryLineData[i]));
    }

    for (int i = 0; i < powerupData.length; i++) {
      String[] individualPowerupData = split(powerupData[i], " ");
      switch(individualPowerupData[0].charAt(0)) {
      case 'T':
        powerups.add(new Goal(PApplet.parseInt(individualPowerupData[1]), PApplet.parseInt(individualPowerupData[2])));
        break;
      case 'B':
        powerups.add(new Boost(PApplet.parseInt(individualPowerupData[1]), PApplet.parseInt(individualPowerupData[2]), PApplet.parseInt(individualPowerupData[3])));
        break;
      case 'G':
        powerups.add(new Gravity(PApplet.parseInt(individualPowerupData[1]), PApplet.parseInt(individualPowerupData[2]), PApplet.parseInt(individualPowerupData[3])));
        break;
      case 'S':
        powerups.add(new SlowMo(PApplet.parseInt(individualPowerupData[1]), PApplet.parseInt(individualPowerupData[2])));
        break;
      case 'O':
        powerups.add(new Bomb(PApplet.parseInt(individualPowerupData[1]), PApplet.parseInt(individualPowerupData[2])));
        break;
      case 'C':
        powerups.add(new Checkpoint(PApplet.parseInt(individualPowerupData[1]), PApplet.parseInt(individualPowerupData[2])));
        break;
      case 'V':
        powerups.add(new Vehicle(PApplet.parseInt(individualPowerupData[1]), PApplet.parseInt(individualPowerupData[2])));
        break;
      }
    }
  }

  //--------------------------------------------------------------------\\

  // // // // // // // // // // fixTrackData \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //--------------------------------------------------------------------\\

  private String fixTrackData(String data) {
    if (data.equals("")) {
      return defaultTrackData;
    }
    int numHash = 0;
    for (int i = 0; i < data.length (); i++) {
      if (data.charAt(i) == '#') {
        numHash++;
      }
    }
    if (numHash < 2) {
      return data + "##";
    }

    return data;
  }

  public ArrayList<PhysicalLine> getAllPhysicalLines() {
    return physicalLines;
  }
  public ArrayList<SceneryLine> getAllSceneryLines() {
    return sceneryLines;
  }
  public ArrayList<Powerup> getAllPowerups() {
    return powerups;
  }
}
class UserInterface {

  Tool[] tools;
  Button[] extraButtons;
  Type_Tool editorTypes;
  ImportExport_Tool importingExporting;
  PImage frhdLogo, sono, importExport;

  int leftBarWidth = 50, baseBarHeight = 50;
  String status;
  byte currentTool = 0;

  byte numTools = 3;

  UserInterface() {

    frhdLogo = loadImage("FRHDLogo.png");
    frhdLogo.resize(leftBarWidth, leftBarWidth);
    sono = loadImage("Sono.png");
    importExport = loadImage("importExport.png");
    importExport.resize(leftBarWidth, leftBarWidth);

    tools = new Tool[numTools];
    tools[0] = new Line_Tool(0, 60, leftBarWidth, leftBarWidth, true);
    tools[1] = new Eraser_Tool(0, 110, leftBarWidth, leftBarWidth, true);
    tools[2] = new Powerup_Tool(0, 160, leftBarWidth, leftBarWidth, true);

    extraButtons = new Button[2];
    extraButtons[0] = new RectButton(0, 0, leftBarWidth, leftBarWidth, true, frhdLogo);
    extraButtons[1] = new RectButton(width-15, 12, 15, 12, true);
    //extraButtons[2] = new RectButton(0, height-baseBarHeight, leftBarWidth, leftBarWidth, true, importExport);

    importingExporting = new ImportExport_Tool(0, height-baseBarHeight, leftBarWidth, leftBarWidth, PApplet.parseInt(width*0.7f), PApplet.parseInt(height/4), 150, 50, true, importExport);
    editorTypes = new Type_Tool(width-115, height-25, PApplet.parseInt(40/2));
  }

  public void update() {

    importingExporting.update();

    if (!importingExporting.getImportingExporting()) {
      tools[currentTool].update();
      switch(currentTool) {
      case 0:
        status = "Line Tool " + editorTypes.getStatus() + " : " + tools[currentTool].getStatus();
        break;
      case 1:
        status = "Eraser Tool " + editorTypes.getStatus() + " : " + tools[currentTool].getStatus();
        break;
      }
    } else {
      status = "Importing / Exporting";
    }
  }

  public void draw() {

    if (!importingExporting.getImportingExporting())
      tools[currentTool].draw();
    else {
      fill(0, 100);
      rect(0, 0, width, height);
    }

    strokeWeight(2);
    stroke(200);
    fill(240, 200);
    rect(0, height-baseBarHeight, width, height);
    rect(0, 0, leftBarWidth, height-baseBarHeight);
    line(0, leftBarWidth, leftBarWidth, leftBarWidth);
    line(0, leftBarWidth + 10, leftBarWidth, leftBarWidth + 10);
    line(leftBarWidth, height-baseBarHeight, leftBarWidth, height);

    for (Button i : extraButtons) {
      i.draw();
    }

    for (Tool i : tools) {
      i.displayImage();
    }

    editorTypes.draw();
    importingExporting.draw();

    fill(0);
    textSize(10);
    textAlign(RIGHT);
    text("FRHD Community Concept Editor - " + version + " ", width, 12);
    text("Developed by Sono ", width, 24);
    //text("Framerate: " + int(frameRate), width, 24);

    textSize(12);
    textAlign(LEFT);
    text(status, leftBarWidth + 10, height - (baseBarHeight/2) + 6);
  }

  public void onMouseDown(int _x, int _y) {
    if (importingExporting.getImportingExporting()) 
      return;
    if (_x > leftBarWidth && _y < height-baseBarHeight)
      tools[currentTool].doMouseDown(_x, _y);
  }

  public void onMouseDragged(int _x, int _y) {
    if (importingExporting.getImportingExporting()) 
      return;
    tools[currentTool].doMouseDragged(_x, _y);
  }

  public void onClick(int _x, int _y) {
    if (importingExporting.getImportingExporting()) {
      importingExporting.doInternalClick(_x, _y);
      return;
    }

    if (extraButtons[0].isClicked(_x, _y)) 
      link("http://freeriderhd.com");
    else if (extraButtons[1].isClicked(_x, _y)) 
      image(sono, (width/2)-(sono.width/2), (height/2)-(sono.height/2));
    else if (importingExporting.isClicked(_x, _y));
    else if (editorTypes.doIsClicked(_x, _y));
    else if (tools[0].isClicked(_x, _y)) {
      currentTool = 0;
      editorTypes.setMultiType(false);
      editorTypes.setPowerType(false);
    } else if (tools[1].isClicked(_x, _y)) {
      currentTool = 1;
      editorTypes.setMultiType(true);
      editorTypes.setPowerType(true);
    } else if (tools[2].isClicked(_x, _y)) {
      currentTool = 2;
      editorTypes.setMultiType(false);
      editorTypes.setPowerType(true);
    } else if (_x > leftBarWidth && _y < height-baseBarHeight)
      tools[currentTool].doClick(_x, _y);
  }

  public void shiftDown(boolean _down) {
    tools[currentTool].setShiftDown(_down);
  }

  private boolean[] getLineTypes() {
    return editorTypes.getLineTypes();
  }
  public void onEscape() {
    importingExporting.setImportingExporting(false);
    tools[currentTool].onEscape();
  }
}

class Button {
  boolean active;
  int x, y;
  Button(int _x, int _y, boolean _active) {
    x = _x; 
    y = _y;
    active = _active;
  }

  public void draw() {
  }
  public void setImage(String _file) {
  }
  public boolean isClicked(int _mx, int _my) {
    return false;
  }
}

class RectButton extends Button {
  PImage optImage;
  int w, h;
  RectButton(int _x, int _y, int _w, int _h, boolean _active) {
    super(_x, _y, _active);
    w = _w;
    h = _h;
  }
  RectButton(int _x, int _y, int _w, int _h, boolean _active, PImage _image) {
    super(_x, _y, _active);
    w = _w;
    h = _h;
    optImage = _image;
    optImage.resize(w, h);
  }

  public void draw() {
    if (optImage != null)
      image(optImage, x, y);
  }

  public void setImage(String _file) {
    optImage = loadImage(_file);
    optImage.resize(w, h);
  }

  public boolean isClicked(int _mx, int _my) {
    if (x < _mx && _mx < x + w && y < _my && _my < y + h && active)
      return true;
    return false;
  }
}

class CircButton extends Button {
  int r;
  CircButton(int _x, int _y, int _r, boolean _active) {
    super(_x, _y, _active);
    r = _r;
  }

  public boolean isClicked(int _mx, int _my) {
    if (sqrt(sq(x-_mx) + sq(y-_my)) <= r && active)
      return true;
    return false;
  }
}
class UndoRedo {

  String[][] events, tempEvents;
  byte currentEvent = 0;

  String[] physicalLines, sceneryLines, powerups;

  int[] tempData;
  boolean[] activeTypes;

  UndoRedo(int _maxEvents) {
    events = new String[_maxEvents][7];
    tempData = new int[4];
    activeTypes  = new boolean[3];
  }

  private void cutFromCurrent() {
    for (int i = 0; i < events.length - currentEvent; i++) {
      events[i] = events[i+currentEvent];
    }
    currentEvent = 0;
    println("CUT");
  }

  public void addEvent(char _type, String _p, String _s, String _pu, String _prevP, String _prevS, String _prevPU) {
    if (currentEvent != 0)
      cutFromCurrent();

    tempEvents = new String[events.length][7];
    for (int i = events.length-1; i > 0; i--) {
      tempEvents[i] = events[i-1];
    } 
    events = tempEvents;

    events[0][0] = _type + "";
    events[0][1] = _p;
    events[0][2] = _s;
    events[0][3] = _pu;
    events[0][4] = _prevP;
    events[0][5] = _prevS;
    events[0][6] = _prevPU;
  }

  public void undo() {

    if (currentEvent == events.length)
      return;

    try {
      switch(events[currentEvent][0].charAt(0)) {
      case 'A':
        activeTypes[0] = true;
        physicalLines = split(events[currentEvent][1], ",");
        for (int i = 0; i < physicalLines.length; i++) {
          tempData = PApplet.parseInt(split(physicalLines[i], " "));
          environment.removeLine(tempData, activeTypes, false);
        }
        activeTypes[0] = false;
        activeTypes[1] = true;
        sceneryLines = split(events[currentEvent][2], ",");
        for (int i = 0; i < sceneryLines.length; i++) {
          tempData = PApplet.parseInt(split(sceneryLines[i], " "));
          environment.removeLine(tempData, activeTypes, false);
        }
        activeTypes[1] = false;
        activeTypes[2] = true;
        powerups = split(events[currentEvent][3], ",");
        for (int i = 0; i < powerups.length; i++) {
          tempData = PApplet.parseInt(split(powerups[i], " "));
          environment.removePowerup(tempData[1], tempData[2], tempData[3], powerups[i].charAt(0), false);
        }
        break;
      case 'E':
        activeTypes[0] = true;
        physicalLines = split(events[currentEvent][1], ",");
        for (int i = 0; i < physicalLines.length; i++) {
          tempData = PApplet.parseInt(split(physicalLines[i], " "));
          environment.addLine(tempData, activeTypes, false);
        }
        activeTypes[0] = false;
        activeTypes[1] = true;
        sceneryLines = split(events[currentEvent][2], ",");
        for (int i = 0; i < sceneryLines.length; i++) {
          tempData = PApplet.parseInt(split(sceneryLines[i], " "));
          environment.addLine(tempData, activeTypes, false);
        }
        activeTypes[1] = false;
        activeTypes[2] = true;
        powerups = split(events[currentEvent][3], ",");
        for (int i = 0; i < powerups.length; i++) {
          tempData = PApplet.parseInt(split(powerups[i], " "));
          environment.addPowerup(tempData[1], tempData[2], tempData[3], powerups[i].charAt(0), false);
        }
        break;
      default :
        return;
      }
      currentEvent++;
    } 
    catch (Exception e) {
      return;
    }

    println("UNDO" + " : " + currentEvent);
  }


  public void redo() {

    if (currentEvent == 0)
      return;

    try {
      switch(events[currentEvent-1][0].charAt(0)) {
      case 'A':
        activeTypes[0] = true;
        physicalLines = split(events[currentEvent-1][1], ",");
        for (int i = 0; i < physicalLines.length; i++) {
          tempData = PApplet.parseInt(split(physicalLines[i], " "));
          environment.addLine(tempData, activeTypes, false);
        }
        activeTypes[0] = false;
        activeTypes[1] = true;
        sceneryLines = split(events[currentEvent-1][2], ",");
        for (int i = 0; i < sceneryLines.length; i++) {
          tempData = PApplet.parseInt(split(sceneryLines[i], " "));
          environment.addLine(tempData, activeTypes, false);
        }
        activeTypes[1] = false;
        activeTypes[2] = true;
        powerups = split(events[currentEvent-1][3], ",");
        for (int i = 0; i < powerups.length; i++) {
          tempData = PApplet.parseInt(split(powerups[i], " "));
          environment.addPowerup(tempData[1], tempData[2], tempData[3], powerups[i].charAt(0), false);
        }
        break;
      case 'E':
        activeTypes[0] = true;
        physicalLines = split(events[currentEvent-1][1], ",");
        for (int i = 0; i < physicalLines.length; i++) {
          tempData = PApplet.parseInt(split(physicalLines[i], " "));
          environment.removeLine(tempData, activeTypes, false);
        }
        activeTypes[0] = false;
        activeTypes[1] = true;
        sceneryLines = split(events[currentEvent-1][2], ",");
        for (int i = 0; i < sceneryLines.length; i++) {
          tempData = PApplet.parseInt(split(sceneryLines[i], " "));
          environment.removeLine(tempData, activeTypes, false);
        }
        activeTypes[1] = false;
        activeTypes[2] = true;
        powerups = split(events[currentEvent-1][3], ",");
        for (int i = 0; i < powerups.length; i++) {
          tempData = PApplet.parseInt(split(powerups[i], " "));
          environment.removePowerup(tempData[1], tempData[2], tempData[3], powerups[i].charAt(0), false);
        }
        break;
      default :
        return;
      }
      currentEvent--;
    }

    catch (Exception e) {
    }

    println("REDO" + " : " + currentEvent);
  }
}
  public void settings() {  size(1000, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "FRHD_V5" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
