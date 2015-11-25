import g4p_controls.*;

Environment environment;
GTextArea txtBox;

void setup() {
  size(1000, 800);
  ellipseMode(CENTER);
  strokeWeight(2);

  println("-=-=- FRHD Community Concept Editor V3.0 -=-=-");
  println("-=-=-         Developed by Sono          -=-=-");
  println("-=-=-                                    -=-=-");
  println("-=-=-        Libraries used: G4P         -=-=-");
  println();

  txtBox = new GTextArea (this, width/5, height/4, int(width/2), int(height/2), G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
  environment = new Environment("data.txt");
  
  
  
}

void draw() {
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


void mouseReleased() {
  if (mouseButton == RIGHT) {
    environment.resetCameraPivot();
  }
}

void mousePressed() {
  if (mouseButton == RIGHT) {
    environment.createCameraPivot(mouseX, mouseY);
  } else if (mouseButton == LEFT) {
    environment.onClick(mouseX, mouseY);
  }
}

void mouseDragged() {
  if (mouseButton == RIGHT) {
    environment.panCamera(mouseX, mouseY);
  } 
  if (mouseButton == LEFT) {
    environment.onMouseDown(mouseX, mouseY);
  }
}

void mouseWheel(MouseEvent event) {
  environment.setCameraZoom(event.getCount(), width, height);
}

void keyPressed() {
  // Disable exit on ESC
  if (key == 27) {
    environment.onEscape();
    key = 0;
  }

  if (keyCode == SHIFT) {
    environment.shiftDown(true);
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    environment.shiftDown(false);
  }
}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) { /* code */ }

