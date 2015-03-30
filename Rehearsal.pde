class Rehearsal {
  String date;
  ArrayList<Note> notes;
  
  Rehearsal(String d) {
    date = d;
  }
  
  Rehearsal(ArrayList<String> strs) throws Exception {
    if(!strs.get(0).equals("Rehearsal")) {
      throw new Exception("Rehearsal Parse Error: not a Rehearsal");
    }
    
    strs.remove(0);
    date = strs.remove(0);
    int n = int(strs.remove(0));
    try {
    for(int i = 0; i < n; i++) {
      addNote(new Note(strs));
    }
    }catch(Exception e) {
      throw new Exception("Rehearsal Parse Error: ", e);
    }
  }
  
  void addNote(Note n) {
    notes.add(n);
  }
  
  String toString() {
    String ret = "Rehearsal\n" + date + "\n";
    
    ret += notes.size() + "\n";
    for(Note n : notes) {
      ret += n + "\n";
    }
    
    return ret;
  }
}
