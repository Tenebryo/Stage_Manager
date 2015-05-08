boolean p_rectIntersect(int px, int py, int rx, int ry, int rw, int rh) {
  return (px >= rx && px < rx + rw && py >= ry && py < ry + rh);
}

String[] getDisplayLines(String s, int w, PGraphics g) {
  ArrayList<String> res = new ArrayList();

  try {
    float lineWidth = 0;
    String currentLine = "";
    for (String s1 : split (s, " ")) {
      float wordWidth = g.textWidth(s1 + " ");
      if (wordWidth > w) {
        if(currentLine.equals("")) {
          res.add(currentLine);
        }
        currentLine = "";
        lineWidth = 0;

        for (char c : s1.toCharArray()) {
          float cLineWidth = g.textWidth(currentLine + c);
          if (cLineWidth > w) {
            res.add(currentLine);
            currentLine = str(c);
            lineWidth = g.textWidth(currentLine);
            continue;
          } else {
            currentLine += c;
            lineWidth = cLineWidth;
          }
        }
        currentLine += " ";
        lineWidth += g.textWidth(" ");
      } else if (lineWidth + wordWidth > w) {
        res.add(currentLine);
        currentLine = s1 + " ";
        lineWidth = wordWidth;
      } else {
        currentLine += s1 + " ";
        lineWidth += wordWidth;
      }
    }
    if(currentLine.length() > 0) {
      res.add(currentLine);
    }
  }
  catch (Exception e) {
  }
  return res.toArray(new String[res.size()]);
}

