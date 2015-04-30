/*////////////////////////////////////////////////////////////////
 
 Base class for a system of managing several views of an application
 
 Functions as a linked list of frames
 
 //*/
class UIObject {
  ArrayList<UIElement> elem;

  //Wrapped reference to next, so the next object can exit itself
  final Wrapper<UIObject> next = new Wrapper<UIObject>(null);
  //Wrapped refernce to this object, so this object can erase the reference to itself
  Wrapper<UIObject> handle;
  PGraphics nextView;

  int W, H;

  boolean transparent, blocking;

  float transition;
  int transState;

  UIObject (Wrapper<UIObject> _h, int w, int h) {
    W = w; 
    H = h;
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

  boolean draw (int w, int h, PGraphics g) {
    if (next.value() == null || next.value().draw(w, h, g)) {
      this.drawSelf(w, h, g);
      return transparent;
    }
    return false;
  }

  boolean keyPressed(char key) {
    if (next.value() == null || !next.value().keyPressed(key)) {
      for (int i = elem.size()-1; i >= 0; i--) {
        if(elem.get(i).keyPressed(key)) {
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
      for (int i = elem.size()-1; i >= 0; i--) {
        if(elem.get(i).mousePressed()) {
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
      for (int i = elem.size()-1; i >= 0; i--) {
        if(elem.get(i).mouseReleased()) {
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
      for (int i = elem.size()-1; i >= 0; i--) {
        if(elem.get(i).mouseClicked()) {
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
      for (int i = elem.size()-1; i >= 0; i--) {
        if(elem.get(i).mouseDragged()) {
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
      for (int i = elem.size()-1; i >= 0; i--) {
        if(elem.get(i).mouseWheel(evt)) {
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
    for (int i = 0; i < elem.size(); i++) {
        elem.get(i).draw(g);
    }
  }

  void exitUIObject() {
    handle.value(null);
  }
}

class UIFullscreenObject extends UIObject {
  UIFullscreenObject(Wrapper<UIObject> _p) {
    super(_p, width, height);
  }
  boolean draw(int w, int h, PGraphics g) {
    return super.draw(width, height, g);
  }
}

