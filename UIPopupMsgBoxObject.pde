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
    PGraphics G = wWin.value().getGraphics();
    G.beginDraw();
    G.background(0);
    G.fill(0x42);
    G.rect(4, 4, wWin.value().w-8, wWin.value().h-8);
    G.textAlign(CENTER, CENTER);
    G.fill(0xE0);
    G.text(message, 0, 0, wWin.value().w, wWin.value().h); 
    G.endDraw();
    wWin.value().draw(g);
  }
}
