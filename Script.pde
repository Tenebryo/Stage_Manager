class Script {
  String filename;
  ArrayList<Scene> scenes;
  ArrayList<Page> pages;
  ArrayList<Line> lines, unPaged, unScened;
  ArrayList<Actor> actors;
  ArrayList<Rehearsal> rehearsals;

  int scriptHeight = 0;

  //empty constructor
  Script (String filename) {
    this.filename = filename;
    scenes = new ArrayList();
    pages  = new ArrayList();
    lines  = new ArrayList();
    actors = new ArrayList();
    unPaged  = new ArrayList();
    unScened = new ArrayList();
    rehearsals = new ArrayList();
  }

  //this constructor builds from an array of strings representing the lines
  //of an appropriately formatted script file
  Script(ArrayList<String> strs, String filename) throws Exception {

    this.filename = filename;
    scenes = new ArrayList();
    pages  = new ArrayList();
    lines  = new ArrayList();
    actors = new ArrayList();
    unPaged  = new ArrayList();
    unScened = new ArrayList();
    rehearsals = new ArrayList();

    if (!strs.get(0).equals("Script")) {
      throw new Exception("Script");
    }

    strs.remove(0);
    int n = int(strs.remove(0));
    println(n, "Lines...");
    for (int i = 0; i < n; i++) {
      this.appendLine(new Line(strs));
    }

    n = int(strs.remove(0));
    println(n, "Scenes...");
    for (int i = 0; i < n; i++) {
      this.addScene(new Scene(strs));
    }

    n = int(strs.remove(0));
    println(n, "Pages...");
    for (int i = 0; i < n; i++) {
      this.addPage(new Page(strs));
    }

    n = int(strs.remove(0));
    println(n, "Actors...");
    for (int i = 0; i < n; i++) {
      this.addActor(new Actor(strs));
    }
    
    n = int(strs.remove(0));
    println(n, "Rehearsals...");
    for (int i = 0; i < n; i++) {
      this.addRehearsal(new Rehearsal(strs, this));
    }

    println("Done!");
  }

  String toString() {
    String obj = "Script\n";

    obj += lines.size() + "\n";
    for (Line l : lines) {
      obj += l + "\n";
    }

    obj += scenes.size() + "\n";
    for (Scene s : scenes) {
      obj += s + "\n";
    }

    obj += pages.size() + "\n";
    for (Page p : pages) {
      obj += p + "\n";
    }

    obj += actors.size() + "\n";
    for (Actor a : actors) {
      obj += a + "\n";
    }
    
    obj += rehearsals.size() + "\n";
    for (Rehearsal r : rehearsals) {
      obj += r + "\n";
    }

    return obj;
  }

  void appendLine(Line l) {
    lines.add(l);
    if (scenes.size() > 0) {
      scenes.get(scenes.size()-1).addLine(l);
    } else {
      unScened.add(l);
    }
    if (pages.size() > 0) {
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

  boolean addActor(Actor a) {
    for (Actor t : actors) {
      if (t.name.equals(a.name)) {
        return false;
      }
    }
    actors.add(a);
    return true;
  }

  void clear() {
    scenes.clear();
    pages.clear();
    lines.clear();
    actors.clear();
    unPaged.clear();
    unScened.clear();
  }
  
  void addRehearsal(Rehearsal r) {
    rehearsals.add(0, r);
  }
}

