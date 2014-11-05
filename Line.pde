class Line
{
  
  //Variable declarations
  protected ArrayList<Word> words;
  protected Actor actor;
  protected int actorPos;
  //posOnPage describes the Line's position relative to the beginning of the Page.
  protected PVector posOnPage;
  protected int page;
  
  //Constructors
  //Default Constructor
  Line()
  {
    
    words = new ArrayList<Word>();
    posOnPage = new PVector();
    
  }
  
  //Page number and Actor Constructor
  Line(Actor a, int p)
  {
    
    words = new ArrayList<Word>();
    actor = a;
    posOnPage = new PVector();
    page = p;
    
  }
  
  //Full Constructor
  Line(ArrayList<Word> w, Actor a, int p)
  {
    
    words = w;
    actor = a;
    posOnPage = new PVector();
    page = p;
    
  }
  
  //Full Constructor creates words from String
  Line(String s, Actor a, int p)
  {
    
    words = new ArrayList<Word>();
    
    for(String word : s.split(" "))
    {
      
      words.add(new Word(word));
      
    }
    
    actor = a;
    posOnPage = new PVector();
    page = p;
    
  }
  
  //Constructor for loading in
  Line(Actor a, int p, PVector pos)
  {
    
    words = new ArrayList<Word>();
    actor = a;
    page = p;
    posOnPage = pos;
    
  }
  
  //Get and set page number
  int getPage()
  {
    
    return page;
    
  }
  
  void setPage(int p)
  {
    
    page = p;
    
  }
  
  //Get and set words (or Words in words)
  ArrayList<Word> getWords()
  {
    
    return words;
    
  }
  
  Word getWord(int i)
  {
    
    return words.get(i);
    
  }
  
  void setWords(ArrayList<Word> w)
  {
    
    words = w;
    
  }
  
  void setWord(int i, Word word)
  {
    
    if(i < words.size())
      words.set(i, word);
    
  }
  
  void setWord(int i, String word)
  {
    
    if(i < words.size())
      words.set(i, new Word(word));
    
  }
  
  //Add to words
  void addWord(Word word)
  {
    
    words.add(word);
    
  }
  
  void addWord(String word)
  {
    
    words.add(new Word(word));
    
  }
  
  void addWord(int i, String word)
  {
    
    words.add(i, new Word(word));
    
  }
  
  Word removeWord(int i)
  {
    
    return words.remove(i);
    
  }
  
  //Get and set actor
  Actor getActor()
  {
    
    return actor;
    
  }
  
  void setActor(Actor a)
  {
    
    actor = a;
    
  }
  
  //Get and set actorPos
  int getActorPos()
  {
    
    return actorPos;
    
  }
  
  void setActorPos(int p)
  {
    
    actorPos = p;
    
  }
  
  //Get and set posOnPage
  PVector getPos()
  {
    
    return posOnPage;
    
  }
  
  void setPos(float x, float y)
  {
    
    posOnPage.set(x, y);
    
  }
  
  //toString
  String toString()
  {
    
    String toReturn = "";
    toReturn += actor.charName + ".";
    
    for(Word word : words)
    {
      
      toReturn += word + " ";
      
    }
    
    toReturn += "(" + page + ")";
    
    return toReturn;
    
  }
  
}
