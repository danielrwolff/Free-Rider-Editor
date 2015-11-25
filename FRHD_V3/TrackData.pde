class TrackData {

  String[] tempTrackData, physicalLineData, sceneryLineData, powerupData;

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

  void update() {
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

  void draw() {
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

  void setTrackData(String _data) {
    physicalLines.clear();
    sceneryLines.clear();
    powerups.clear();
    processData(_data);
  }

  void addLine(int[] _line, boolean[] _activeTypes) {

    if (_activeTypes[0]) {
      for (int i = 0; i < _line.length - 2; i+=2) {
        if (sqrt(sq(_line[i+2]-_line[i]) + sq(_line[i+3]-_line[i+1])) >= 2) 
          physicalLines.add(new PhysicalLine(_line[i], _line[i+1], _line[i+2], _line[i+3]));
      }
    } else {
      for (int i = 0; i < _line.length - 2; i+=2) {
        if (sqrt(sq(_line[i+2]-_line[i]) + sq(_line[i+3]-_line[i+1])) >= 2)
          sceneryLines.add(new SceneryLine(_line[i], _line[i+1], _line[i+2], _line[i+3]));
      }
    }

    /*
    switch(_type) {
     case 'P' :
     for (int i = 0; i < _line.length - 2; i+=2) {
     if (sqrt(sq(_line[i+2]-_line[i]) + sq(_line[i+3]-_line[i+1])) >= 2) 
     physicalLines.add(new PhysicalLine(_line[i], _line[i+1], _line[i+2], _line[i+3]));
     }
     break;
     case 'S' :
     for (int i = 0; i < _line.length - 2; i+=2) {
     if (sqrt(sq(_line[i+2]-_line[i]) + sq(_line[i+3]-_line[i+1])) >= 2)
     sceneryLines.add(new SceneryLine(_line[i], _line[i+1], _line[i+2], _line[i+3]));
     }
     break;
     }
     */
  }

  void removeLine(int[] _line, boolean[] _activeTypes) {
    if (_activeTypes[0]) {
      for (int i = 0; i < physicalLines.size (); i++) {
        if (physicalLines.get(i).points[0] == _line[0] && physicalLines.get(i).points[1] == _line[1] && physicalLines.get(i).points[2] == _line[2] && physicalLines.get(i).points[3] == _line[3]) {
          physicalLines.remove(i);
        }
      }
    }
    if (_activeTypes[1]) {
      for (int i = 0; i < sceneryLines.size (); i++) {
        if (sceneryLines.get(i).points[0] == _line[0] && sceneryLines.get(i).points[1] == _line[1] && sceneryLines.get(i).points[2] == _line[2] && sceneryLines.get(i).points[3] == _line[3]) {
          sceneryLines.remove(i);
        }
      }
    }
  }

  private String base32ToDec(String _data) {

    String[] givenData = split(_data, " ");
    String[] newData = new String[givenData.length];
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

  private int findIndex(char[] a, char b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] == b) {
        return i;
      }
    } 
    return 0;
  }

  private void processData(String _data) {

    tempTrackData = split(fixTrackData(_data), "#");

    String[] tempLine;
    StringList tempPhysicalLineData = new StringList();
    StringList tempSceneryLineData = new StringList();

    physicalLineData = split(tempTrackData[0], ",");
    for (int i = 0; i < physicalLineData.length; i++) {
      tempLine = split(physicalLineData[i], " ");
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
      tempLine = split(sceneryLineData[i], " ");
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
        powerups.add(new Goal(int(individualPowerupData[1]), int(individualPowerupData[2])));
        break;
      case 'B':
        powerups.add(new Boost(int(individualPowerupData[1]), int(individualPowerupData[2]), int(individualPowerupData[3])));
        break;
      case 'G':
        powerups.add(new Gravity(int(individualPowerupData[1]), int(individualPowerupData[2]), int(individualPowerupData[3])));
        break;
      case 'S':
        powerups.add(new SlowMo(int(individualPowerupData[1]), int(individualPowerupData[2])));
        break;
      case 'O':
        powerups.add(new Bomb(int(individualPowerupData[1]), int(individualPowerupData[2])));
        break;
      case 'C':
        powerups.add(new Checkpoint(int(individualPowerupData[1]), int(individualPowerupData[2])));
        break;
      }
    }
  }

  private String fixTrackData(String data) {
    if (data.equals("")) {
      return "-18 1i 18 1i##";
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

  ArrayList<PhysicalLine> getAllPhysicalLines() {
    return physicalLines;
  }
  ArrayList<SceneryLine> getAllSceneryLines() {
    return sceneryLines;
  }
}

