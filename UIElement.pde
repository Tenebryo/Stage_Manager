
UIElement focus;
void destroyFocus() {
  focus = null;
}

abstract class UIElement {
  int x, y, w, h;

  UIElement(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }

  void setAsFocus() {
    focus = this;
  }

  abstract void draw(PGraphics g);

  void keyPressed(char key) {
  }
  void mousePressed() {
  }
  void mouseReleased() {
  }
  void mouseClicked() {
  }
  void mouseWheel(MouseEvent event) {
  }
  void mouseDragged() {
  }
  void mouseMoved() {
  }
}

class UITextBox extends UIElement {
  String text, helpText;
  int maxLen, cursorPos;
  UIAction submit;
  boolean focusOnly = true;

  UITextBox (int _x, int _y, int _w, int _h, int _maxLen, String _helpText, UIAction _submit) {
    super(_x, _y, _w, _h);
    maxLen = _maxLen;
    cursorPos = 0;
    helpText = _helpText;
    submit = _submit;
  }

  void setText(String _text) {
    text = _text;
    cursorPos = max(0, min(text.length(), cursorPos));
  }

  void keyPressed(char key) {
    if ((focusOnly && focus == this) || !focusOnly) {
      if (key == CODED) {
        if (key == LEFT && cursorPos > 0) {
          cursorPos--;
        } else if (key == RIGHT && key < text.length()) {
          cursorPos++;
        }
      } else if (key == ENTER || key == RETURN) {
        submit.execute();
      } else if (key == BACKSPACE) {
        text = text.substring(0, max(0, cursorPos-2)) + text.substring(cursorPos);
      } else if (key == DELETE) {
        text = text.substring(0, max(0, cursorPos-1)) + text.substring(min(cursorPos+1, text.length()));
      } else if (key == ESC) {
        if (focus == this) {
          destroyFocus();
        }
      } else {
        text += key;
      }
    }
  }

  void draw(PGraphics g) {
    g.noStroke();
    g.fill(0xE0);
    g.rect(x, y+h-2, w, 2, 0, 0, 2, 2); 
    g.textAlign(LEFT, BOTTOM);
    g.stroke(0xFF);
    g.text(text, x, y+h);
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

  void mousePressed() {
    if(mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h && onPressed != null) {
      onPressed.execute();
    }
  }
  void mouseReleased() {
    if(mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h && onReleased != null) {
      onReleased.execute();
    }
  }
  void mouseClicked() {
    if(mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h && onClicked != null) {
      onClicked.execute();
    }
  }
  
  void draw(PGraphics g) {
    g.noStroke();
    g.fill(0x19, 0x76, 0xD2);
    g.rect(x, y, w, h);
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

  void mousePressed() {
    if (mouseX >= x && mouseX <= x+w && mouseY >= y+scrollPos && mouseY <= y+scrollPos+h/10) {
      lastMousePos = mouseY;
      lastPos = scrollPos;
      focus = this;
    } else {
      lastMousePos = -1;
      lastPos = -1;
    }
  }

  void mouseDragged() {
    if (lastPos != -1) {
      scrollPos = constrain(lastPos + (mouseY - lastMousePos), 0, (h*9)/10);
      scrollAlpha.val = scrollPos/((h*9)/10.0);
    }
  }

  void mouseReleased() {
    lastMousePos = -1;
    lastPos = -1;
  }
  
  void mouseWheel(MouseEvent evt) {
    if (focus == this) {
      scrollPos = constrain(scrollPos + evt.getCount()*step, 0, (h*9)/10);
      scrollAlpha.val = scrollPos/((h*9)/10.0);
    }
  }

  void draw(PGraphics g) {
    g.noStroke();
    g.fill(0x61);
    g.rect(x, y, w, h);
    g.fill(0x19, 0x76, 0xD2);
    if (lastPos != -1)
      g.fill(0x15, 0x65, 0xC0);
    g.rect(x, y+scrollPos, w, h/10);
  }
}

