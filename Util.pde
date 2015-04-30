boolean p_rectIntersect(int px, int py, int rx, int ry, int rw, int rh) {
  return px >= rx && px < rx + rw && py >= ry && py < ry + rh;
}

String[] getDisplayLines(String s, int w, PGraphics g) {
  ArrayList<String> res = new ArrayList();
  
  int lineWidth = 0;
  String currentLine = "";
  for(String s1 : split(s, " ")) {
    float wordWidth = g.textWidth(s1);
    if(wordWidth > w) {
      res.add(currentLine);
      currentLine = "";
      lineWidth = 0;
      
      for(char c : s1.toCharArray()) {
        float charWidth = g.textWidth(c);
        if(lineWidth + charWidth > w) {
          res.add(currentLine);
          currentLine = str(c);
          lineWidth = int(charWidth);
          continue;
        }
        currentLine += c;
      }
    } else if(lineWidth + wordWidth > w) {
      res.add(currentLine);
      currentLine = s1;
      lineWidth = int(wordWidth);
    }
  }
  
  return res.toArray(new String[0]);
}
