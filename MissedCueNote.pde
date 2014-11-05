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
  
}
