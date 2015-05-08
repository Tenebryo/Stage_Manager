class Window {
  private PGraphics g;
  private Window p;
  int x, y, w, h;
  
  Window(int x, int y, int w, int h, Window p) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.p = p;
    g = createGraphics(w, h);
  }
  
  void draw(PGraphics pg) {
    pg.image(g, x, y);
  }
  
  void draw() {
    image(g, x, y);
  }
 
  PGraphics getGraphics() {
    return g;
  }
  
  int getMouseX() {
    if(p != null) {
      return p.getMouseX() - x;
    }
    return mouseX - x;
  }
  
  int getMouseY() {
    if(p != null) {
      return p.getMouseY() - y;
    }
    return mouseY - y;
  }
  
  PGraphics beginDraw() {
    g.beginDraw();
    return g;
  }
  
  void endDraw() {
    g.endDraw();
  }
}
