class Scene {
  ArrayList<Integer> lines;
  String title, description;

  Scene(String _title, String _desc) {
    title = _title.replaceAll("\n", "");
    description = _desc.replaceAll("\n", "");
    lines = new ArrayList();
  }

  Scene(ArrayList<String> ls) throws Exception {
    if (!ls.get(0).equals("Scene")) {
      throw new Exception("Scene");
    }
    lines = new ArrayList();
    ls.remove(0);
    title = ls.remove(0);
    description = ls.remove(0);
    String[] strLineNums = splitTokens(ls.remove(0), " ");
    for (String s : strLineNums) {
      lines.add(int(s));
    }
  }

  void addLine(Line l) {
    lines.add(l.lineNum);
  }

  String toString() {
    String ret = "Scene\n" + title + "\n" + description + "\n";

    for (int l : lines) {
      ret += l + " ";
    }
    return ret;
  }
}

