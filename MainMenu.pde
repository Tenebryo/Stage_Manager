//provide a list of recent scripts, an open script file, and a create new script file

class MainMenu extends UIFullscreenObject {
  MainMenu(Wrapper<UIObject> _parent) {
    super(_parent);

    elem.add(new UIButton(W/2, 100, W/2-10, 40, "Open Script").setOnClicked(new UIAction() {
      //runs when the button is clicked
      public void execute() {
        onFileOpen = new UIFileParamAction() {
          //runs when the file is selected
          public void execute(File f) {
            try {
              next.value(new ScriptDisplay(next, new Script(new ArrayList(Arrays.asList(loadStrings(f.getAbsolutePath()))), f.getAbsolutePath())));
            }
            catch(Exception e) {
            }
          }
        };
        selectInput("Select Script File", "fileOpenedCallBack");
      }
    }
    ));

    elem.add(new UIButton(W/2, 150, W/2-10, 40, "Create New Script").setOnClicked(new UIAction() {
      //runs when the button is clicked
      public void execute() {
        //open new script dialogue
        next.value(new ScriptLoader(next));
      }
    }
    ));

    String[] recents = loadStrings(recentScripts);

    UIContainerElement recentContainer = new UIContainerElement() {
      void update() {}
    };
    int _h = 100;
    for (String s : recents) {
      final String fs = s;
      recentContainer.add(new UIButton(10, _h, W/2 - 20, 40, s).setOnClicked(new UIAction() {
        //run when the button is clicked
        public void execute() {
          println(fs);
          try {
            next.value(new ScriptDisplay(next, new Script(new ArrayList(Arrays.asList(loadStrings(fs))), fs)));
          }
          catch(Exception e) {
            println(e.getMessage());
          }
        }
      }
      ));
      _h += 50;
    }
    elem.add(recentContainer);
    println(recentContainer.elems.size());
  }

  void drawSelf(int w, int h, PGraphics g) {
    g.background(0x21);

    g.fill(0x15, 0x65, 0xC0);
    g.textAlign(LEFT, BOTTOM);
    g.textSize(24);
    g.text("Recently Opened Scripts", 10, 90);

    g.textSize(16);
    g.textAlign(RIGHT, BOTTOM);
    g.text("Created by Sam Blazes", W-10, H-10);


    super.drawSelf(w, h, g);
  }
}

