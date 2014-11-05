class ParaphraseNote extends Note
{
  
  String said;
  
  ParaphraseNote()
  {
    
    super();
    said = "";
    type = 1;
    
  }
  
  ParaphraseNote(ArrayList<Line> ls, ArrayList<Word> ws)
  {
    
    super();
    lines.addAll(ls);
    words.addAll(ws);
    type = 1;
    
    for(Line line : lines)
    {
      
      if(actors.indexOf(line.getActor()) == -1)
        actors.add(line.getActor());
        
    }
    
    giveToActors();
    
  }
  
  void actorSaid(String s)
  {
    
    said = s;
    
  }
  
  String getSaid()
  {
    
    return said;
    
  }
  
}
