class Note {
  
  ArrayList<Integer> lineNums;
  String note, extra_info, selection;
  int sStart, sEnd;
  
  Note(String n, String extra, String select, int sS, int sE, ArrayList<Line> ln) {
    note = n;
    extra_info = extra;
    selection = select;
    sStart = sS;
    sEnd = sE;
    lineNums = new ArrayList();
    for(Line l : ln) {
      lineNums.add(l.lineNum);
    }
  }
  
  Note(ArrayList<String> strs) throws Exception {
    if(!strs.get(0).equals("Note")) {
      throw new Exception("Note Parsing Error: Not a Note");
    }
    strs.remove(0);
    note = strs.remove(0);
    extra_info = strs.remove(0);
    
    for (String s : splitTokens(strs.remove(0), " ")) {
      lineNums.add(int(s));
    }
  }
  
  String toString() {
    String res = "Note\n" + note + "\n" + extra_info + "\n";
    for(int ln : lineNums) {
      res += ln + " ";
    }
    return res;
  }
}
