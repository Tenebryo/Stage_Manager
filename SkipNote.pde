class SkipNote extends Note
{
  
  //Constructors
  //Default Constructor
  SkipNote()
  {
    
    super();
    type = 0;
    
  }
  
  //Constructor given lines and words
  SkipNote(ArrayList<Line> ls, ArrayList<Word> ws)
  {
    
    super();
    lines.addAll(ls);
    words.addAll(ws);
    type = 0;
    
    for(Line line : lines)
    {
      
      if(actors.indexOf(line.getActor()) == -1)
        actors.add(line.getActor());
        
    }
    
    giveToActors();
    
  }
  
}
