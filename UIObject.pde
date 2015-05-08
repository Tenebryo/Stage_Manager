/*////////////////////////////////////////////////////////////////
 
 Base class for a system of managing several views of an application
 
 Functions as a linked list of frames
 
 //*/
class UIObject {
  ArrayList<UIElement> elem;

  final Wrapper<Window> wWin = new Wrapper<Window>(null);
  //Wrapped reference to next, so the next object can exit itself
  final Wrapper<UIObject> next = new Wrapper<UIObject>(null);
  //Wrapped refernce to this object, so this object can erase the reference to itself
  Wrapper<UIObject> handle;
  PGraphics nextView;

  int W, H;

  boolean transparent, blocking;

  float transition;
  int transState;

  UIObject (Wrapper<UIObject> _h, Wrapper<Window> win, int x, int y, int w, int h) {
    W = w; 
    H = h;
    
    wWin.value(new Window(x, y, w, h, win.value()));
      
    handle = _h;
    transparent = false;
    blocking = true;
    elem = new ArrayList<UIElement>();
  }

  boolean isTransparent() {
    if (!transparent)
      return false;
    else if (next.value() != null)
      return next.value().isTransparent();
    else
      return true;
  }

  boolean isBlocking() {
    if (blocking)
      return true;
    else if (next.value() != null)
      return next.value().isBlocking();
    else
      return false;
  }

  boolean draw () {
    boolean ret = false;
    PGraphics g = wWin.value().beginDraw();
    
    if (next.value() == null || next.value().draw()) {
      
      this.drawSelf(g.width, g.height, g);
      
      ret = transparent;
    }
    
    if(next.value() != null) {
      next.value().wWin.value().draw(g);
    }
      
    wWin.value().endDraw();
    
    return ret;
  }

  boolean keyPressed(char key) {
    if (next.value() == null || !next.value().keyPressed(key)) {
      for (int i = elem.size ()-1; i >= 0; i--) {
        if (elem.get(i).keyPressed(key)) {
          break;
        }
      }
      selfKeyPressed(key);
      return blocking;
    }
    return false;
  }

  boolean mousePressed() {
    if (next.value() == null || !next.value().mousePressed()) {
      for (int i = elem.size ()-1; i >= 0; i--) {
        if (elem.get(i).mousePressed()) {
          break;
        }
      }
      selfMousePressed();
      return blocking;
    }
    return false;
  }

  boolean mouseReleased() {
    if (next.value() == null || !next.value().mouseReleased()) {
      for (int i = elem.size ()-1; i >= 0; i--) {
        if (elem.get(i).mouseReleased()) {
          break;
        }
      }
      selfMouseReleased();
      return blocking;
    }
    return false;
  }

  boolean mouseClicked() {
    if (next.value() == null || !next.value().mouseClicked()) {
      for (int i = elem.size ()-1; i >= 0; i--) {
        if (elem.get(i).mouseClicked()) {
          break;
        }
      }
      selfMouseClicked();
      return blocking;
    }
    return false;
  }

  boolean mouseDragged() {
    if (next.value() == null || !next.value().mouseDragged()) {
      for (int i = elem.size ()-1; i >= 0; i--) {
        if (elem.get(i).mouseDragged()) {
          break;
        }
      }
      selfMouseDragged();
      return blocking;
    }
    return false;
  }

  boolean mouseWheel(MouseEvent evt) {
    if (next.value() == null || !next.value().mouseWheel(evt)) {
      for (int i = elem.size ()-1; i >= 0; i--) {
        if (elem.get(i).mouseWheel(evt)) {
          break;
        }
      }
      selfMouseWheel(evt);
      return blocking;
    }
    return false;
  }

  void selfKeyPressed(char key) {
  }
  void selfMousePressed() {
  }
  void selfMouseReleased() {
  }
  void selfMouseClicked() {
  }
  void selfMouseDragged() {
  }
  void selfMouseWheel(MouseEvent evt) {
  }

  void drawSelf(int w, int h, PGraphics g) {
    for (int i = 0; i < elem.size (); i++) {
      elem.get(i).draw(g);
    }
  }

  void exitUIObject() {
    handle.value(null);
  }
}

class UIFullscreenObject extends UIObject {
  UIFullscreenObject(Wrapper<UIObject> _p, Wrapper<Window> win) {
    super(_p, win, 0, 0, width, height);
  }
}

