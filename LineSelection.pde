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

