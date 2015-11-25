class Camera {

  int posX, posY, pivotX, pivotY, changeX, changeY;
  float zoom;

  Camera(int _posX, int _posY, float _zoom) {
    posX = _posX;
    posY = _posY;
    zoom = _zoom;
  }

  void update() {
    posX -= (pivotX - changeX)/zoom;
    posY -= (pivotY - changeY)/zoom;
    pivotX = changeX;
    pivotY = changeY;

  }

  int getPosX() {
    return posX;
  }
  int getPosY() {
    return posY;
  }
  float getZoom() {
    return zoom;
  }

  void createCameraPivot(int _x, int _y) {
    pivotX = _x;
    pivotY = _y;
    changeX = pivotX;
    changeY = pivotY;
  }

  void resetCameraPivot() {
    pivotX = changeX;
    pivotY = changeY;
  }

  void panCamera(int _changeX, int _changeY) {
    changeX = _changeX;
    changeY = _changeY;
  }

  void setCameraZoom(int _inc, int _x, int _y) {
    
    if (_inc == -1) 
      zoom+=0.1;
    else if (_inc == 1)
      zoom-=0.1;
    if (zoom < 0.1)
      zoom = 0.1;
    else if (zoom > 3)
      zoom = 3.0;
    
  }
}