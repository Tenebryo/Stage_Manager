class Word
{
  
  //Variable declarations
  protected String word;
  //posInLine describes the Word's position relative to the beginning of the line. 
  protected PVector posInLine;
  protected boolean highlighted;
  
  Word(String w)
  {
    
    word = w;
    posInLine = new PVector();
    highlighted = false;
    
  }
  
  Word(String w, PVector p)
  {
    
    word = w;
    posInLine = p;
    highlighted = false;
    
  }
  
  //Get and set word
  String getWord()
  {
    
    return word;
    
  }
  
  void setWord(String w)
  {
    
    word = w;
    
  }
  
  //Get and set posInLine
  PVector getPos()
  {
    
    return posInLine;
    
  }
  
  void setPos(float x, float y)
  {
    
    posInLine.set(x, y);
    
  }
  
  //Get and set highlighting
  boolean isHighlighted()
  {
    
    return highlighted;
    
  }
  
  void setHighlight(boolean h)
  {
    
    highlighted = h;
    
  }
  
  //toString
  String toString()
  {
    
    return word;
    
  }
  
}
