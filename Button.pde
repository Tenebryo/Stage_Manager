class Button
{
  
  //Variable declarations
  protected PVector topLeftPos;
  protected PVector bottomRightPos;
  protected String text;
  protected boolean typing;
  //ArrayList<Integer> states;
  
  //Constructors
  //Default Constructor
  Button()
  {
    
    topLeftPos = new PVector();
    bottomRightPos = new PVector();
    text = "";
    typing = false;
    
  }
  
  //Constructor given text
  Button(String txt)
  {
    
    topLeftPos = new PVector();
    bottomRightPos = new PVector();
    text = txt;
    typing = false;
    
  }
  
  //Constructor given 5 inputs
  Button(float px, float py, String txt, boolean t, boolean l)
  {
    
    if(t)
    {
      
      if(l)
      {
        
        topLeftPos = new PVector(px, py);
        bottomRightPos = new PVector(px + 2 * xMargin + textWidth(txt), py + 2 * yMargin + textHeight);
        
      }
      
      else
      {
        
        topLeftPos = new PVector(px - 2 * xMargin - textWidth(txt), py);
        bottomRightPos = new PVector(px, py + 2 * yMargin + textHeight);
        
      }
      
    }
    
    else
    {
      
      if(l)
      {
        
        topLeftPos = new PVector(px, py - 2 * yMargin - textHeight);
        bottomRightPos = new PVector(px + 2 * xMargin + textWidth(txt), py);
        
      }
      
      else
      {
        
        topLeftPos = new PVector(px - 2 * xMargin - textWidth(txt), py - 2 * yMargin - textHeight);
        bottomRightPos = new PVector(px, py);
        
      }
      
    }
    
    text = txt;
    typing = false;
    
  }
  
  //Display Method
  void display()
  {
    
    rectMode(CORNERS);
    fill(153);
    noStroke();
    
    if((mouseX >= topLeftPos.x && mouseX <= bottomRightPos.x && mouseY >= topLeftPos.y && mouseY <= bottomRightPos.y) || typing)
      stroke(255);
    
    rect(topLeftPos.x, topLeftPos.y, bottomRightPos.x, bottomRightPos.y);
    fill(255);
    
    if(typing)
      fill(0, 255, 255);
    
    textAlign(LEFT, TOP);
    text(text, topLeftPos.x + xMargin, topLeftPos.y + yMargin);
    
  }
  
  //Get and set topLeftPos
  PVector getTLP()
  {
    
    return topLeftPos;
    
  }
  
  float getTLPx()
  {
    
    return topLeftPos.x;
    
  }
  
  float getTLPy()
  {
    
    return topLeftPos.y;
    
  }
  
  void setTLP(PVector tlp)
  {
    
    topLeftPos = tlp;
    
  }
  
  void setTLP(float x, float y)
  {
    
    topLeftPos.set(x, y);
    
  }
  
  //Get and set bottomRightPos
  PVector getBRP()
  {
    
    return bottomRightPos;
    
  }
  
  float getBRPx()
  {
    
    return bottomRightPos.x;
    
  }
  
  float getBRPy()
  {
    
    return bottomRightPos.y;
    
  }
  
  void setBRP(PVector brp)
  {
    
    bottomRightPos = brp;
    
  }
  
  void setBRP(float x, float y)
  {
    
    bottomRightPos.set(x, y);
    
  }
  
  //Get and set text
  String getText()
  {
    
    return text;
    
  }
  
  void setText(String t)
  {
    
    text = t;
    
  }
  
  //Get and set typing
  boolean getTyping()
  {
    
    return typing;
    
  }
  
  void setTyping(boolean b)
  {
    
    typing = b;
    
  }
  
}
