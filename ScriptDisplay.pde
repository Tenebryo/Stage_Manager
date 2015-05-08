//add multi-ordering (by scene, by page, by line)

class ScriptDisplay extends UIFullscreenObject {
  //draw panel for the script text
  Window line, actor, scene, page;
  //make sure there aren't any data races
  Semaphore scriptMutex = new Semaphore(1, true);
  //script scroll percent
  final Wrapper<Float> scriptScrollAlpha = new Wrapper<Float>(0.0);
  final Wrapper<String> noteType = new Wrapper("");
  final Wrapper<ArrayList<UIElement>> wElems = new Wrapper<ArrayList<UIElement>>(null);

  //position of the script panel
  final int scriptX = 280;
  final int scriptY = 90;
  int scrollHeight;

  //script object
  Script script;
  final Wrapper<Script> wScript = new Wrapper<Script>(null);
  final Wrapper<Rehearsal> currentRehearsal = new Wrapper<Rehearsal>(null);
  int displayMode = 0;

  ScriptDisplay(Wrapper<UIObject> _p, Wrapper<Window> win, Script s) {
    super(_p, win);
    wElems.value(elem);
    loadScript(s);
    init();
  }

  void init() {

    scrollHeight = H-100;

    int dW = max(0, W-340);
    int x = W-ceil(0.50*dW)-20;

    line = new Window(x, 90, ceil(0.50*dW), scrollHeight, null);
    x -= ceil(0.11*dW); 
    actor = new Window(x, 90, ceil(0.11*dW), scrollHeight, null);
    x -= ceil(0.33*dW);
    scene = new Window(x, 90, ceil(0.33*dW), scrollHeight, null);
    x -= ceil(0.056*dW);
    page = new Window(x, 90, ceil(0.056*dW), scrollHeight, null);

    //exit button
    elem.add(new UIButton(W-110, 5, 100, 40, "Exit").setOnClicked(new UIAction() {
      public void execute() {
        exitUIObject();
      }
    }
    ));

    x -= 20;

    //add/choose current rehearsal
    elem.add(new UISuperButton(10, 90, x, 40, "Choose Rehearsal...") {
      UIElement rSelector;
      public void onClicked() {
        //create rehearsal dialogue
        final int _X = x, _Y = y, _W = w, _H = h;
        final Wrapper<UISuperButton> wButton = new Wrapper<UISuperButton>(this);
        final Wrapper<UIElement> wThis = new Wrapper<UIElement>(null);
        rSelector = new UIContainerElement() {
          int s = 0;
          public void init() {
            wThis.value(this);
            elems.add(new UISuperButton(_X, _Y, _W/3, _H, "<") {
              public void onClicked() {
                //advance to previous page of Rehearsals
                if (s-10 >= 0) {
                  s -= 10;
                  elems.clear();
                  init();
                }
              }
            }
            );
            elems.add(new UISuperButton(_X + _W/3, _Y, _W/3+1, _H, "New") {
              public void onClicked() {
                //add a new Rehearsal
                DateFormat df = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
                Date d = new Date();
                wScript.value().addRehearsal(new Rehearsal(df.format(d), "Rehearsal " + df.format(d)));
                wElems.value().remove(wThis.value());
              }
            }
            );
            elems.add(new UISuperButton(_X + _W*2/3, _Y, _W/3+1, _H, ">") {
              public void onClicked() {
                //advance to next page of Rehearsals
                if (s+10 < wScript.value().rehearsals.size()) {
                  s += 10;
                  elems.clear();
                  init();
                }
              }
            }
            );
            int i;
            for (i = 1; i < 10 && i+s < wScript.value ().rehearsals.size(); i++) {
              final Rehearsal r = wScript.value().rehearsals.get(i+s);
              elems.add(new UISuperButton(_X, _Y+_H*i, _W, _H, r.label) {
                public void onClicked() {
                  //set the current rehearsal to the this rehearsal
                  currentRehearsal.value(r);
                  //set the text of the button to the rehearsal's lable
                  wButton.value().text = r.label;
                  //stop displaying the rehearsal selector
                  wElems.value().remove(wThis.value());
                }
              }
              );
            }
          }
          public void update() {
            if (mouseX < _X || mouseY < _Y || mouseX > _X+_W || mouseY > _Y+min(11, wScript.value().rehearsals.size()-s+1)*_H) {
              wElems.value().remove(this);
            }
          }
        };
        wElems.value().add(rSelector);
      }
    }
    );

    //save script button
    elem.add(new UISuperButton(10, 140, x, 40, "Save Progress") {
      public void onClicked() {
        String[] t = new String[1];
        t[0] = script.toString();
        saveStrings(script.filename, t);
      }
    }
    );

    //add note button
    elem.add(new UISuperButton(10, 190, x, 40, "Choose Note Type...") {
      UIElement rSelector;
      public void onClicked() {
        final int _X = x, _Y = y, _W = w, _H = h;
        final Wrapper<UISuperButton> wButton = new Wrapper<UISuperButton>(this);
        final Wrapper<UIElement> wThis = new Wrapper<UIElement>(null);
        rSelector = new UIContainerElement() {
          int s = 0;
          public void init() {
            wThis.value(this);
            elems.add(new UISuperButton(_X, _Y, _W, _H, "Called for Line") {
              public void onClicked() {
                //stop displaying the note type selector
                wElems.value().remove(wThis.value());
                //change the button text to the selected type
                wButton.value().text = "Called for Line";
                //set flag for current note type
                noteType.value("Called for Line Note");
              }
            }
            );
            elems.add(new UISuperButton(_X, _Y + _H, _W, _H, "Missed Cue") {
              public void onClicked() {
                //stop displaying the note type selector
                wElems.value().remove(wThis.value());
                //change the button text to the selected type
                wButton.value().text = "Missed Cue";
                //set flag for current note type
                noteType.value("Missed Cue Note");
              }
            }
            );
            elems.add(new UISuperButton(_X, _Y + _H + _H, _W, _H, "Skipped") {
              public void onClicked() {
                //stop displaying the note type selector
                wElems.value().remove(wThis.value());
                //change the button text to the selected type
                wButton.value().text = "Skipped";
                //set flag for current note type
                noteType.value("Skipped Note");
              }
            }
            );
            elems.add(new UISuperButton(_X, _Y + _H + _H + _H, _W, _H, "Custom") {
              public void onClicked() {
                //stop displaying the note type selector
                wElems.value().remove(wThis.value());
                //change the button text to the selected type
                wButton.value().text = "Custom";
                //set flag for current note type
                noteType.value("Custom Note");
              }
            }
            );
          }
          public void update() {
            if (mouseX < _X || mouseY < _Y || mouseX > _X+_W || mouseY > _Y+4*_H) {
              //close the note type selector if the mouse leaves the area
              wElems.value().remove(this);
            }
          }
        };
        wElems.value().add(rSelector);
      }
    }
    );

    final Wrapper<UITextBox> wTextBox = new Wrapper<UITextBox>(new UITextBox(10, 240, x, H-400, "Enter Note Description...") {
    }
    );
    final Wrapper<UIObject> wScriptDisplay = new Wrapper<UIObject>(this);

    elem.add(wTextBox.value());

    elem.add(new UISuperButton(10, H-100, x, 40, "Create Note") {
      public void onClicked() {
        if (currentRehearsal.value() == null) {
          next.value(new UIPopupMsgBoxObject(wScriptDisplay.value().next, wWin, "You Must Select a Rehearsal", int(0.375*W), int(0.375*H), int(W/4.0), int(H/4.0)){
            int lifetime = 300;
            public boolean test() {
              return (lifetime-- < 0);
            }
          });
          println("Error: You Must Select a Rehearsal");
        } else if (noteType.equals("")) {
          next.value(new UIPopupMsgBoxObject(wScriptDisplay.value().next, wWin, "You Must Select a Note Type", int(0.375*W), int(0.375*H), int(W/4.0), int(H/4.0)));
          println("Error: You Must Select a Note Type");
        } else if (selected == null) {
          next.value(new UIPopupMsgBoxObject(wScriptDisplay.value().next, wWin, "You Must Select Some Text", int(0.375*W), int(0.375*H), int(W/4.0), int(H/4.0)));
          println("Error: You Must Select Some Text");
        } else {
          currentRehearsal.value().addNote(new Note(noteType.value(), wTextBox.value().text, selected.selectedText, 0, 0, selected.selected));
          wTextBox.value().setText("");
          println("Note Created!");
        }
      }
    }
    );

    elem.add(new UIScrollBar(W - 20, 90, 10, H - 100, 0.5, scriptScrollAlpha));
  }

  void loadScript(Script s) {
    script = s;
    wScript.value(s);
  }

  void drawSelf(int w, int h, PGraphics g) {
    g.background(0x21);

    if (selected != null && selected.finished) {
      g.textAlign(LEFT, BOTTOM);
      g.text(selected.selectedText, W-10, H-10);
    }

    renderLines(line.getGraphics());
    line.draw(g);
    renderActors(actor.getGraphics());
    actor.draw(g);
    renderScenes(scene.getGraphics());
    scene.draw(g);
    renderPages(page.getGraphics());
    page.draw(g);
    super.drawSelf(w, h, g);
  }

  void renderLines(PGraphics g) {
    g.beginDraw();

    g.background(0x42);
    g.stroke(0x61);

    g.pushMatrix();

    g.textSize(16);

    try {

      scriptMutex.acquire();

      int i = getScriptScrollPos();
      g.translate(5, -i);


      if (selected != null) {
        selected.draw(g);
      }

      g.fill(0xE0);

      for (Line l : script.lines) {
        l.drawText(g);
        g.translate(0, l.textHeight);
      }

      scriptMutex.release();
    } 
    catch(InterruptedException e) {
    }

    g.popMatrix();

    g.line(0, 0, 0, g.height);

    g.endDraw();
  }

  void renderActors(PGraphics g) {
    g.beginDraw();

    g.background(0x42);
    g.stroke(0x61);

    g.pushMatrix();

    g.textSize(16);

    try {

      scriptMutex.acquire();

      int i = getScriptScrollPos();
      g.translate(-5, -i);

      g.fill(0xE0);

      for (Line l : script.lines) {
        l.drawActor(g);
        g.translate(0, l.textHeight);
      }

      scriptMutex.release();
    } 
    catch(InterruptedException e) {
    }

    g.popMatrix();

    g.line(0, 0, 0, g.height);

    g.endDraw();
  }

  void renderScenes(PGraphics g) {
    g.beginDraw();

    g.background(0x42);
    g.stroke(0x61);

    g.pushMatrix();

    g.textSize(16);

    try {

      scriptMutex.acquire();

      int i = getScriptScrollPos();
      g.translate(-5, -i);

      g.fill(0xE0);

      for (Scene s : script.scenes) {
        for (int j = 0; j < s.lines.get (0); j++) {
          g.translate(0, script.lines.get(j).textHeight);
        } 
        s.drawScene(g);
      }

      scriptMutex.release();
    } 
    catch(InterruptedException e) {
    }

    g.popMatrix();

    g.line(0, 0, 0, g.height);

    g.endDraw();
  }

  void renderPages(PGraphics g) {
    g.beginDraw();

    g.background(0x42);

    g.stroke(0x61);

    g.pushMatrix();

    g.textSize(16);

    try {

      scriptMutex.acquire();

      int i = getScriptScrollPos();
      g.translate(-5, -i);

      g.fill(0xE0);

      for (Page p : script.pages) {
        for (int j = 0; j < p.lines.get (0); j++) {
          g.translate(0, script.lines.get(j).textHeight);
        }
        p.drawPage(g);
      }

      scriptMutex.release();
    } 
    catch(InterruptedException e) {
    }

    g.popMatrix();

    g.line(0, 0, 0, g.height);

    g.endDraw();
  }

  int getScriptScrollPos() {
    int totalH = 0;
    for (Line l : script.lines) { 
      totalH += l.textHeight;
    }

    int extra = max(totalH - scrollHeight, 0);
    int ret = (int)(extra*scriptScrollAlpha.value());
    return ret;
  }

  int getScriptMouseX() {
    return mouseX - line.x;
  }

  int getScriptMouseY() {
    return mouseY - line.y + getScriptScrollPos();
  }

  LineSelection selected;

  //code to select text
  void selfMousePressed() {
    if (p_rectIntersect(mouseX, mouseY, line.x, line.y, line.w, line.h)) {
      int y = getScriptMouseY(), x = getScriptMouseX();
      selected = new LineSelection(x, y, script);
    } else {
      selected = null;
    }
  }

  void selfMouseDragged() {
    if (selected != null && p_rectIntersect(mouseX, mouseY, line.x, line.y, line.w, line.h)) {
      try {
        scriptMutex.acquire();
        int y = getScriptMouseY(), x = getScriptMouseX();
        selected.update(x, y);
        scriptMutex.release();
      } 
      catch(InterruptedException e) {
      }
    }
  }

  void selfMouseReleased() {
    if (selected != null) {
      try {
        scriptMutex.acquire();
        selected.finish(line.getGraphics());
        scriptMutex.release();
      } 
      catch(InterruptedException e) {
      }
    }
  }
}

