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

  void addEvent(char _type, String _p, String _s, String _pu, String _prevP, String _prevS, String _prevPU) {
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

  void undo() {

    if (currentEvent == events.length)
      return;

    try {
      switch(events[currentEvent][0].charAt(0)) {
      case 'A':
        activeTypes[0] = true;
        physicalLines = split(events[currentEvent][1], ",");
        for (int i = 0; i < physicalLines.length; i++) {
          tempData = int(split(physicalLines[i], " "));
          environment.removeLine(tempData, activeTypes, false);
        }
        activeTypes[0] = false;
        activeTypes[1] = true;
        sceneryLines = split(events[currentEvent][2], ",");
        for (int i = 0; i < sceneryLines.length; i++) {
          tempData = int(split(sceneryLines[i], " "));
          environment.removeLine(tempData, activeTypes, false);
        }
        activeTypes[1] = false;
        activeTypes[2] = true;
        powerups = split(events[currentEvent][3], ",");
        for (int i = 0; i < powerups.length; i++) {
          tempData = int(split(powerups[i], " "));
          environment.removePowerup(tempData[1], tempData[2], tempData[3], powerups[i].charAt(0), false);
        }
        break;
      case 'E':
        activeTypes[0] = true;
        physicalLines = split(events[currentEvent][1], ",");
        for (int i = 0; i < physicalLines.length; i++) {
          tempData = int(split(physicalLines[i], " "));
          environment.addLine(tempData, activeTypes, false);
        }
        activeTypes[0] = false;
        activeTypes[1] = true;
        sceneryLines = split(events[currentEvent][2], ",");
        for (int i = 0; i < sceneryLines.length; i++) {
          tempData = int(split(sceneryLines[i], " "));
          environment.addLine(tempData, activeTypes, false);
        }
        activeTypes[1] = false;
        activeTypes[2] = true;
        powerups = split(events[currentEvent][3], ",");
        for (int i = 0; i < powerups.length; i++) {
          tempData = int(split(powerups[i], " "));
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


  void redo() {

    if (currentEvent == 0)
      return;

    try {
      switch(events[currentEvent-1][0].charAt(0)) {
      case 'A':
        activeTypes[0] = true;
        physicalLines = split(events[currentEvent-1][1], ",");
        for (int i = 0; i < physicalLines.length; i++) {
          tempData = int(split(physicalLines[i], " "));
          environment.addLine(tempData, activeTypes, false);
        }
        activeTypes[0] = false;
        activeTypes[1] = true;
        sceneryLines = split(events[currentEvent-1][2], ",");
        for (int i = 0; i < sceneryLines.length; i++) {
          tempData = int(split(sceneryLines[i], " "));
          environment.addLine(tempData, activeTypes, false);
        }
        activeTypes[1] = false;
        activeTypes[2] = true;
        powerups = split(events[currentEvent-1][3], ",");
        for (int i = 0; i < powerups.length; i++) {
          tempData = int(split(powerups[i], " "));
          environment.addPowerup(tempData[1], tempData[2], tempData[3], powerups[i].charAt(0), false);
        }
        break;
      case 'E':
        activeTypes[0] = true;
        physicalLines = split(events[currentEvent-1][1], ",");
        for (int i = 0; i < physicalLines.length; i++) {
          tempData = int(split(physicalLines[i], " "));
          environment.removeLine(tempData, activeTypes, false);
        }
        activeTypes[0] = false;
        activeTypes[1] = true;
        sceneryLines = split(events[currentEvent-1][2], ",");
        for (int i = 0; i < sceneryLines.length; i++) {
          tempData = int(split(sceneryLines[i], " "));
          environment.removeLine(tempData, activeTypes, false);
        }
        activeTypes[1] = false;
        activeTypes[2] = true;
        powerups = split(events[currentEvent-1][3], ",");
        for (int i = 0; i < powerups.length; i++) {
          tempData = int(split(powerups[i], " "));
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