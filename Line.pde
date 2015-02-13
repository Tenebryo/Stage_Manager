class Script {
  ArrayList<Scene> scenes;
  ArrayList<Page> pages;
  ArrayList<Line> lines, unPaged, unScened;
  ArrayList<Actor> actors;
  
  Script () {
    scenes = new ArrayList();
    pages  = new ArrayList();
    lines  = new ArrayList();
    actors = new ArrayList();
    unPaged  = new ArrayList();
    unScened = new ArrayList();
  }
  
  void fromString(String str) {
    
  }
  
  String toString() {
    String obj = "";
    
    obj += line.size();
    for(Line l : lines) {
      obj += l + "\n";
    }
    
    obj += scenes.size();
    
    obj += pages.size();
    
    
    return obj;
  }
  
  void appendLine(Line l) {
    lines.add(l);
    if(scenes.size() > 0) {
      scenes.get(scenes.size()-1).addLine(l);
    } else {
      unScened.add(l);
    }
    if(pages.size() > 0) {
      pages.get(pages.size()-1).addLine(l);
    } else {
      unPaged.add(l);
    }
  }
  
  void addScene(Scene s) {
    scenes.add(s);
  }
  
  void addPage(Page p) {
    pages.add(p);
  }
  
  void addActor(Actor a) {
    for (Actor t : actors) {
      if (t.name.equals(a.name)) {
        return;
      }
    }
    actors.add(a);
  }
  
  void clear() {
    scenes.clear();
    pages.clear();
    lines.clear();
    actors.clear();
    unPaged.clear();
    unScened.clear();
  }
}

class Scene {
  ArrayList<Line> lines;
  String title, description;
  
  Scene(String _title, String _desc) {
    title = _title;
    description = _desc;
    lines = new ArrayList();
  }
  
  void addLine(Line l) {
    lines.add(l);
  }
}

class Actor {
  String name;
  
  Actor(String _name) {
    name = _name;
  }
}

class Page {
  ArrayList<Line> lines;
  int pageNumber;
  
  Page(int _pgnum) {
    pageNumber = _pgnum;
    lines = new ArrayList();
  }
  
  void addLine(Line l) {
    lines.add(l);
  }
}

class Line {
  String text;
  String actor;
  int numLines, textHeight, lineNum;
  
  Line(String a, String t, int lineNum) {
    text = t;
    actor = a;
  }
  void calculateHeights(int w, int th, PGraphics g) {
    numLines = numLinesHeight(text, w, g);
    textHeight = (numLines*th) + 10;
  }
  
  String toString() {
    return actor + "\n" + text;
  }
}

int numLinesHeight(String str, int w, PGraphics g) {
  String[] t = splitTokens(str, " ");
  int h = 1;
  float lineW = 0;
  for(String s : t) {
    float wid = g.textWidth(s);
    if(wid > w) {
      h++;
      float strw=0;
      for(char c : s.toCharArray()) {
        float cwid = g.textWidth(c);
        if(strw + cwid > w) {
          strw = cwid;
          h++;
        } else {
          strw += cwid;
        }
      } 
      
      lineW = strw;
    } else if(lineW + wid > w) {
      h++;
      lineW = wid;
    }else {
      lineW += wid;
    }
  }
  return max(h, 1);
}
