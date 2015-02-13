import java.util.concurrent.Semaphore;

class ScriptLoader extends UIFullscreenObject {
  String script_filename;
  String output_filename;
  final Wrapper<File> script_file = new Wrapper(null);
  final Wrapper<Float> actorScrollAlpha = new Wrapper<Float>(0.0), 
  scriptScrollAlpha = new Wrapper<Float>(0.0);
  PGraphics listG, scriptG;
  Semaphore scriptMutex = new Semaphore(1, true);

  final Script script = new Script();

  public ScriptLoader(UIObject _p) {
    super(_p); 
    //*
    elem.add(new UIButton(200, 10, 50, 30, "Select\nScript").setOnClicked(new UIAction() {
      //Callback for when the button is clicked
      public void execute() {
        //set the file opened callback function to call this function
        onFileOpen = new UIFileParamAction() {
          public void execute(File f) {
            println(f.getAbsolutePath());
            //load lines from selected file
            String[] loadedLines = loadStrings(f.getAbsolutePath());
            try {
              //Make sure we are not using a list in two places at once
              //Search for "Java Semaphores" for more info
              scriptMutex.acquire();

              script.clear();
              int lineNum = 0;

              for (String str : loadedLines) {

                String[] scene = match(str, "^\\[([A-Za-z0-9 ]+)\\][^{]*\\{([^}]+)\\}");
                String[] page = match(str, "^([0-9]+)$");

                if (scene != null) {
                  //println("New Scene");
                  //if a new scene is detected
                  //matches represent the title and description of the scene
                  script.addScene(new Scene(scene[1], scene[2]));
                } else if (page != null) {
                  //println("New Page");
                  //if a new page is detected
                  script.addPage(new Page(Integer.parseInt(page[1])));
                } else {
                  //println("New Line");
                  //if a new line is detected
                  //separate actor name and 
                  String[] splitLine = match(str, "^([A-Za-z0-9 ]+)[:.\t](.*)$");
                  if (splitLine != null) {
                    //println("Loaded line");
                    script.addActor(new Actor(trim(splitLine[1])));
                    script.appendLine(new Line(trim(splitLine[1]), trim(splitLine[2]), lineNum));
                    lineNum++;
                  } else {
                    //println("Malformed line");
                  }
                }
              }

              scriptMutex.release();
            } 
            catch (Exception e) {
            }

            script_file.val = f;
          }
        };
        selectInput("Choose a Script File", "fileOpenedCallBack");
      }
    }
    ));//*/
    elem.add(new UIScrollBar(W/2 - 20, 90, 10, H - 100, 0.5, actorScrollAlpha));
    elem.add(new UIScrollBar(W - 20, 90, 10, H - 100, 0.5, scriptScrollAlpha));

    listG = createGraphics(W/2 - 30, H - 100);
    scriptG = createGraphics(W/2 - 30, H - 100);
  }

  void drawSelf(int w, int h, PGraphics g) {
    g.background(0x21);

    try {
      scriptMutex.acquire();
      drawActors();
      drawScript();
      scriptMutex.release();
    } 
    catch (Exception e) {
    }
    //actor List
    //TODO: be able to merge
    g.textAlign(LEFT, BOTTOM);
    g.textSize(24);
    //g.fill(0x0D, 0x47, 0xA1);
    g.text("Detected Actors", 10, 90);
    g.image(listG, 10, 90);
    //script display
    g.text("Parsed Script", w/2+10, 90);
    g.image(scriptG, w/2+10, 90);


    g.fill(0x0D, 0x47, 0xA1);
    g.noStroke();
    g.rect(0, 0, w, 50);
    super.drawSelf(w, h, g);
  }

  void drawActors() {
    listG.beginDraw();

    //listG.textFont(font);
    listG.background(0x42);
    listG.stroke(0xE0);
    listG.textSize(16);
    listG.textAlign(LEFT, TOP);

    //calculate how much scrolling is needed
    int extra = max(script.actors.size()*32 - listG.height, 0);
    int i = (int)(extra*-actorScrollAlpha.val);

    for (Actor a : script.actors) {
      listG.text(a.name, 10, i+10);
      i += 32;
    }

    listG.endDraw();
  }

  void drawScript() {
    scriptG.beginDraw();
    //scriptG.textFont(font);

    scriptG.background(0x42);
    scriptG.stroke(0x61);
    scriptG.textSize(16);

    int maxWidth = scriptG.width-110;

    int totalH = 0;
    for (Line l : script.lines) { 
      l.calculateHeights(maxWidth, 24, scriptG); 
      totalH += l.textHeight;
    }

    int extra = max(totalH - scriptG.height, 0);
    int i = (int)(extra*-scriptScrollAlpha.val);

    for (Line l : script.lines) {
      scriptG.textAlign(RIGHT, TOP);
      scriptG.text(l.actor, 100, i+10);
      scriptG.textAlign(LEFT, TOP);
      scriptG.text(l.text, 110, i+10, maxWidth, l.textHeight);
      i += l.textHeight;
    }

    scriptG.line(105, 0, 105, scriptG.height);

    scriptG.endDraw();
  }
}

