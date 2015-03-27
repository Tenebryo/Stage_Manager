boolean p_rectIntersect(int px, int py, int rx, int ry, int rw, int rh) {
  return px >= rx && px < rx + rw && py >= ry && ry < ry + rh;
}
