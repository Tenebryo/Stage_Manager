class MissedCueNote extends Note
{
  
  //Constructors
  //Default Constructor
  MissedCueNote()
  {
    
    super();
    type = 0;
    
  }
  
  //Constructor given lines and words
  MissedCueNote(ArrayList<Line> ls, ArrayList<Word> ws)
  {
    
    super();
    lines.addAll(ls);
    words.addAll(ws);
    type = 3;
    
    for(Line line : lines)
    {
      
      if(actors.indexOf(line.getActor()) == -1)
        actors.add(line.getActor());
        
    }
    
    giveToActors();
    
  }
  
  String toString()
  {
    String str = "MISSED CUE, PAGE "+str(lines.get(0).getPage())+"\n\tLINE:\n\t\t";
    
    for(Line l : lines)
    {
      for(Word w : l.getWords())
      {
        str += w.getWord() + " ";
      }
      str += "\n\t";
    }
    str += "MISSED:\n\t... ";
    
    for(Word w : words)
    {
      str += w.getWord() + " ";
    }
    
    str += " ...\n\n";
    
    return str;
  }
  
}
