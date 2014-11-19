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
    str += "ACTOR SAID:\n\t";
    
    str += said;
    
    str +="\nINSTEAD OF:\n\t\t... ";
    
    for(Word w : words)
    {
      str += w.getWord() + " ";
    }
    
    str += " ...\n\n";
    
    return str;
  }
  
}
