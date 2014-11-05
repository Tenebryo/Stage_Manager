class Actor
{
  
  //Variable declarations
  protected String charName;
  protected String actorName;
  protected ArrayList<Note> notes;
  
  //Constructor
  //Default Constructor
  Actor()
  {
    
    charName = "";
    actorName = "";
    notes = new ArrayList<Note>();
    
  }
  
  //Constructor given cName
  Actor(String c)
  {
    
    charName = c;
    actorName = "";
    notes = new ArrayList<Note>();
    
  }
  
  //Constructor given everything
  Actor(String c, String a)
  {
    
    charName = c;
    actorName = a;
    notes = new ArrayList<Note>();
    
  }
  
  //Get and set character name
  String getCharName()
  {
    
    return charName;
    
  }
  
  void setCharName(String c)
  {
    
    charName = c;
    
  }
  
  //Get and set actor name
  String getActorName()
  {
    
    return actorName;
    
  }
  
  void setActorName(String a)
  {
    
    actorName = a;
    
  }
  
  //Get and set notes
  ArrayList<Note> getNotes()
  {
    
    return notes;
    
  }
  
  void addNote(Note note)
  {
    
    notes.add(note);
    
  }
  
  //toString
  String toString()
  {
    
    return(charName + " (" + actorName + ")");
    
  }
  
}
