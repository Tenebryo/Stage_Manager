class Note {
  
  int lineNum;
  String note, extra_info;
  
  Note(String n) {
    note = n;
  }
  
  Note(ArrayList<String> strs) throws Exception {
    if(!strs.get(0).equals("Note")) {
      throw new Exception("Note Parsing Error: Not a Note");
    }
    strs.remove(0);
  }
  
  String toString() {
    return "Note\n" + lineNum + "\n" + note + "\n" + extra_info;
  }
}
