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

    importingExporting = new ImportExport_Tool(0, height-baseBarHeight, leftBarWidth, leftBarWidth, int(width*0.7), int(height/4), 150, 50, true, importExport);
    editorTypes = new Type_Tool(width-115, height-25, int(40/2));
  }

  void update() {

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

  void draw() {

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

  void onMouseDown(int _x, int _y) {
    if (importingExporting.getImportingExporting()) 
      return;
    if (_x > leftBarWidth && _y < height-baseBarHeight)
      tools[currentTool].doMouseDown(_x, _y);
  }

  void onMouseDragged(int _x, int _y) {
    if (importingExporting.getImportingExporting()) 
      return;
    tools[currentTool].doMouseDragged(_x, _y);
  }

  void onClick(int _x, int _y) {
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

  void shiftDown(boolean _down) {
    tools[currentTool].setShiftDown(_down);
  }

  private boolean[] getLineTypes() {
    return editorTypes.getLineTypes();
  }
  void onEscape() {
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

  void draw() {
  }
  void setImage(String _file) {
  }
  boolean isClicked(int _mx, int _my) {
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

  void draw() {
    if (optImage != null)
      image(optImage, x, y);
  }

  void setImage(String _file) {
    optImage = loadImage(_file);
    optImage.resize(w, h);
  }

  boolean isClicked(int _mx, int _my) {
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

  boolean isClicked(int _mx, int _my) {
    if (sqrt(sq(x-_mx) + sq(y-_my)) <= r && active)
      return true;
    return false;
  }
}

