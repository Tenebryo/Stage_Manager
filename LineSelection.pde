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
    try {
      int h = 0;
      int i = 0;
      //find the line where the selection starts
      while (h < tbY) {
        Line ln = s.lines.get(i);
        int lHeight = ln.textHeight;

        if (h + lHeight >= tbY) {
          int lineSelectStart = (int)((h+lHeight - tbY)/lineHeight);

          //get the index within the entire string that the selection can start at
          int lnStartIndex = 0;
          for (int j = 0; j < lineSelectStart; j++) {
            lnStartIndex += ln.displayLines.get(j).length();
          }

          //get the character where the selection starts
          int dispLnLen = 0;
          String dispLn = ln.displayLines.get(lineSelectStart);
          for (int j = 0; j < dispLn.length (); j++) {
            dispLnLen += dispLn.charAt(j);
            if (dispLnLen > tbX - 110) { //TODO: make less hard-coded, currently uses a number that could change and that this class does not have a way to access 
              lnStartIndex += j;
              break;
            }
          }

          //check if the end is within the same Line
          if (h + lHeight >= teY) {
            int lineSelectEnd = (int)((h+lHeight - teY)/lineHeight);

            //get the index within the entire string that the selection can start at
            int lnEndIndex = 0;
            for (int j = 0; j < lineSelectEnd; j++) {
              lnEndIndex += ln.displayLines.get(j).length();
            }

            //get the character where the selection ends
            dispLnLen = 0;
            dispLn = ln.displayLines.get(lineSelectEnd);
            for (int j = 0; j < dispLn.length (); j++) {
              dispLnLen += g.textWidth(dispLn.charAt(j));
              if (dispLnLen > tbX - 110) { //TODO: make less hard-coded, currently uses a number that could change and that this class does not have a way to access 
                lnEndIndex += j;
                break;
              }
            }
            //add the selection to the selected text from the start of the selection to the end of the selection and return (the entire selection is covered)
            selectedText += ((lnStartIndex < 20)?ln.actor.name + ": ":ln.actor.name+": ...") + ln.text.substring(max(0, lnStartIndex-20), lnEndIndex-max(0, lnStartIndex-20)) + (()?:);
            return;
          } else {
            //add the text to the selected string from the start to the end of the line.
            selectedText += (()?:) + ln.text.substring(lnStartIndex) + "\n";
          }
        }

        h += lHeight;
        i++;
      }
      selected.add(s.lines.get(i));
      i++;
      while (h < eY || h < bY) {
        h += s.lines.get(i).textHeight;
        selected.add(s.lines.get(i));
        i++;
      }
    }
    catch(IndexOutOfBoundsException e) {
    }
    finished = true;
  }
}

