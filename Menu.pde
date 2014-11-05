class Menu
{
  
  //Variable declarations
  protected PVector topLeftPos;
  protected PVector bottomRightPos;
  protected ArrayList<MenuButton> buttons;
  static final String LONGEST = "CALLED FOR LINE";
  static final int COUNT = 4;
  
  //Constructors
  //Default Constructor
  Menu()
  {
    
    topLeftPos = new PVector();
    bottomRightPos = new PVector();
    buttons = new ArrayList<MenuButton>();
    
  }
  
  //Position constructor
  Menu(PVector tlp, float w)
  {
    
    topLeftPos = tlp;
    buttons = new ArrayList<MenuButton>();
    buttons.add(new MenuButton(tlp.x, tlp.y, tlp.x + 2 * xMargin + w, tlp.y + textHeight, "SKIPPED"));
    buttons.add(new MenuButton(tlp.x, tlp.y + textHeight, tlp.x + 2 * xMargin + w, tlp.y + 2 * textHeight, "PARAPHRASED"));
    buttons.add(new MenuButton(tlp.x, tlp.y + 2 * textHeight, tlp.x + 2 * xMargin + w, tlp.y + 3 * textHeight, "CALLED FOR LINE"));
    buttons.add(new MenuButton(tlp.x, tlp.y + 3 * textHeight, tlp.x + 2 * xMargin + w, tlp.y + 4 * textHeight, "MISSED CUE"));
    
  }
  
  //Get and set buttons
  ArrayList<MenuButton> getButtons()
  {
    
    return buttons;
    
  }
  
  //Add the rest later
  
}
