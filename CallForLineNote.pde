class CallForLineNote extends Note
{
  
  //Constructors
  //Default Constructor
  CallForLineNote()
  {
    
    super();
    type = 0;
    
  }
  
  //Constructor given lines and words
  CallForLineNote(ArrayList<Line> ls, ArrayList<Word> ws)
  {
    
    super();
    lines.addAll(ls);
    words.addAll(ws);
    type = 2;
    
    for(Line line : lines)
    {
      
      if(actors.indexOf(line.getActor()) == -1)
        actors.add(line.getActor());
        
    }
    
    giveToActors();
    
  }
  
}
