
UIElement focus;
void destroyFocus() {
  focus = null;
}

/*
UIElement is a class that handles user input, such as text boxes,
 scroll bars, buttons, checkboxes, etc.
 
 UIObjects pass/call user input events on these elements.
 
 Some only operate if there are "in focus" and only one can be 
 "in focus" at a time.
 //*/
abstract class UIElement {
  int x, y, w, h;
  boolean debug = false;

  UIElement(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }

  void setAsFocus() {
    focus = this;
  }

  void removeFocus() {
    if (focus == this) {
      focus = null;
    }
  }

  abstract void draw(PGraphics g);

  boolean keyPressed(char key) {
    return false;
  }
  boolean mousePressed() {
    return false;
  }
  boolean mouseReleased() {
    return false;
  }
  boolean mouseClicked() {
    return false;
  }
  boolean mouseWheel(MouseEvent event) {
    return false;
  }
  boolean mouseDragged() {
    return false;
  }
  boolean mouseMoved() {
    return false;
  }
}

class UITextBox extends UIContainerElement {
  final Wrapper<String> wText = new Wrapper<String>("");
  String text, helpText;
  int maxLen, cursorPos;
  boolean focusOnly = true;
  Window textArea;
  Wrapper<Float> scrollPos;
  Semaphore mutex = new Semaphore(1, true);

  UITextBox (int _x, int _y, int _w, int _h, String _helpText) {
    super();
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    cursorPos = 0;
    helpText = _helpText;
    text = "";
    textArea = new Window(_x, _y, _w, _h, null);
    scrollPos = new Wrapper<Float>(0.0);
    elems.add(new UIScrollBar(_w-10, 0, 10, _h, 0.5, scrollPos));
  }

  void setText(String _text) {
    text = _text;
    cursorPos = max(0, min(text.length(), cursorPos));
  }

  boolean mouseClicked() {
    if (p_rectIntersect(mouseX, mouseY, x, y, w, h)) {
      setAsFocus();
    } else {
      removeFocus();
    }
    return super.mouseClicked();
  }

  boolean keyPressed(char key) {
    if (focus == this || !focusOnly) {
      try {
        mutex.acquire();
        if (key == CODED) {
          if (key == LEFT && cursorPos > 0) {
            cursorPos--;
          } else if (key == RIGHT && cursorPos < text.length()) {
            cursorPos++;
          }
        } else if (key == ENTER || key == RETURN) {
          submit();
        } else if (key == DELETE) {
          text = text.substring(0, max(0, cursorPos-1)) + text.substring(min(cursorPos+1, text.length()));
        } else if (key == BACKSPACE) {
          text = text.substring(0, max(0, cursorPos-1)) + text.substring(cursorPos);
          if (cursorPos > 0) {
            cursorPos--;
          }
        } else if (key == ESC) {
          removeFocus();
        } else if ((int)key >= 32 && (int)key <= 126) {
          text = text.substring(0, cursorPos) + key + text.substring(min(cursorPos+1, text.length()));
          cursorPos++;
        }
        mutex.release();
      } 
      catch (InterruptedException e) {
      }
    }
    println("Text: ", text);
    return super.keyPressed(key);
  }

  void submit() {
  }
  void update() {
  }

  void draw(PGraphics g) {
    PGraphics TAg = textArea.getGraphics();
    TAg.beginDraw();

    TAg.background(0x42);
    TAg.noStroke();
    TAg.fill(0xE0);
    TAg.rect(x, y+h-2, w, 2, 0, 0, 2, 2); 
    TAg.textAlign(LEFT, TOP);
    TAg.stroke(0xFF);

    String[] dLines = getDisplayLines(text, w-20, TAg);
    TAg.translate(0, -max(0, dLines.length*lineHeight-h)*scrollPos.value());
    for (int i = 0; i < dLines.length; i++) {
      TAg.text(dLines[i], 5, i*lineHeight);
    }
    super.draw(TAg);

    TAg.endDraw();
    textArea.draw(g);

    update();
  }
}

class UIButton extends UIElement {
  UIAction onPressed, onReleased, onClicked;
  String text;

  UIButton (int _x, int _y, int _w, int _h, String _text) {
    super(_x, _y, _w, _h);
    text = _text;
  }

  UIButton setOnClicked(UIAction action) {
    onClicked = action;
    return this;
  }

  UIButton setOnPressed(UIAction action) {
    onPressed = action;
    return this;
  }

  UIButton setOnReleased(UIAction action) {
    onReleased = action;
    return this;
  }

  boolean mousePressed() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h && onPressed != null) {
      onPressed.execute();
      return true;
    }
    return false;
  }
  boolean mouseReleased() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h && onReleased != null) {
      onReleased.execute();
      return true;
    }
    return false;
  }
  boolean mouseClicked() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h && onClicked != null) {
      onClicked.execute();
      return true;
    }
    return false;
  }

  void draw(PGraphics g) {
    g.noStroke();
    g.fill(0x19, 0x76, 0xD2);
    if (p_rectIntersect(mouseX, mouseY, x, y, w, h)) {
      g.fill(0x10, 0x54, 0x96);
    }
    g.rect(x, y, w, h);
    g.fill(0xE0);
    g.textAlign(CENTER, CENTER);
    g.textSize(14);
    g.text(text, x+w/2, y+h/2);
  }
}

class UISuperButton extends UIElement {
  String text;

  UISuperButton (int _x, int _y, int _w, int _h, String _text) {
    super(_x, _y, _w, _h);
    text = _text;
  }

  void onClicked() {
  };

  void onPressed() {
  };

  void onReleased() {
  };

  boolean mousePressed() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h) {
      onPressed();
      return true;
    }
    return false;
  }
  boolean mouseReleased() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h) {
      onReleased();
      return true;
    }
    return false;
  }
  boolean mouseClicked() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h) {
      onClicked();
      return true;
    }
    return false;
  }

  void draw(PGraphics g) {
    g.noStroke();
    g.fill(0x19, 0x76, 0xD2);
    if (p_rectIntersect(mouseX, mouseY, x, y, w, h)) {
      g.fill(0x10, 0x54, 0x96);
    }
    g.rect(x, y, w, h);
    g.fill(0xE0);
    g.textAlign(CENTER, CENTER);
    g.textSize(14);
    g.text(text, x+w/2, y+h/2);
  }
}

class UIScrollBar extends UIElement {
  float scrollPos=0;
  int lastMousePos = -1;
  float lastPos=0;
  float step = 1;
  Wrapper<Float> scrollAlpha;
  UIScrollBar(int _x, int _y, int _w, int _h, float _step, Wrapper<Float> _sp) {
    super(_x, _y, _w, _h);
    scrollAlpha = _sp;
  }

  boolean mousePressed() {
    if (mouseX >= x && mouseX <= x+w && mouseY >= y+scrollPos && mouseY <= y+scrollPos+h/10) {
      lastMousePos = mouseY;
      lastPos = scrollPos;
      focus = this;
      return true;
    } else {
      lastMousePos = -1;
      lastPos = -1;
    }
    return false;
  }

  boolean mouseDragged() {
    if (lastPos != -1) {
      scrollPos = constrain(lastPos + (mouseY - lastMousePos), 0, (h*9)/10);
      scrollAlpha.value(scrollPos/((h*9)/10.0));
      return true;
    }
    return false;
  }

  boolean mouseReleased() {
    lastMousePos = -1;
    lastPos = -1;
    return false;
  }

  boolean mouseWheel(MouseEvent evt) {
    if (focus == this) {
      scrollPos = constrain(scrollPos + evt.getCount()*step, 0, (h*9)/10);
      scrollAlpha.value(scrollPos/((h*9)/10.0));
    }
    return false;
  }

  void draw(PGraphics g) {
    g.noStroke();
    g.fill(0x61);
    g.rect(x, y, w, h);
    g.fill(0x15, 0x65, 0xC0);
    if (lastPos != -1)
      g.fill(0x0D, 0x47, 0xA1);
    g.rect(x, y+scrollPos, w, h/10);
  }
}

class UICheckboxElement extends UIElement {
  Wrapper<Boolean> checked;
  boolean hover = false;
  UICheckboxElement(int x, int y, Wrapper<Boolean> _out) {
    super(x, y, 10, 10);
    checked = _out;
  }

  boolean mouseReleased() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h) {
      checked.value(!checked.value());
      return true;
    }
    return false;
  }

  boolean mouseMoved() {
    hover = false;
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h) {
      hover = true;
    }
    return false;
  }

  void draw(PGraphics g) {
  }
}

/*
this class provides a method of controlling and storing an arbitrary number of UIElements as a group
 //*/
class UIContainerElement extends UIElement {

  ArrayList<UIElement> elems;
  boolean active;

  UIContainerElement(UIElement... _elems) {
    super(0, 0, 0, 0);
    elems = new ArrayList(Arrays.asList(_elems));
    init();
  }

  void clear() {
    elems.clear();
  }

  void add(UIElement e) {
    elems.add(e);
  }

  void update() {
  };
  void init() {
  };

  void draw(PGraphics g) {
    for (UIElement e : elems) {
      e.draw(g);
    }
    update();
  }

  boolean keyPressed(char key) {
    for (UIElement e : elems) {
      if (e.keyPressed(key)) {
        return true;
      }
    }
    return false;
  }
  boolean mousePressed() {
    for (UIElement e : elems) {
      if (e.mousePressed()) {
        return true;
      }
    }
    return false;
  }
  boolean mouseReleased() {
    for (UIElement e : elems) {
      if (e.mouseReleased()) {
        return true;
      }
    }
    return false;
  }
  boolean mouseClicked() {
    for (UIElement e : elems) {
      if (e.mouseClicked()) {
        return true;
      }
    }
    return false;
  }
  boolean mouseWheel(MouseEvent event) {
    for (UIElement e : elems) {
      if (e.mouseWheel(event)) {
        return true;
      }
    }
    return false;
  }
  boolean mouseDragged() {
    for (UIElement e : elems) {
      if (e.mouseDragged()) {
        return true;
      }
    }
    return false;
  }
  boolean mouseMoved() {
    for (UIElement e : elems) {
      if (e.mouseMoved()) {
        return true;
      }
    }
    return false;
  }
}

