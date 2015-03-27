class Actor {
  String name;

  Actor(String _name) {
    name = _name;
  }

  String toString() {
    return "Actor\n" + name;
  }

  Actor(ArrayList<String> strs) throws Exception {
    if (!strs.get(0).equals("Actor")) {
      throw new Exception("Actor");
    }
    strs.remove(0);
    name = strs.remove(0);
  }
}

