class Page
{
  
  //Variable declarations
  protected ArrayList<Line> lines;
  protected int number;
  protected PVector pos;
  
  //Constructor
  //Default Constructor
  Page()
  {
    
    lines = new ArrayList<Line>();
    pos = new PVector();
    
  }
  
  //Constructor given page number
  Page(int p)
  {
    
    lines = new ArrayList<Line>();
    number = p;
    pos = new PVector();
    
  }
  
  Page(int p, PVector po)
  {
    
    lines = new ArrayList<Line>();
    number = p;
    pos = po;
    
  }
  
  //Get and set page number
  int getNumber()
  {
    
    return number;
    
  }
  
  void setNumber(int p)
  {
    
    number = p;
    
  }
  
  //Get and set lines
  ArrayList<Line> getLines()
  {
    
    return lines;
    
  }
  
  Line getLine(int i)
  {
    
    return lines.get(i);
    
  }
  
  void setLine(int i, Line l)
  {
    
    lines.set(i, l);
    
  }
  
  void addLine(Line l)
  {
    
    lines.add(l);
    
  }
  
  //Get and set pos
  PVector getPos()
  {
    
    return pos;
    
  }
  
  void setPos(PVector p)
  {
    
    pos = p;
    
  }
  
  void setPos(float x, float y)
  {
    
    pos.set(x, y);
    
  }
  
}
