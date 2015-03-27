//add multi-ordering (by scene, by page, by line)

class ScriptDisplay extends UIFullscreenObject {
  //draw panel for the script text
  PGraphics scriptGraphics;
  //make sure there aren't any data races
  Semaphore scriptMutex = new Semaphore(1, true);
  //script scroll percent
  final Wrapper<Float> scriptScrollAlpha = new Wrapper<Float>(0.0);

  //position of the script panel
  final int scriptX = 280;
  final int scriptY = 90;

  //script object
  Script script;
  int displayMode = 0;

  ScriptDisplay(Wrapper<UIObject> _p) {
    super(_p);
    scriptGraphics = createGraphics(width - 300, height - 100);

    elem.add(new UIButton(W-110, 5, 100, 40, "Exit").setOnClicked(new UIAction() {
      public void execute() {
        exitUIObject();
      }
    }
    ));

    elem.add(new UIScrollBar(W - 20, 90, 10, H - 100, 0.5, scriptScrollAlpha));
  }

  void loadScript(Script s) {
    script = s;
  }

  void drawSelf(int w, int h, PGraphics g) {
    g.background(0x21);

    renderScript(scriptGraphics);
    g.image(scriptGraphics, scriptX, scriptY);
    super.drawSelf(w, h, g);
  }

  void renderScript(PGraphics g) {
    g.beginDraw();

    g.background(0x42);

    g.stroke(0x61);

    g.pushMatrix();

    g.textSize(16);

    try {

      scriptMutex.acquire();

      int i = getScriptScrollPos(g);
      g.translate(0, -i);


      if (selected != null) {
        selected.draw(g);
      }
      
      g.fill(0xE0);

      for (Line l : script.lines) {
        l.draw(g);
        g.translate(0, l.textHeight);
      }

      scriptMutex.release();
    } 
    catch(InterruptedException e) {
    }

    g.popMatrix();

    g.line(105, 0, 105, g.height);

    g.endDraw();
  }

  int getScriptScrollPos(PGraphics g) {
    int totalH = 0;
    for (Line l : script.lines) { 
      totalH += l.textHeight;
    }

    int extra = max(totalH - g.height, 0);
    int ret = (int)(extra*scriptScrollAlpha.value());
    return ret;
  }

  int getScriptMouseX() {
    return mouseX - scriptX;
  }

  int getScriptMouseY() {
    return mouseY - scriptY + getScriptScrollPos(scriptGraphics);
  }

  LineSelection selected;

  //code to select text
  void selfMousePressed() {
    if (p_rectIntersect(mouseX, mouseY, scriptX, scriptY, scriptGraphics.width, scriptGraphics.height)) {
      int y = getScriptMouseY(), x = getScriptMouseX();
      selected = new LineSelection(x, y, script);
    }
  }

  void selfMouseDragged() {
    if (selected != null && p_rectIntersect(mouseX, mouseY, scriptX, scriptY, scriptGraphics.width, scriptGraphics.height)) {
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
        selected.finish(scriptGraphics);
        scriptMutex.release();
      } 
      catch(InterruptedException e) {
      }
    }
  }
}

