class MenuButton extends Button
{
  
  //Default Constructor
  MenuButton()
  {
    
    super();
    
  }
  
  //Constructor given text
  MenuButton(String txt)
  {
    
    super(txt);
    
  }
  
  MenuButton(float tlpx, float tlpy, float brpx, float brpy, String txt)
  {
    
    topLeftPos = new PVector(tlpx, tlpy);
    bottomRightPos = new PVector(brpx, brpy);
    text = txt;
    typing = false;
    
  }
  
  //Constructor given 5 inputs
  MenuButton(float px, float py, String txt, boolean t, boolean l)
  {
    
    super(px, py, txt, t, l);
    
  }
  
  //Display Method
  void display()
  {
    
    rectMode(CORNERS);
    textAlign(CENTER, TOP);
    noStroke();
    
    if((mouseX > topLeftPos.x && mouseX < bottomRightPos.x && mouseY > topLeftPos.y && mouseY < bottomRightPos.y) || typing)
    {
      
      fill(0, 0, 255);
      rect(topLeftPos.x, topLeftPos.y, bottomRightPos.x, bottomRightPos.y);
      fill(0);
      text(text, topLeftPos.x + xMargin + textWidth(Menu.LONGEST) / 2, topLeftPos.y);
      
    }
    
    else
    {
      
      fill(153);
      rect(topLeftPos.x, topLeftPos.y, bottomRightPos.x, bottomRightPos.y);
      fill(255);
      text(text, topLeftPos.x + xMargin + textWidth(Menu.LONGEST) / 2, topLeftPos.y);
      
    }
    
  }
  
}
