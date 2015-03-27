import java.io.*;
import java.util.*;
import java.nio.channels.*;
import java.util.concurrent.Semaphore;

String recentScripts = "./data/recent.dat";

//PFont font = loadFont("Roboto-Regular-48.vlw");
UIObject root;
PGraphics rootGraphics;
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
  root = new MainMenu(null);
  rootGraphics = createGraphics(displayWidth, displayHeight);
  done = true;
  //textFont(font);
}

void draw() {
  if(!done) return;
  rootGraphics.beginDraw();
  root.draw(width, height, rootGraphics);
  rootGraphics.endDraw();
  image(rootGraphics, 0, 0);
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
void keyPressed(char key) {
  root.keyPressed(key);
}
void fileOpenedCallBack(File f) {
  onFileOpen.execute(f);
}

