class Note {
  
  ArrayList<Integer> lineNums;
  ArrayList<String> actors;
  String note, extra_info, selection;
  int sStart, sEnd;
  
  Note(String n, String extra, String select, int sS, int sE, ArrayList<Line> ln) {
    note = n;
    extra_info = extra;
    selection = select;
    sStart = sS;
    sEnd = sE;
    lineNums = new ArrayList();
    actors = new ArrayList();
    for(Line l : ln) {
      lineNums.add(l.lineNum);
      if (!actors.contains(l.actor)) {
        actors.add(l.actor);
      }
    }
  }
  
  Note(ArrayList<String> strs, Script p) throws Exception {
    if(!strs.get(0).equals("Note")) {
      println("Not a Note");
      throw new Exception("Note Parsing Error: Not a Note");
    }
    strs.remove(0);
    note = strs.remove(0);
    extra_info = strs.remove(0);
    lineNums = new ArrayList();
    actors = new ArrayList();
    
    for (String s : splitTokens(strs.remove(0), " ")) {
      lineNums.add(int(s));
      actors.add(p.lines.get(int(s)).actor);
    }
  }
  
  String toString() {
    String res = "Note\n" + note + "\n" + extra_info + "\n";
    for(int ln : lineNums) {
      res += ln + " ";
    }
    return res;
  }
  
  String formattedExport() {
    String result = "";
    result +=          "+---------------------------------------------------+\n";
    result += ("|"+note+"                                                   |\n".substring(note.length()));
    result +=          "+---------------------------------------------------+\n\n";
    result += selection;
    result +=      "\n\n+--------------------+\n\n";
    result += extra_info + "\n\n";
    
    return result;
  }
}
