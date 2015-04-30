import java.util.concurrent.Semaphore;

class ScriptLoader extends UIFullscreenObject {
  String script_filename;
  String output_filename;
  final Wrapper<File> script_file = new Wrapper(null);
  final Wrapper<Float> actorScrollAlpha = new Wrapper<Float>(0.0), 
  scriptScrollAlpha = new Wrapper<Float>(0.0);
  PGraphics listG, scriptG;
  Semaphore scriptMutex = new Semaphore(1, true);
  UIContainerElement actorMergeCheckBoxList;

  final Script script = new Script("");

  public ScriptLoader(Wrapper<UIObject> _p) {
    super(_p); 
    //*
    elem.add(new UIButton(W-330, 5, 100, 40, "Select Script").setOnClicked(new UIAction() {
      //Callback for when the button is clicked
      public void execute() {
        //set the file opened callback function to call this function
        onFileOpen = new UIFileParamAction() {
          public void execute(File f) {
            println(f.getAbsolutePath());
            //load lines from selected file
            String[] loadedLines = loadStrings(f.getAbsolutePath());
            script.filename = f.getAbsolutePath();
            try {
              //Make sure we are not using a list in two places at once
              //Search for "Java Semaphores" for more info
              scriptMutex.acquire();

              script.clear();
              actorMergeCheckBoxList.clear();
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

            script_file.value(f);
          }
        };
        //get file input location
        selectInput("Choose a Script File", "fileOpenedCallBack");
      }
    }
    ));//*/
    elem.add(new UIButton(W-220, 5, 100, 40, "Save Script").setOnClicked(new UIAction() {
      public void execute() {
        //set up callback to write to file
        onFileOpen = new UIFileParamAction() {
          public void execute(File f) {
            //write Script.toString() output to file
            String[] t = new String[1];
            t[0] = script.toString();
            saveStrings(f.getAbsolutePath(), t);
            //add file to recents
            t = loadStrings(recentScripts);
            //check if the file to be added to the recents list is already in the recents list
            boolean inRecents = false;
            int index = 0;
            for (String s : t) {
              if (s.equals(f.getAbsolutePath())) {
                inRecents = true;
                break;
              }
              index++;
            }
            //recreate list in the correct order and write to file
            if (inRecents) {
              for (int i = index; i > 0; i--) {
                t[i] = t[i-1];
              }
              t[0] = f.getAbsolutePath();
            } else if (t.length >= 10) {
              for (int i = t.length-1; i > 0; i--) {
                t[i] = t[i-1];
              }
              t[0] = f.getAbsolutePath();
              saveStrings(recentScripts, t);
            } else {
              String[] t1 = new String[t.length+1];
              t1[0] = f.getAbsolutePath();
              for (int i = 0; i < t.length; i++) {
                t1[i+1] = t[i];
              }
              saveStrings(recentScripts, t1);
            }
          }
        };
        //Get the location of the save the file
        selectOutput("Choose where to Save the Script", "fileOpenedCallBack");
      }
    }
    ));

    elem.add(new UIButton(W-110, 5, 100, 40, "Exit").setOnClicked(new UIAction() {
      public void execute() {
        exitUIObject();
      }
    }
    ));

    elem.add(new UIScrollBar(W/3 - 20, 90, 10, H - 100, 0.5, actorScrollAlpha));
    elem.add(new UIScrollBar(W - 20, 90, 10, H - 100, 0.5, scriptScrollAlpha));

    actorMergeCheckBoxList = new UIContainerElement() {void update(){}};
    elem.add(actorMergeCheckBoxList);

    listG = createGraphics(W/3 - 30, H - 100);
    scriptG = createGraphics(W*2/3 - 30, H - 100);
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
    g.fill(0x15, 0x65, 0xC0);
    //g.fill(0x0D, 0x47, 0xA1);
    g.text("Detected Actors", 10, 90);
    g.image(listG, 10, 90);
    //script display
    g.text("Parsed Script", w/2+10, 90);
    g.image(scriptG, w/3+10, 90);


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

    int actorDetailHeight = 96;
    //calculate how much scrolling is needed
    int extra = max(script.actors.size()*actorDetailHeight - listG.height, 0);
    int i = (int)(extra*-actorScrollAlpha.value());

    for (Actor a : script.actors) {
      listG.fill(0x0D, 0x47, 0xA1);
      listG.noStroke();
      listG.rect(10, i+10, listG.width-20, actorDetailHeight-16);
      listG.fill(0xE0);
      listG.text(a.name, 15, i+15);
      i += actorDetailHeight;
    }

    listG.endDraw();
  }

  void drawScript() {
    scriptG.beginDraw();
    //scriptG.textFont(font);

    scriptG.background(0x42);
    scriptG.stroke(0x61);
    scriptG.textSize(16);

    int totalH = 0;
    for (Line l : script.lines) { 
      totalH += l.textHeight;
    }

    int extra = max(totalH - scriptG.height, 0);

    scriptG.pushMatrix();

    scriptG.translate(0, (int)(extra*-scriptScrollAlpha.value()));

    for (Line l : script.lines) {
      l.draw(scriptG);
      scriptG.translate(0, l.textHeight);
    }

    scriptG.popMatrix();

    scriptG.line(105, 0, 105, scriptG.height);

    scriptG.endDraw();
  }
}

