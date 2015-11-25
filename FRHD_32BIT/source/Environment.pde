


Camera camera;
TrackData trackManager;
UserInterface ui;
UndoRedo ur;

class Environment {

  Environment() {
    camera = new Camera(width/2, height/2, 1.0);
    trackManager = new TrackData("");
    ui = new UserInterface();
    ur = new UndoRedo(15);
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
    ui.onClick(_x, _y);
  }
  void onMouseDown(int _x, int _y) {
    ui.onMouseDown(_x, _y);
  }
  void onMouseDragged(int _x, int _y) {
    ui.onMouseDragged(_x, _y);
  }
  void shiftDown(boolean _down) {
    ui.shiftDown(_down);
  }
  void onEscape() {
    ui.onEscape();
  }

  void addLine(int[] _line, boolean[] _activeTypes, boolean _addNewEvent) {
    trackManager.addLine(_line, _activeTypes, _addNewEvent);
  }
  void addPowerup(int _x, int _y, int _angle, char _type, boolean _addNewEvent) {
    trackManager.addPowerup(_x, _y, _angle, _type, _addNewEvent);
  }
  void removeLine(int[] _line, boolean[] _activeTypes, boolean _addNewEvent) {
    trackManager.removeLine(_line, _activeTypes, _addNewEvent);
  }
  void removePowerup(int _x, int _y, int _angle, char _type, boolean _addNewEvent) {
    trackManager.removePowerup(_x, _y, _angle, _type, _addNewEvent);
  }
  void addEvent(char _type, String _p, String _s, String _pu, String _prevP, String _prevS, String _prevPU) {
    ur.addEvent(_type, _p, _s, _pu, _prevP, _prevS, _prevPU);
  }

  void undo() {
    ur.undo();
  }
  void redo() {
    ur.redo();
  }

  void setTrackData(String _data) {
    trackManager.setTrackData(_data);
  }
  String getTrackData() {
    return trackManager.getTrackData();
  }

  ArrayList<PhysicalLine> getAllPhysicalLines() {
    return trackManager.getAllPhysicalLines();
  }
  ArrayList<SceneryLine> getAllSceneryLines() {
    return trackManager.getAllSceneryLines();
  }
  ArrayList<Powerup> getAllPowerups() {
    return trackManager.getAllPowerups();
  }
}