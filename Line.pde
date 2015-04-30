class Line {
  String text;
  String actor;
  ArrayList<String> displayLines;
  int numLines, textHeight, lineNum;
  int ypos = 0, hightlightStart = 0, highlightEnd = 0; 
  PGraphics lastG;

  Line(String a, String t, int lNum) {
    displayLines = new ArrayList();
    text = t;
    actor = a;
    lineNum = lNum;
  }

  String toString() {
    String ret = "Line\n" +  actor + "\n" + text;
    return ret;
  }

  Line(ArrayList<String> strs) throws Exception {
    if (!strs.get(0).equals("Line")) {
      throw new Exception("Line");
    }
    displayLines = new ArrayList();
    strs.remove(0);
    actor = strs.remove(0);
    text = strs.remove(0);
  }

  void splitLines(PGraphics g) {
    String cl = "";
    int w = g.width-110;

    displayLines.clear();
    String[] t = splitTokens(text, " ");
    for (String s : t) {
      float t0 = g.textWidth(s), t1 = g.textWidth(cl);
      if (t0 > w) {

        displayLines.add(cl);
        cl = "";
        String temp = s;
        while (g.textWidth (temp) > w) {
          int i = 0;
          while (g.textWidth (temp.substring (0, i)) < w) {
            i++;
          }
          temp = temp.substring(i-1);
          displayLines.add(temp.substring(0, i-1));
        }
        cl = temp;
      } else if (t0 + t1 > w) {

        displayLines.add(cl);
        cl = s;
      } else {
        cl += " " + s;
      }
    }

    displayLines.add(cl);
    displayLines.add("");

    textHeight = (displayLines.size())*lineHeight;
    numLines = displayLines.size();
  }

  void draw(PGraphics g) {
    if (lastG == null || lastG != g) {
      splitLines(g);
      lastG = g;
    }
    g.textAlign(RIGHT, TOP);
    g.text(actor, 100, ypos);
    g.textAlign(LEFT, TOP);
    int h = ypos;
    for (String s : displayLines) { 
      g.text(s, 110, h);
      h += lineHeight;
    }
  }
  
  void drawText(PGraphics g) {
    if (lastG == null || lastG != g) {
      splitLines(g);
      lastG = g;
    }
    g.textAlign(LEFT, TOP);
    int h = 0;
    for (String s : displayLines) { 
      g.text(s, 0, h);
      h += lineHeight;
    }
  }
  
  void drawActor(PGraphics g) {
    g.textAlign(RIGHT, TOP);
    g.text(actor, g.width, 0);
  }
}
