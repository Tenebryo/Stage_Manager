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

    int x0, x1, y0, y1;
    x0 = tbX;
    x1 = teX;
    y0 = lineHeight*(int)(tbY/lineHeight);
    y1 = lineHeight*(int)(teY/lineHeight);

    if (y0 == y1) {
      g.rect(x0, y0, x1, y1+lineHeight);
    } else {
      g.rect(x0, y0, g.width, y0 + lineHeight);
      g.rect(0, y0 + lineHeight, g.width, y1);
      g.rect(0, y1, x1, y1 + lineHeight);
    }

    g.popMatrix();
  }

  PVector findNearestPoint(int x, int y)
  {
    return new PVector();
  }

  void update(int nx, int ny) {
    if (finished) return;
    eX = nx;
    eY = ny;

    //tbY = (lineHeight*((int)(bY/lineHeight)));
    //teY = (lineHeight*((int)(eY/lineHeight)));
    teY = eY;
    tbY = bY;
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
      if (h+l.textHeight >= sHeight) {
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
      if (h+l.textHeight >= sHeight) {
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
      if (h+l.textHeight >= sHeight) {
        return l;
      }
      h+=l.textHeight;
    }
    return null;
  }

  String cutOffStringAtLength(String s, int l, PGraphics g)
  {
    String result = "";
    String[] sarray = s.split(" ");
    for (int i = 0, w = 0; i < sarray.length; i++) {
      int wordWidth = int(g.textWidth(sarray[i]) + " ");
      if (w + wordWidth > l) {
        result += sarray[i] + " ";
        break;
      }
      result += sarray[i] + " ";
      w += wordWidth;
    }
    return result;
  }

  String beginStringAtLength(String s, int l, PGraphics g)
  {
    String result = " ";
    String[] sarray = s.split(" ");
    for (int i = 0, w = 0; i < sarray.length; i++) {
      int wordWidth = int(g.textWidth(sarray[i]) + " ");
      if (w + wordWidth > l) {
        result += sarray[i] + " ";
      }
      w += wordWidth;
    }
    return result;
  }

  //get the text of the selected string from the start 
  //of a selection point within the line to the end of the line
  String getLineSelectionStringAllFromStart(Line l, int relHeight, int xOffset, PGraphics g) {
    //which display line the select falls on
    int dLineIndex = int(relHeight/lineHeight);

    //the result string we will build
    String result = l.actor + ": ";

    //partial segment
    result += beginStringAtLength(l.displayLines.get(max(l.displayLines.size()-1,dLineIndex)), xOffset, g);

    //add the rest of the line
    for (int i = dLineIndex + 1; i < l.displayLines.size (); i++) {
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

    //partial line
    result += cutOffStringAtLength(l.displayLines.get(dLineIndex), xOffset, g);

    return result;
  }

  //get the text that is selected between two points within the line
  String getLineSelectionStringPartial(Line l, int relHeight0, int xOffset0, int relHeight1, int xOffset1, PGraphics g) {
    //which display line the select falls on
    int dLineIndex0 = int(relHeight0/lineHeight);
    int dLineIndex1 = int(relHeight1/lineHeight);

    //the result string we will build
    String result = l.actor + ": ";

    println("XOffset0:", xOffset0);
    println("XOffset1:", xOffset1);

    if (dLineIndex0 == dLineIndex1) {
      String[] sarray = l.displayLines.get(max(l.displayLines.size()-1,dLineIndex0)).split(" ");
      for (int i = 0, w = 0, t=0; i < sarray.length; i++) {
        int wordWidth = int(g.textWidth(sarray[i]) + " ");
        if (w + wordWidth > xOffset1) {
          result += sarray[i] + " ";
          println("Index:", i);
          break;
        } else if (w + wordWidth > xOffset0) {
          if (i!=0 && t==0) {
            result += "... ";
            t = 1;
          }
          result += sarray[i] + " ";
          println("Index:", i);
        }
        w += wordWidth;
      }
    } else {
      
      //beginning partial Line
      result += beginStringAtLength(l.displayLines.get(max(l.displayLines.size()-1,dLineIndex0)), xOffset0, g);

      //add the rest of the line
      for (int i = dLineIndex0 + 1; i < dLineIndex1; i++) {
        result += l.displayLines.get(i);
      }

      //ending partial Line
      result += cutOffStringAtLength(l.displayLines.get(max(l.displayLines.size()-1,dLineIndex1)), xOffset1, g);
    }

    return result;
  }

  void finish(PGraphics g) {
    int line0Index = getLineIndexFromHeight(tbY), 
    line0Offset = getSelectPositionFromHeight(tbY);
    int line1Index = getLineIndexFromHeight(teY), 
    line1Offset = getSelectPositionFromHeight(teY);

    println(line0Offset, line1Offset); 

    selected.clear();
    if (line0Index == line1Index)
    {
      selected.add(s.lines.get(line0Index));
      selectedText = getLineSelectionStringPartial(s.lines.get(line0Index), line0Offset, tbX, line1Offset, teX, g);
    } else
    {
      selected.add(s.lines.get(line0Index));
      selectedText = getLineSelectionStringAllFromStart(s.lines.get(line0Index), line0Offset, tbX, g);

      for (int i = line0Index+1; i < line1Index; i++) {
        Line ln = s.lines.get(i);
        selected.add(ln);
        selectedText += ("\n" + ln.actor + ": " + ln.text);
      }
      
      selected.add(s.lines.get(line1Index));
      selectedText += ("\n" + getLineSelectionStringAllToEnd(s.lines.get(line1Index), line1Offset, teX, g));
    }
    println(selectedText);
  }
}

