class Rehearsal {
  String date, label;
  ArrayList<Note> notes;

  Rehearsal(String d, String lbl) {
    date = d;
    label = lbl;
    notes = new ArrayList();
  }

  Rehearsal(ArrayList<String> strs, Script p) throws Exception {
    if (!strs.get(0).equals("Rehearsal")) {
      throw new Exception("Rehearsal Parse Error: not a Rehearsal");
    }
    notes = new ArrayList();
    strs.remove(0);
    date = strs.remove(0);
    label = strs.remove(0);
    int n = int(strs.remove(0));
    try {
      for (int i = 0; i < n; i++) {
        addNote(new Note(strs, p));
      }
    }
    catch(Exception e) {
      throw new Exception("Rehearsal Parse Error: ", e);
    }
  }

  void addNote(Note n) {
    notes.add(n);
  }

  String toString() {
    String ret = "Rehearsal\n" + date + "\n" + label + "\n";

    ret += notes.size();
    for (int i = 0; i < notes.size(); i++) {
      ret += "\n" + notes.get(i);
    }

    return ret;
  }
}

