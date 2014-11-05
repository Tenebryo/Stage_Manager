class Note
{
  
  protected ArrayList<Line> lines;
  protected ArrayList<Word> words;
  protected ArrayList<Actor> actors;
  protected int type;
  protected int rehearsal;
  
  //Default Constructor
  Note()
  {
    
    rehearsal = currentRehearsal;
    lines = new ArrayList<Line>();
    words = new ArrayList<Word>();
    actors = new ArrayList<Actor>();
    
  }
  
  void giveToActors()
  {
    
    for(Actor actor : actors)
    {
      
      actor.addNote(this);
      
    }
    
  }
  
  //Get lines
  ArrayList<Line> getLines()
  {
    
    return lines;
    
  }
  
  Line getLine(int i)
  {
    
    return lines.get(i);
    
  }
  
  void addLine(Line line)
  {
    
    lines.add(line);
    
  }
  
  //Get words
  ArrayList<Word> getWords()
  {
    
    return words;
    
  }
  
  Word getWord(int i)
  {
    
    return words.get(i);
    
  }
  
  void addWord(Word word)
  {
    
    words.add(word);
    
  }
  
  //Get and set actors
  ArrayList<Actor> getActors()
  {
    
    return actors;
    
  }
  
  void addActor(Actor a)
  {
    
    actors.add(a);
    
  }
  
  //Get type
  int getType()
  {
    
    return type;
    
  }
  
  //Get and set rehearsal
  int getRehearsal()
  {
    
    return rehearsal;
    
  }
  
  void setRehearsal(int r)
  {
    
    rehearsal = r;
    
  }
  
  //Overriden in ParaphraseNote
  void actorSaid(String s)
  {
  }
  
  String getSaid()
  {
    
    return "";
    
  }
  
}
