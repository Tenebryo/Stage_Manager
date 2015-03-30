class Note {
  
  String note;
  
  Note(String n) {
    note = n;
  }
  
  Note(ArrayList<String> strs) {
    if(!strs.get(0).equals("Note")) {
      throw new Exception("Note Parsing Error: Not a Note");
    }
    strs.remove(0);
  }
  
  String toString() {
    return "Note\n";
  }
}
