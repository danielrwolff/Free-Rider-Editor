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

  void update() {
    cameraOffsetX = environment.getCameraOffsetX();
    cameraOffsetY = environment.getCameraOffsetY();
    cameraZoom = environment.getCameraZoom();
    activeLineTypes = ui.getLineTypes();
    cursorX = int((mouseX/cameraZoom)-cameraOffsetX);
    cursorY = int((mouseY/cameraZoom)-cameraOffsetY);
    correctedMouseX = int((cursorX + cameraOffsetX)*cameraZoom);
    correctedMouseY = int((cursorY + cameraOffsetY)*cameraZoom);
  }

  void draw() {
  }
  void displayImage() {
  }
  String getStatus() {
    return status;
  }
  boolean isClicked(int _x, int _y) {
    return false;
  }
  void doClick(int _x, int _y) {
  }
  void doMouseDown(int _x, int _y) {
  }
  void doMouseDragged(int _x, int _y) {
  }
  void setShiftDown(boolean _down) {
  }
  void onEscape() {
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
  boolean isClicked (int _x, int _y) {
    if (clickField.isClicked(_x, _y))
      return true;
    return false;
  }
  void displayImage() {
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
  boolean isClicked (int _x, int _y) {
    if (clickField.isClicked(_x, _y))
      return true;
    return false;
  }
  void draw() {
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

  void update() {
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
        status = "Next point: (" + cursorX + "," + cursorY + ") ; Line length: " + str(int(sqrt(sq(line.get(0) - cursorX) + sq(line.get(1) - cursorY)))) + " ; Angle: " + nf(degrees(atan2(line.get(1)-cursorY, line.get(0)-cursorX)), 0, 2);
        break;
      }
    }
  }

  void draw() {
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

  void doMouseDown(int _x, int _y) {
    if (stage == 0) {
      if (shiftDown) {
        line.append(prevLineX);
        line.append(prevLineY);
        stage = 2;
      } else 
        stage = 1;
      line.append(int((_x/cameraZoom)-cameraOffsetX));
      line.append(int((_y/cameraZoom)-cameraOffsetY));
    }
  }

  void doClick(int _x, int _y) {
    switch (stage) {
    case 1:
      line.append(int((_x/cameraZoom)-cameraOffsetX));
      line.append(int((_y/cameraZoom)-cameraOffsetY));
      stage = 0;
      processLineData();
      break;
    case 2:
      line.append(int((_x/cameraZoom)-cameraOffsetX));
      line.append(int((_y/cameraZoom)-cameraOffsetY));
      break;
    }
  }


  void setShiftDown(boolean _down) {
    shiftDown = _down;
  }

  void onEscape() {
    stage = 0;
    line.clear();
  }

  void processLineData() {
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

  void update() {
    super.update();

    if (mouseX > 50 && mouseY < height-50) 
      status = "Erase around point: (" + cursorX + "," + cursorY + ")";
  }

  void draw() {
    fill(255);
    strokeWeight(1);
    stroke(0);
    ellipse(correctedMouseX, correctedMouseY, eraserSize*cameraZoom, eraserSize*cameraZoom);
  }

  void doMouseDragged(int _x, int _y) {

    if (activeLineTypes[0]) {
      for (PhysicalLine i : environment.getAllPhysicalLines ()) {
        if (circleLineCollision(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), eraserSize/2, i.points)) 
          removePhysicalLines.add(i);
      }
    }
    if (activeLineTypes[1]) {
      for (SceneryLine i : environment.getAllSceneryLines ()) {
        if (circleLineCollision(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), eraserSize/2, i.points)) 
          removeSceneryLines.add(i);
      }
    }
    if (activeLineTypes[2]) {
      for (Powerup i : environment.getAllPowerups ()) {
        if (circleCircleCollision(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), eraserSize/2, i.posX, i.posY, int(i.size/cameraZoom))) {
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

  void update() {
    super.update();
    for (SquareTool i : powerupTypes) {
      i.update();
    }
  }

  void draw() {
    stroke(200);
    fill(240, 200);
    rect(x + w, y, w, h*powerupTypes.length);

    for (SquareTool i : powerupTypes) {
      i.displayImage();
    }
    powerupTypes[currentType].draw();
  }

  void doClick(int _x, int _y) {
    for (int i = 0; i < powerupTypes.length; i++) {
      if (powerupTypes[i].isClicked(_x, _y)) {
        currentType = byte(i);
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
  void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0, 150);
    fill(255, 255, 0, 150);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  void doClick(int _x, int _y) {
    environment.addPowerup(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUBoost_Tool extends SquareTool {
  char type;
  PUBoost_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(0, 255, 0);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  void doClick(int _x, int _y) {
    environment.addPowerup(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUGravity_Tool extends SquareTool {
  char type;
  PUGravity_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(0, 170, 255);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  void doClick(int _x, int _y) {
    environment.addPowerup(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUSlowMo_Tool extends SquareTool {
  char type;
  PUSlowMo_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(225);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  void doClick(int _x, int _y) {
    environment.addPowerup(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUBomb_Tool extends SquareTool {
  char type;
  PUBomb_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(255, 0, 0);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  void doClick(int _x, int _y) {
    environment.addPowerup(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUCheckpoint_Tool extends SquareTool {
  char type;
  PUCheckpoint_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0);
    fill(0, 0, 255);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  void doClick(int _x, int _y) {
    environment.addPowerup(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), 0, type, true);
  }
}
class PUVehicle_Tool extends SquareTool {
  char type;
  PUVehicle_Tool(int _x, int _y, int _w, int _h, boolean _active, char _type) {
    super(_x, _y, _w, _h, _active);
    clickField.setImage("powerupTool.png");
    type = _type;
  } 
  void draw() {
    strokeWeight(2*cameraZoom);
    stroke(0, 150);
    fill(255, 160, 0, 150);
    ellipse(correctedMouseX, correctedMouseY, 15*cameraZoom, 15*cameraZoom);
  }
  void doClick(int _x, int _y) {
    environment.addPowerup(int((_x/cameraZoom)-cameraOffsetX), int((_y/cameraZoom)-cameraOffsetY), 0, type, true);
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

  void draw() {
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

  boolean doIsClicked(int _x, int _y) {
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

  String getStatus() {
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

  boolean[] getLineTypes() {
    return typeStatus;
  }

  void setMultiType(boolean _m) {
    allowMulti = _m;
    if (!allowMulti) {
      typeStatus[0] = true;
      typeStatus[1] = false;
      typeStatus[2] = false;
    }
  }
  void setPowerType(boolean _p) {
    allowPower = _p;
    if (!allowPower)
      typeStatus[2] = false;
  }
  void setAllowNone(boolean _n) {
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

  void update() {
    txtBox.setVisible(importingOrExporting);
  }

  void draw() {
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
      text(internalButtonText[i], internalButtons[i].x + (internalButtons[i].w)/2, internalButtons[i].y + internalButtons[i].h*0.75);
    }
  }

  boolean isClicked(int _x, int _y) {
    if (clickField.isClicked(_x, _y)) {
      importingOrExporting = true;
      return true;
    } 
    return false;
  }

  void doInternalClick(int _x, int _y) {
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

  void setImportingExporting(boolean _i) {
    importingOrExporting = _i;
  }
  boolean getImportingExporting() {
    return importingOrExporting;
  }
}