/*////////////////////////////////////////////////////////////////

Base class for a system of managing several views of an application

Functions as a linked list of frames

//*/
class UIObject {
  ArrayList<UIElement> elem;
  
  private UIObject next;
  UIObject prev;
  PGraphics nextView;
  
  int W, H;

  boolean transparent, blocking;

  float transition;
  int transState;

  UIObject (UIObject _p, int w, int h) {
    prev = _p; W = w; H = h;
    transparent = false;
    blocking = true;
    elem = new ArrayList<UIElement>();
  }

  boolean isTransparent() {
    if (!transparent)
      return false;
    else if (next != null)
      return next.isTransparent();
    else
      return true;
  }
  
  boolean isBlocking() {
    if (blocking)
      return true;
    else if (next != null)
      return next.isBlocking();
    else
      return false;
  }

  boolean draw (int w, int h, PGraphics g) {
    if (next == null || next.draw(w, h, g)) {
      this.drawSelf(w, h, g);
      return transparent;
    }
    return false;
  }
  
  boolean keyPressed(char key) {
    if(next == null || !next.keyPressed(key)) {
      for(UIElement e : elem) {
        e.keyPressed(key);
      }
      selfKeyPressed(key);
      return blocking;
    }
    return false;
  }
  
  boolean mousePressed() {
    if(next == null || !next.mousePressed()) {
      for(UIElement e : elem) {
        e.mousePressed();
      }
      selfMousePressed();
      return blocking;
    }
    return false;
  }
  
  boolean mouseReleased() {
    if(next == null || !next.mouseReleased()) {
      for(UIElement e : elem) {
        e.mouseReleased();
      }
      selfMouseReleased();
      return blocking;
    }
    return false;
  }
  
  boolean mouseClicked() {
    if(next == null || !next.mouseClicked()) {
      for(UIElement e : elem) {
        e.mouseClicked();
      }
      selfMouseClicked();
      return blocking;
    }
    return false;
  }
  
  boolean mouseDragged() {
    if(next == null || !next.mouseDragged()) {
      for(UIElement e : elem) {
        e.mouseDragged();
      }
      selfMouseDragged();
      return blocking;
    }
    return false;
  }
  
  boolean mouseWheel(MouseEvent evt) {
    if(next == null || !next.mouseWheel(evt)) {
      for(UIElement e : elem) {
        e.mouseWheel(evt);
      }
      selfMouseWheel(evt);
      return blocking;
    }
    return false;
  }

  void selfKeyPressed(char key) {}
  void selfMousePressed() {}
  void selfMouseReleased() {}
  void selfMouseClicked() {}
  void selfMouseDragged() {}
  void selfMouseWheel(MouseEvent evt) {}
  
  void drawSelf(int w, int h, PGraphics g) {
      for(UIElement e : elem) {
        e.draw(g);
      }
  }
}

class UIFullscreenObject extends UIObject {
  UIFullscreenObject(UIObject _p) {
    super(_p, width, height);
  }
  boolean draw(int w, int h, PGraphics g) {
    return super.draw(width, height, g);
  }
}


