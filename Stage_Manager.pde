import java.io.*;
import java.util.*;
import java.text.*;
import java.nio.channels.*;
import java.util.concurrent.Semaphore;

String recentScripts = "./data/recent.dat";

//PFont font = loadFont("Roboto-Regular-48.vlw");
UIObject root;
Window rootWindow;
UIFileParamAction onFileOpen;

int lineHeight = 24;

boolean sketchFullScreen() {
  return true;
}

boolean done = false;

void setup() {
  try {
    loadStrings(recentScripts);
  } catch (Exception e) {
    saveStrings(recentScripts, new String[0]);
  }
  size(displayWidth, displayHeight);
  rootWindow = new Window(0, 0, displayWidth, displayHeight, null);
  root = new MainMenu(null, new Wrapper<Window>(rootWindow));
  done = true;
  //textFont(font);
}

void draw() {
  if(!done) return;
  rootWindow.beginDraw();
  root.draw();
  root.wWin.value().draw(rootWindow.getGraphics());
  rootWindow.endDraw();
  rootWindow.draw();
}

void mousePressed() {
  root.mousePressed();
}
void mouseReleased() {
  root.mouseReleased();
}
void mouseClicked() {
  root.mouseClicked();
}
void mouseDragged() {
  root.mouseDragged();
}
void mouseWheel(MouseEvent evt) {
  root.mouseWheel(evt);
}
void keyPressed() {
  root.keyPressed(key);
}
void fileOpenedCallBack(File f) {
  onFileOpen.execute(f);
}

