class UIPopupMsgBoxObject extends UIObject {
  String message = "";
  
  
  UIPopupMsgBoxObject(Wrapper<UIObject> _p, Wrapper<Window> win, String msg, int x, int y, int w, int h) {
    super(_p, win, x, y, w, h);
    transparent = true;
    blocking = false;
    message = msg;
  }
  
  boolean test() {
    return true;
  }
  
  void drawSelf(int w, int h, PGraphics g) {
    println("Test");
    if(test()) {
      exitUIObject();
      return;
    }
    g.beginDraw();
    g.background(0);
    g.fill(0x42);
    g.rect(4, 4, w-8, h-8);
    g.textAlign(CENTER, CENTER);
    g.fill(0xE0);
    g.text(message, 0, 0, w, h);
  }
}
