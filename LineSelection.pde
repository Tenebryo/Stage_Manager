//class to store information about a selected area of text
//this class houses the nastiest code (needed to find the selected string) 
class LineSelection {
  int bX, bY, eX, eY, tbY, teY, tbX, teX;
  ArrayList<Line> selected;
  String selectedText;
  boolean finished = true;
  Script s;

  LineSelection(int _bX, int _bY, Script _s) {
    eX = bX = _bX;
    eY = bY = _bY;
    update(_bX, _bY);
    s = _s;
    selected = new ArrayList();
    finished = false;
  }

  void draw(PGraphics g) {
    g.pushMatrix();

    g.fill(255, 0, 0, 100);
    g.noStroke();
    g.rectMode(CORNERS);

    if (tbY == teY) {
      g.rect(tbX, tbY, teX, teY+lineHeight);
    } else {
      g.rect(tbX, tbY, g.width, tbY + lineHeight);
      g.rect(0, tbY + lineHeight, g.width, teY);
      g.rect(0, teY, teX, teY + lineHeight);
    }

    g.popMatrix();
  }

  void update(int nx, int ny) {
    if (finished) return;
    eX = nx;
    eY = ny;

    tbY = (lineHeight*((int)(bY/lineHeight)));
    teY = (lineHeight*((int)(eY/lineHeight)));
    teX = eX;
    tbX = bX;

    if (teY < tbY || (teY == tbY && teX < tbX)) {
      int tmp = teY;
      teY = tbY;
      tbY = tmp;

      tmp = teX;
      teX = tbX;
      tbX = tmp;
    }
  }
  
  //gets the index of the line at height sHeight in the stack of Lines
  int getLineIndexFromHeight(int sHeight) {
    int h = 0;
    int i = 0;
    for (Line l : s.lines) {
      if(h+l.textHeight >= sHeight) {
        break;
      }
      h+=l.textHeight;
      i++;
    }
    return i;
  }
  
  //gets the vertical distance from the start of the line 
  //the selection point is in to the selection point
  int getSelectPositionFromHeight(int sHeight) {
    int h = 0;
    for (Line l : s.lines) {
      if(h+l.textHeight >= sHeight) {
        break;
      }
      h+=l.textHeight;
    }
    return sHeight - h;
  }
  
  //get the Line object that is at the selection point
  Line getLineFromHeight(int sHeight) {
    int h = 0;
    for (Line l : s.lines) {
      if(h+l.textHeight >= sHeight) {
        return l;
      }
      h+=l.textHeight;
    }
    return null;
  }
  
  //get the text of the selected string from the start 
  //of a selection point within the line to the end of the line
  String getLineSelectionStringAllFromStart(Line l, int relHeight, int xOffset, PGraphics g) {
    //which display line the select falls on
    int dLineIndex = int(relHeight/lineHeight);
    
    //the result string we will build
    String result = l.actor + ": ";
    
    //display line
    String dpLine = l.displayLines.get(dLineIndex);
    //last space index 0 and 1
    //keep track of the second to last ' ' found in the string
    int lSpaceI0 = 0, lSpaceI1 = 0;
    //add the segment of text
    for (int i = 0, w = 0; i < dpLine.length(); i++) {
      if (dpLine.charAt(i) == ' ') {
        lSpaceI0 = lSpaceI1;
        lSpaceI1 = i;
      }
      int charWidth = int(g.textWidth(dpLine.charAt(i)));
      if(w + charWidth < xOffset) {
        result += dpLine.substring(lSpaceI0);
        break;
      }
    }
    
    //add the rest of the line
    for (int i = dLineIndex + 1; i < l.displayLines.size(); i++) {
      result += l.displayLines.get(i);
    }
    
    return result;
  }
  
  //get all text that would be selected if selecting from
  //start of the line to a specific point within the line
  String getLineSelectionStringAllToEnd(Line l, int relHeight, int xOffset, PGraphics g) {
    //which display line the select falls on
    int dLineIndex = int(relHeight/lineHeight);
    
    //the result string we will build
    String result = l.actor + ": ";
    
    //add all lines until the one where the selection ends
    for (int i = 0; i < dLineIndex; i++) {
      result += l.displayLines.get(i);
    }
    
    //display line
    String dpLine = l.displayLines.get(dLineIndex);
    //add the segment of text
    for (int i = 0, w = 0; i < dpLine.length(); i++) {
      int charWidth = int(g.textWidth(dpLine.charAt(i)));
      if(w + charWidth < xOffset) {
        int spaceLoc = dpLine.substring(i).indexOf(' ');
        result += dpLine.substring(0, ((spaceLoc==-1)?dpLine.length():i+spaceLoc) );
        break;
      }
    }
    
    return result;
  }
  
  //get the text that is selected between two points within the line
  String getLineSelectionStringPartial(Line l, int relHeight0, int xOffset0, int relHeight1, int xOffset1, PGraphics g) {
    //which display line the select falls on
    int dLineIndex0 = int(relHeight0/lineHeight);
    int dLineIndex1 = int(relHeight1/lineHeight);
    
    //the result string we will build
    String result = l.actor + ": ";
    
    //display line
    String dpLine0 = l.displayLines.get(dLineIndex0);
    //last space index 0 and 1
    //keep track of the second to last ' ' found in the string
    int lSpaceI0 = 0, lSpaceI1 = 0;
    //add the segment of text
    for (int i = 0, w = 0; i < dpLine0.length(); i++) {
      if (dpLine0.charAt(i) == ' ') {
        lSpaceI0 = lSpaceI1;
        lSpaceI1 = i;
      }
      int charWidth = int(g.textWidth(dpLine0.charAt(i)));
      if(w + charWidth < xOffset0) {
        result += dpLine0.substring(lSpaceI0);
        break;
      }
    }
    
    //add the rest of the line
    for (int i = dLineIndex0 + 1; i < dLineIndex1; i++) {
      result += l.displayLines.get(i);
    }
    
    
    //display line
    String dpLine1 = l.displayLines.get(dLineIndex1);
    //add the last segment of text
    for (int i = 0, w = 0; i < dpLine1.length(); i++) {
      int charWidth = int(g.textWidth(dpLine1.charAt(i)));
      if(w + charWidth < xOffset1) {
        int spaceLoc = dpLine1.substring(i).indexOf(' ');
        result += dpLine1.substring(0, ((spaceLoc==-1)?dpLine1.length():i+spaceLoc) );
        break;
      }
    }
    
    return result;
  }

  void finish(PGraphics g) {
    selectedText = "";
    int selectBuf = 10;
    try {
      int h = 0;
      int i = -1;
      //find the line where the selection starts
      while (h < tbY) {
        i++;
        Line ln = s.lines.get(i);
        int lHeight = ln.textHeight;

        if (h + lHeight >= tbY) {
          int lineSelectStart = (int)((h+lHeight - tbY)/lineHeight);
          //space between lines has been selected
          if (lineSelectStart >= ln.displayLines.size()) {
            break;
          }

          //get the index within the entire string that the selection can start at
          int j;
          int lnStartIndex = 0;
          for (j = 0; j < lineSelectStart; j++) {
            lnStartIndex += ln.displayLines.get(j).length();
          }

          //get the character where the selection starts
          int dispLnLen = 0;
          String dispLn = ln.displayLines.get(lineSelectStart);
          for (j = 0; j < dispLn.length (); j++) {
            dispLnLen += dispLn.charAt(j);
            if (dispLnLen > tbX - 110) { //TODO: make less hard-coded, currently uses a number that could change and that this class does not have a way to access 
              break;
            }
          }
          lnStartIndex += j;

          //check if the end is within the same Line
          if (h + lHeight >= teY) {
            int lineSelectEnd = (int)((h+lHeight - teY)/lineHeight);

            //get the index within the entire string that the selection can start at
            int lnEndIndex = 0;
            for (j = 0; j < lineSelectEnd; j++) {
              lnEndIndex += ln.displayLines.get(j).length();
            }

            //get the character where the selection ends
            dispLnLen = 0;
            dispLn = ln.displayLines.get(lineSelectEnd);
            for (j = 0; j < dispLn.length (); j++) {
              dispLnLen += g.textWidth(dispLn.charAt(j));
              if (dispLnLen > tbX - 110) { //TODO: make less hard-coded, currently uses a number that could change and that this class does not have a way to access 
                break;
              }
            }
            lnEndIndex += j;
            //add the selection to the selected text from the start of the selection to the end of the selection and return (the entire selection is covered)
            //add ellipses and a bit extra of the text if there is text before the selection
            selectedText += ((lnStartIndex < selectBuf)?ln.actor + ": ":ln.actor+": ...") + 
              ln.text.substring(max(0, lnStartIndex-selectBuf), min(ln.text.length() - max(0, lnStartIndex-selectBuf), lnEndIndex-max(0, lnStartIndex-selectBuf)+selectBuf)) + 
              ((lnEndIndex + 20 >= ln.text.length())?"\n":"...");
            return;
          } else {
            //add the text to the selected string from the start to the end of the line.
            selectedText += ((lnStartIndex < selectBuf)?ln.actor + ": ":ln.actor+": ...") + ln.text.substring(max(0,lnStartIndex-selectBuf)) + "\n";
          }
        }

        h += lHeight;
      }

      //add intermediary lines
      while (h < eY || h < bY) {
        i++;
        Line ln = s.lines.get(i);
        h += ln.textHeight;
        if (h < eY || h < bY) {
          selectedText += ln.actor + ": " + ln.text + "\n";
        }
      }

      Line ln = s.lines.get(i);
      //add part/all of last line
      int lineSelectEnd = (int)((h+ln.textHeight - teY)/lineHeight);

      //get the index within the entire string that the selection can start at
      int lnEndIndex = 0;
      for (int j = 0; j < lineSelectEnd; j++) {
        lnEndIndex += ln.displayLines.get(j).length();
      }

      //get the character where the selection ends
      int j;
      int dispLnLen = 0;
      String dispLn = ln.displayLines.get(lineSelectEnd);
      for (j = 0; j < dispLn.length (); j++) {
        dispLnLen += g.textWidth(dispLn.charAt(j));
        if (dispLnLen > tbX - 110) { //TODO: make less hard-coded, currently uses a number that could change and that this class does not have a way to access (maybe make the actor draw space and the line draw space separate
          break;
        }
      }
      lnEndIndex += j;
      //add the selection to the selected text from the start of the selection to the end of the selection and return (the entire selection is covered)
      //add ellipses and a bit extra of the text if there is text before the selection
      selectedText += ln.actor + ": " + 
        ln.text.substring(0, min(ln.text.length(), lnEndIndex+selectBuf)) + 
        ((lnEndIndex + selectBuf >= ln.text.length())?"\n":"...");
      return;
    }
    catch(IndexOutOfBoundsException e) {
      println("Error:", e.getMessage());
    }
    finished = true;
    println("Selection Finished:\n", selectedText);
  }
}

