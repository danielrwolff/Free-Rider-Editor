


Camera camera;
TrackData trackManager;
UserInterface ui;

class Environment {

  Environment(String file) {
    camera = new Camera(width/2, height/2, 1.0);
    trackManager = new TrackData("");
    ui = new UserInterface();
  }

  void update() {
    camera.update();
    trackManager.update();
    ui.update();
  }

  void draw() {
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
  void setCameraZoom(int _inc, int _x, int _y) {
    camera.setCameraZoom(_inc, _x, _y);
  }
  void createCameraPivot(int _x, int _y) {
    camera.createCameraPivot(_x, _y);
  }
  void panCamera(int _cx, int _cy) {
    camera.panCamera(_cx, _cy);
  }
  void resetCameraPivot() {
    camera.resetCameraPivot();
  }
  void onClick(int _x, int _y) {
    ui.onClick(_x,_y); 
  }
  void onMouseDown(int _x, int _y) {
    ui.onMouseDown(_x,_y); 
  }
  void shiftDown(boolean _down) {
     ui.shiftDown(_down);
  }
  void onEscape() {
    ui.onEscape(); 
  }
  void addLine(int[] _line, boolean[] _activeTypes) {
    trackManager.addLine(_line,_activeTypes);
  }
  void removeLine(int[] _line, boolean[] _activeTypes) {
    trackManager.removeLine(_line,_activeTypes);
  }
  ArrayList<PhysicalLine> getAllPhysicalLines() {
    return trackManager.getAllPhysicalLines(); 
  }
  ArrayList<SceneryLine> getAllSceneryLines() {
    return trackManager.getAllSceneryLines(); 
  }
  
}

