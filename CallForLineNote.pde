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
  
  String toString()
  {
    String str = "CALLED FOR LINE, PAGE "+str(lines.get(0).getPage())+"\n\tLINE:\n\t\t";
    
    for(Line l : lines)
    {
      for(Word w : l.getWords())
      {
        str += w.getWord() + " ";
      }
      str += "\n\t";
    }
    str += "CALLED AT:\n\t... ";
    
    for(Word w : words)
    {
      str += w.getWord() + " ";
    }
    
    str += " ...\n\n";
    
    return str;
  }
  
}
