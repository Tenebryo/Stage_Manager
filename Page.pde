class Page {
  ArrayList<Integer> lines;
  int pageNumber;

  Page(int _pgnum) {
    pageNumber = _pgnum;
    lines = new ArrayList();
  }

  String toString() {
    String ret = "Page\n" + pageNumber + "\n";

    for (int l : lines) {
      ret += l + " ";
    }
    return ret;
  }

  Page(ArrayList<String> ls) throws Exception {
    if (!ls.get(0).equals("Page")) {
      throw new Exception("Page");
    }
    lines = new ArrayList();
    ls.remove(0);
    pageNumber = Integer.parseInt(ls.remove(0));
    String[] strLineNums = splitTokens(ls.remove(0), " ");
    for (String s : strLineNums) {
      lines.add(int(s));
    }
  }

  void addLine(Line l) {
    lines.add(l.lineNum);
  }
}

