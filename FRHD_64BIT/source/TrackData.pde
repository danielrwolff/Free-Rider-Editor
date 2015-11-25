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

  //--------------------------------------------------------------------\\

  // // // // // // // // // // getTrackData \\ \\ \\ \\ \\ \\ \\ \\ \\ \\

  //--------------------------------------------------------------------\\

  String getTrackData() {

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

  void addLine(int[] _line, boolean[] _activeTypes, boolean _addNewEvent) {
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

  void removeLine(int[] _line, boolean[] _activeTypes, boolean _addNewEvent) {
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

  void addPowerup(int _x, int _y, int _angle, char _type, boolean _addNewEvent) {
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

  void removePowerup(int _x, int _y, int _angle, char _type, boolean _addNewEvent) {
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
        value = abs(int(givenData[i]));
        if (value == 0) {
          newData[i] = "0";
          break;
        }

        for (int k = floor (log (value)/log(32)); k >= 0; k--) {
          base32 += alphabet32[int(value / pow(32, k))];
          value = int(value % pow(32, k));
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
      case 'V':
        powerups.add(new Vehicle(int(individualPowerupData[1]), int(individualPowerupData[2])));
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

  ArrayList<PhysicalLine> getAllPhysicalLines() {
    return physicalLines;
  }
  ArrayList<SceneryLine> getAllSceneryLines() {
    return sceneryLines;
  }
  ArrayList<Powerup> getAllPowerups() {
    return powerups;
  }
}