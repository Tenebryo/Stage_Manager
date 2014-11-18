class Script 
{
  /*NOTES
   
   Where is space after character period coming from?
   Edit words and paraphrase will only work on the first line selected
   
   */

  /*TODO
   
   Instead of missing page announcement, search for page number first to see if the missing page number can be found
   Fix separateLines() so that each interlinear line poses a question
   Gil still wants to recognize stage directions (idea for that, do this in word before converting to txt).
   Jumped line and missed cue
   
   */

  //Import IO

  //Declare Array to read in each line of the script text file
  String[] script;
  String[] actorArray;
  String[] pageArray;
  String[] lineArray;
  String[] noteArray;

  //Declare ArrayLists for lines, actors, pages, and notes
  ArrayList<Line> lines;
  ArrayList<Actor> actors;
  ArrayList<Page> pages;
  ArrayList<Note> notes;

  /*Types of Notes
   
   0 = SKIPPED LINE
   1 = PARAPHRASED
   2 = CALLED FOR LINE
   3 = MISSED CUE
   
   */


  //State
  /*ENUM substitutes
   
   0 = Displaying Script
   1 = Missing Page
   2 = Unsaved Quit
   3 = Jump to Page
   4 = Highlighting
   5 = Assigning Note
   6 = Editing script
   7 = Highlighting for edit
   8 = Assigning edit
   9 = Assigning Paraphrase
   10 = Jump to Page edit
   11 = Separating line
   
   */
  static final int DISPLAYSCRIPT = 0;
  static final int MISSINGPAGE = 1;
  static final int UNSAVEDQUIT = 2;
  static final int JUMPTOPAGE = 3;
  static final int HIGHLIGHTING = 4;
  static final int ASSIGNINGNOTE = 5;
  static final int EDITINGSCRIPT = 6;
  static final int HIGHLIGHTINGEDIT = 7;
  static final int ASSIGNINGEDIT = 8;
  static final int ASSIGNINGPPHRASE = 9;
  static final int JUMPTOPAGEEDIT = 10;
  static final int SEPARATELINE = 11;

  int state;
  int prevState; //Necessary for quitting without saving and hitting cancel

  //Buttons
  /*ENUM substitutes
   
   0:
   0, 0 = Quit
   0, 1 = Jump to Page
   0, 2 = Save
   0, 3 = Edit Script
   1:
   1, 0 = Quit
   2:
   2, 0 = Save and Quit
   2, 1 = Don't Save and Quit
   2, 2 = Cancel
   3:
   3, 0 = Quit
   3, 1 = Jump to Page
   3, 2 = Save
   3, 3 = Edit Script
   4:
   4, 0 = Quit
   4, 1 = Jump to Page
   4, 2 = Save
   4, 3 = Edit Script
   5:
   5, 0 = Quit
   5, 1 = Jump to Page
   5, 2 = Save
   5, 3 = Edit Script
   5, 4 = Skipped
   5, 5 = Paraphrase
   5, 6 = Called for line
   6:
   6, 0 = Quit
   6, 1 = Jump to Page
   6, 2 = Save
   6, 3 = Back
   6, 4 = Edit words
   6, 5 = Separate line
   6, 6 = Add line
   6, 7 = Remove line
   7:
   7, 0 = Quit
   7, 1 = Jump to Page
   7, 2 = Save
   7, 3 = Back
   
   */
  ArrayList<ArrayList<Button>> buttons;
  boolean editButton;

  //Boolean to chek saved
  boolean saved;

  //Position for display
  PVector startPos;
  PVector pos;

  //Page numbers
  int start;
  int currentPage;

  //Temp string for typing
  String typing;

  //Mouse positions for highlighting
  PVector mouseStart;
  PVector mouseEnd;

  //Selected words
  ArrayList<Word> selected;
  ArrayList<Line> selectedLines;

  //Menu for assigning notes
  Menu menu;

  String prefix;

  Script(String _prefix)
  {
    prefix = _prefix;
    println(prefix);  
    //Set the background color to black
    background(0);
    //Load in the script
    println("Loading Script");
    script = loadStrings(prefix + "/script.txt");
    actorArray = loadStrings(prefix + "/actors.txt");
    pageArray = loadStrings(prefix + "/pages.txt");
    lineArray = loadStrings(prefix + "/lines.txt");
    noteArray = loadStrings(prefix + "/savedNotes.txt");
    println("Done");
    //Initialize ArrayLists for lines, actors, pages, and notes
    lines = new ArrayList<Line>();
    actors = new ArrayList<Actor>();
    pages = new ArrayList<Page>();
    notes = new ArrayList<Note>();
    //Set state to 0
    state = DISPLAYSCRIPT;
    //Initialize buttons
    buttons = new ArrayList<ArrayList<Button>>();
    editButton = false;
    //Initially saved
    saved = true;
    //Initialize pos
    startPos = new PVector(xMargin, 4 * yMargin + textHeight);
    pos = startPos;
    //Separate the Lines
    println("Separating Lines");
    separateLines();
    println("Done");
    currentPage = start;
    //Create the buttons
    addButtons();
    buttons.get(DISPLAYSCRIPT).get(1).setText("JUMP TO PAGE: " + currentPage);
    println("Setup Done");
  }

  void draw()
  {

    background(0);

    switch(state)
    {
    case DISPLAYSCRIPT:
    case JUMPTOPAGE:
    case HIGHLIGHTING:
    case ASSIGNINGNOTE:
    case EDITINGSCRIPT:
    case HIGHLIGHTINGEDIT:
    case JUMPTOPAGEEDIT:
    case SEPARATELINE:

      displayScript();
      break;

    case MISSINGPAGE:

      fill(255);
      textAlign(CENTER, CENTER);
      text("MISSING PAGE " + lines.get(lines.size() - 1).getPage() + ", PLEASE CORRECT SCRIPT", width / 2, height / 2);
      break;

    case UNSAVEDQUIT:

      fill(255);
      textAlign(CENTER, CENTER);
      text("NOT SAVED, WOULD YOU LIKE TO SAVE CHANGES?", width / 2, height / 2);
      break;

    case ASSIGNINGEDIT:

      displayScript();
      fill(255, 0, 0);
      text("CHANGE TO: " + typing, xMargin, pages.get(selectedLines.get(0).getPage() - start).getPos().y + selectedLines.get(0).getPos().y - textHeight - pos.y);
      break;

    case ASSIGNINGPPHRASE:

      displayScript();
      fill(255, 0, 0);
      text("ACTOR SAID: " + typing, xMargin, pages.get(selectedLines.get(0).getPage() - start).getPos().y + selectedLines.get(0).getPos().y - textHeight - pos.y);
      break;
    }

    //Display all the buttons for this state
    for (Button button : buttons.get (state))
    {

      button.display();
    }
  }

  void mousePressed()
  {

    //Boolean for whether or not a button has been clicked
    boolean buttonClicked = false;

    //Run through the buttons in this state
    for (int i = 0; i < buttons.get(state).size(); i++)
    {
      //Check to see if the button has been pressed
      if (mouseX >= buttons.get(state).get(i).getTLPx() && mouseX <= buttons.get(state).get(i).getBRPx() && mouseY >= buttons.get(state).get(i).getTLPy() && mouseY <= buttons.get(state).get(i).getBRPy())
      {
        buttonClicked = true;
        buttonClick(state, i);
        break;
      }
    }

    //Only enter here if no button has been pressed
    if (!buttonClicked)
    {

      switch(state)
      {

      case DISPLAYSCRIPT:

        mouseStart = new PVector(mouseX, mouseY);
        selected = new ArrayList<Word>();
        selectedLines = new ArrayList<Line>();

        for (Page page : pages)
        {

          if (page.getPos().y > height + pos.y)
            break;

          if (page.getPos().y + page.getLine(page.getLines().size() - 1).getPos().y + page.getLine(page.getLines().size() - 1).getWord(page.getLine(page.getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight >= pos.y)
          {

            for (Line line : page.getLines ())
            {

              boolean lineSelected = false;

              for (Word word : line.getWords ())
              {

                if ((mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord())) || (mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x >= page.getPos().x + line.getPos().x + word.getPos().x) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord()) && mouseStart.x >= page.getPos().x + line.getPos().x + word.getPos().x))
                {

                  lineSelected = true;
                  word.setHighlight(true);
                  selected.add(word);
                } else
                {

                  word.setHighlight(false);
                }
              }

              if (lineSelected)
                selectedLines.add(line);
            }
          }
        }

        state = HIGHLIGHTING;
        break;

      case 3:

        buttons.get(JUMPTOPAGE).get(1).setTyping(false);
        buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + currentPage);
        state = DISPLAYSCRIPT;
        break;

      case 5:

        for (Word word : selected)
        {

          word.setHighlight(false);
        }

        mouseStart = new PVector(mouseX, mouseY);
        selected.clear();
        selectedLines.clear();

        for (Page page : pages)
        {

          if (page.getPos().y > height + pos.y)
            break;

          if (page.getPos().y + page.getLine(page.getLines().size() - 1).getPos().y + page.getLine(page.getLines().size() - 1).getWord(page.getLine(page.getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight >= pos.y)
          {

            for (Line line : page.getLines ())
            {

              boolean lineSelected = false;

              for (Word word : line.getWords ())
              {

                if ((mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord())) || (mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x >= page.getPos().x + line.getPos().x + word.getPos().x) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord()) && mouseStart.x >= page.getPos().x + line.getPos().x + word.getPos().x))
                {

                  lineSelected = true;
                  word.setHighlight(true);
                  selected.add(word);
                } else
                {

                  word.setHighlight(false);
                }
              }

              if (lineSelected)
                selectedLines.add(line);
            }
          }
        }

        buttons.get(ASSIGNINGNOTE).clear();
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(0));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(1));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(2));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(3));
        state = HIGHLIGHTING;
        break;

      case HIGHLIGHTINGEDIT:

        mouseStart = new PVector(mouseX, mouseY);
        selected = new ArrayList<Word>();
        selectedLines = new ArrayList<Line>();

        for (Page page : pages)
        {

          if (page.getPos().y > height + pos.y)
            break;

          if (page.getPos().y + page.getLine(page.getLines().size() - 1).getPos().y + page.getLine(page.getLines().size() - 1).getWord(page.getLine(page.getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight >= pos.y)
          {

            for (Line line : page.getLines ())
            {

              boolean lineSelected = false;

              for (Word word : line.getWords ())
              {

                if ((mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord())) || (mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x >= page.getPos().x + line.getPos().x + word.getPos().x) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord()) && mouseStart.x >= page.getPos().x + line.getPos().x + word.getPos().x))
                {

                  lineSelected = true;
                  word.setHighlight(true);
                  selected.add(word);
                } else
                {

                  word.setHighlight(false);
                }
              }

              if (lineSelected)
                selectedLines.add(line);
            }
          }
        }

        break;
      }
    }
  }

  void mouseDragged()
  {

    if (state == HIGHLIGHTING)
    {

      PVector mouseEnd = new PVector(mouseX, mouseY);
      selected = new ArrayList<Word>();
      selectedLines = new ArrayList<Line>();

      for (Page page : pages)
      {

        if (page.getPos().y > height + pos.y)
          break;

        if (page.getPos().y + page.getLine(page.getLines().size() - 1).getPos().y + page.getLine(page.getLines().size() - 1).getWord(page.getLine(page.getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight >= pos.y)
        {

          for (Line line : page.getLines ())
          {

            boolean lineSelected = false;

            for (Word word : line.getWords ())
            {

              if ((mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord())) || (mouseEnd.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseEnd.x >= page.getPos().x + line.getPos().x + word.getPos().x) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord()) && mouseEnd.x >= page.getPos().x + line.getPos().x + word.getPos().x))
              {

                lineSelected = true;
                word.setHighlight(true);
                selected.add(word);
              } else
              {

                word.setHighlight(false);
              }
            }

            if (lineSelected)
              selectedLines.add(line);
          }
        }
      }

      if (selected.size() == 0)
      {

        PVector temp = mouseStart;
        mouseStart = mouseEnd;
        mouseEnd = temp;

        for (Page page : pages)
        {

          if (page.getPos().y > height + pos.y)
            break;

          if (page.getPos().y + page.getLine(page.getLines().size() - 1).getPos().y + page.getLine(page.getLines().size() - 1).getWord(page.getLine(page.getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight >= pos.y)
          {

            for (Line line : page.getLines ())
            {

              boolean lineSelected = false;

              for (Word word : line.getWords ())
              {

                if ((mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord())) || (mouseEnd.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseEnd.x >= page.getPos().x + line.getPos().x + word.getPos().x) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord()) && mouseEnd.x >= page.getPos().x + line.getPos().x + word.getPos().x))
                {

                  lineSelected = true;
                  word.setHighlight(true);
                  selected.add(word);
                } else
                {

                  word.setHighlight(false);
                }
              }

              if (lineSelected)
                selectedLines.add(line);
            }
          }
        }

        mouseEnd = mouseStart;
        mouseStart = temp;
      }
    } else if (state == HIGHLIGHTINGEDIT)
    {

      PVector mouseEnd = new PVector(mouseX, mouseY);
      selected = new ArrayList<Word>();
      selectedLines = new ArrayList<Line>();

      for (Page page : pages)
      {

        if (page.getPos().y > height + pos.y)
          break;

        if (page.getPos().y + page.getLine(page.getLines().size() - 1).getPos().y + page.getLine(page.getLines().size() - 1).getWord(page.getLine(page.getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight >= pos.y)
        {

          for (Line line : page.getLines ())
          {

            boolean lineSelected = false;

            for (Word word : line.getWords ())
            {

              if ((mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord())) || (mouseEnd.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseEnd.x >= page.getPos().x + line.getPos().x + word.getPos().x) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord()) && mouseEnd.x >= page.getPos().x + line.getPos().x + word.getPos().x))
              {

                lineSelected = true;
                word.setHighlight(true);
                selected.add(word);
              } else
              {

                word.setHighlight(false);
              }
            }

            if (lineSelected)
              selectedLines.add(line);
          }
        }
      }

      if (selected.size() == 0)
      {

        PVector temp = mouseStart;
        mouseStart = mouseEnd;
        mouseEnd = temp;

        for (Page page : pages)
        {

          if (page.getPos().y > height + pos.y)
            break;

          if (page.getPos().y + page.getLine(page.getLines().size() - 1).getPos().y + page.getLine(page.getLines().size() - 1).getWord(page.getLine(page.getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight >= pos.y)
          {

            for (Line line : page.getLines ())
            {

              boolean lineSelected = false;

              for (Word word : line.getWords ())
              {

                if ((mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord())) || (mouseEnd.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseEnd.x >= page.getPos().x + line.getPos().x + word.getPos().x) || (mouseStart.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y <= page.getPos().y + line.getPos().y + word.getPos().y - pos.y + textHeight && mouseEnd.y >= page.getPos().y + line.getPos().y + word.getPos().y - pos.y && mouseStart.x <= page.getPos().x + line.getPos().x + word.getPos().x + textWidth(word.getWord()) && mouseEnd.x >= page.getPos().x + line.getPos().x + word.getPos().x))
                {

                  lineSelected = true;
                  word.setHighlight(true);
                  selected.add(word);
                } else
                {

                  word.setHighlight(false);
                }
              }

              if (lineSelected)
                selectedLines.add(line);
            }
          }
        }

        mouseEnd = mouseStart;
        mouseStart = temp;
      }
    }
  }

  void mouseReleased()
  {

    if (state == HIGHLIGHTING)
    {

      if (selected.size() > 0)
      {

        state = ASSIGNINGNOTE;
        prepareMenu(mouseX, mouseY);
      } else
      {

        state = DISPLAYSCRIPT;
      }
    } else if (state == EDITINGSCRIPT)
    {

      if (editButton)
      {

        state = HIGHLIGHTINGEDIT;
        editButton = false;
      }
    } else if (state == HIGHLIGHTINGEDIT)
    {

      if (selected.size() > 0)
      {

        state = ASSIGNINGEDIT;
        typing = "";
      } else
      {

        state = EDITINGSCRIPT;
      }
    }
  }

  void keyPressed()
  {

    switch(state)
    {

    case DISPLAYSCRIPT:
    case EDITINGSCRIPT:

      //Scroll down in script
      if (keyCode == DOWN)
      {

        if (pos.y < pages.get(pages.size() - 1).getPos().y + pages.get(pages.size() - 1).getLine(pages.get(pages.size() - 1).getLines().size() - 1).getPos().y + pages.get(pages.size() - 1).getLine(pages.get(pages.size() - 1).getLines().size() - 1).getWord(pages.get(pages.size() - 1).getLine(pages.get(pages.size() - 1).getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight - height / 2)
        {

          pos.y += textHeight;
        }

        //If at the bottom, change currentPage to the last page (may not go down far enough to do so automatically)
        else
        {

          buttons.get(DISPLAYSCRIPT).get(1).setText("JUMP TO PAGE: " + pages.get(pages.size() - 1).getNumber());
        }

        //If passing to the next page, changes currentPage
        if (currentPage - start < pages.size() - 1 && pages.get(currentPage - start + 1).getPos().y <= 4 * yMargin + textHeight + pos.y)
        {

          currentPage++;
          buttons.get(DISPLAYSCRIPT).get(1).setText("JUMP TO PAGE: " + currentPage);
        }
      }

      //Scroll up in script
      else if (keyCode == UP)
      {

        if (pos.y > 4 * yMargin + textHeight)
        {

          pos.y -= textHeight;
        }

        //If passing to the previous page, changes currentPage
        if (currentPage - start > 0 && pages.get(currentPage - start).getPos().y >= 4 * yMargin + textHeight + pos.y)
        {

          currentPage--;
          buttons.get(DISPLAYSCRIPT).get(1).setText("JUMP TO PAGE: " + currentPage);
        }
      } else if (keyCode == RIGHT)
      {

        if (currentPage - start < pages.size() - 1)
        {

          currentPage++;
          buttons.get(DISPLAYSCRIPT).get(1).setText("JUMP TO PAGE: " + currentPage);
          pos.set(pages.get(currentPage - start).getPos().x, pages.get(currentPage - start).getPos().y - 4 * yMargin - textHeight);
        }
      } else if (keyCode == LEFT)
      {

        if (currentPage - start > 0)
        {

          if (pos.y + 4 * yMargin + textHeight == pages.get(currentPage - start).getPos().y)
          {

            currentPage--;
            buttons.get(DISPLAYSCRIPT).get(1).setText("JUMP TO PAGE: " + currentPage);
            pos.set(pages.get(currentPage - start).getPos().x, pages.get(currentPage - start).getPos().y - 4 * yMargin - textHeight);
          } else
          {

            pos.set(pages.get(currentPage - start).getPos().x, pages.get(currentPage - start).getPos().y - 4 * yMargin - textHeight);
          }
        } else
        {

          pos.set(pages.get(currentPage - start).getPos().x, pages.get(currentPage - start).getPos().y - 4 * yMargin - textHeight);
        }
      }

      break;

    case JUMPTOPAGE:

      if (key >= 48 && key <= 57)
      {

        typing += key;
        buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + typing);
      } else if (key == 8 && typing.length() > 0)
      {

        typing = typing.substring(0, typing.length() - 1);
        buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + typing);
      } else if (keyCode == ENTER || keyCode == RETURN)
      {

        if (pageNumber(typing) >= start && pageNumber(typing) <= pages.get(pages.size() - 1).getNumber())
        {

          currentPage = pageNumber(typing);
          buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + currentPage);
          buttons.get(JUMPTOPAGE).get(1).setTyping(false);
          pos.set(pages.get(currentPage - start).getPos().x, pages.get(currentPage - start).getPos().y - 4 * yMargin - textHeight);
          typing = "";
          state = DISPLAYSCRIPT;
        } else
        {

          key = 27;
        }
      }

      if (key == 27)
      {

        key = 0;
        buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + currentPage);
        buttons.get(JUMPTOPAGE).get(1).setTyping(false);
        typing = "";
        state = DISPLAYSCRIPT;
      }

      break;

    case JUMPTOPAGEEDIT:

      if (key >= 48 && key <= 57)
      {

        typing += key;
        buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + typing);
      } else if (key == 8 && typing.length() > 0)
      {

        typing = typing.substring(0, typing.length() - 1);
        buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + typing);
      } else if (keyCode == ENTER || keyCode == RETURN)
      {

        if (pageNumber(typing) >= start && pageNumber(typing) <= pages.get(pages.size() - 1).getNumber())
        {

          currentPage = pageNumber(typing);
          buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + currentPage);
          buttons.get(JUMPTOPAGE).get(1).setTyping(false);
          pos.set(pages.get(currentPage - start).getPos().x, pages.get(currentPage - start).getPos().y - 4 * yMargin - textHeight);
          typing = "";
          state = EDITINGSCRIPT;
        } else
        {

          key = 27;
        }
      }

      if (key == 27)
      {

        key = 0;
        buttons.get(JUMPTOPAGE).get(1).setText("JUMP TO PAGE: " + currentPage);
        buttons.get(JUMPTOPAGE).get(1).setTyping(false);
        typing = "";
        state = EDITINGSCRIPT;
      }

      break;

    case ASSIGNINGNOTE:

      if (key == 27)
      {

        key = 0;

        for (Word word : selected)
        {

          word.setHighlight(false);
        }

        mouseStart = null;
        selected.clear();
        selectedLines.clear();
        buttons.get(ASSIGNINGNOTE).clear();
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(0));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(1));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(2));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(3));
        state = DISPLAYSCRIPT;
      }

      break;

    case ASSIGNINGEDIT:

      if ((keyCode >= 48 && keyCode <= 90) || key == ',' || key == '.' || key == ':' || key == ';' || key == '-' || key == '\'' || key == '!' || key == '?' || key == ' '  || key == '(' || key == ')')
      {

        typing += key;
      } else if (key == 8 && typing.length() > 0)
      {

        typing = typing.substring(0, typing.length() - 1);
      } else if (keyCode == ENTER || keyCode == RETURN)
      {

        int temp = selectedLines.get(0).getWords().indexOf(selected.get(0));
        saved = false;

        for (String word : typing.split (" "))
        {

          selectedLines.get(0).addWord(temp, word);
          temp++;
        }

        for (int i = selected.size () - 1; i >= 0; i--)
        {

          if (selectedLines.get(0).getWords().indexOf(selected.get(i)) != -1)
          {

            selectedLines.get(0).removeWord(selectedLines.get(0).getWords().indexOf(selected.get(i)));
          } else
          {

            selected.get(i).setHighlight(false);
            selected.remove(i);
          }
        }

        assignPositionsOld();
        selected.clear();
        selectedLines.clear();
        typing = "";
        state = EDITINGSCRIPT;
      } else if (key == 27)
      {

        key = 0;

        for (Word word : selected)
        {

          word.setHighlight(false);
        }

        selected.clear();
        selectedLines.clear();
        typing = "";
        state = EDITINGSCRIPT;
      }

      break;

    case ASSIGNINGPPHRASE:

      if ((keyCode >= 48 && keyCode <= 90) || key == ',' || key == '.' || key == ':' || key == ';' || key == '-' || key == '\'' || key == '!' || key == '?' || key == ' '  || key == '(' || key == ')')
      {

        typing += key;
      } else if (key == 8 && typing.length() > 0)
      {

        typing = typing.substring(0, typing.length() - 1);
      } else if (keyCode == ENTER || keyCode == RETURN)
      {

        saved = false;
        notes.get(notes.size() - 1).actorSaid(typing);

        for (Word word : selected)
        {

          word.setHighlight(false);
        }

        selected.clear();
        selectedLines.clear();
        typing = "";
        state = DISPLAYSCRIPT;
      } else if (key == 27)
      {

        key = 0;

        for (Word word : selected)
        {

          word.setHighlight(false);
        }

        selected.clear();
        selectedLines.clear();
        typing = "";
        state = EDITINGSCRIPT;
      }

      break;
    }
  }

  void displayScript()
  {

    textAlign(LEFT, TOP);

    //Loop through the pages
    for (Page page : pages)
    {

      //If the page is past the bottom of the display, quit the loop
      if (page.getPos().y > height + pos.y)
        break;

      //If the page should be displayed, enter this if
      if (page.getPos().y + page.getLine(page.getLines().size() - 1).getPos().y + page.getLine(page.getLines().size() - 1).getWord(page.getLine(page.getLines().size() - 1).getWords().size() - 1).getPos().y + textHeight >= pos.y)
      {

        //Display the page number
        fill(255);
        textAlign(CENTER, TOP);
        text("PAGE " + page.getNumber(), width / 2, page.getPos().y - pos.y);
        //Prepare to display the lines that are on the page
        textAlign(LEFT, TOP);

        //Loop through the lines on the page
        for (Line line : page.getLines ())
        {

          //If the line is past the bottom of the display, quit the loop
          if (page.getPos().y + line.getPos().y > height + pos.y)
            break;

          fill(255);
          //Display the actor
          text(line.getActor().getCharName() + ".", page.getPos().x + line.getPos().x, page.getPos().y + line.getPos().y - pos.y);


          for (Word word : line.getWords ())
          {

            //If the word is past the bottom of the display, quit the loop
            if (page.getPos().y + line.getPos().y + word.getPos().y > height + pos.y)
              break;

            fill(255);

            if (word.isHighlighted())
            {

              switch(state)
              {

              case HIGHLIGHTING:
              case HIGHLIGHTINGEDIT:

                fill(0, 255, 255);
                break;

              case ASSIGNINGNOTE:
              case ASSIGNINGEDIT:

                fill(0, 255, 0);
                break;
              }
            }

            //Display the word
            text(word.getWord() + " ", page.getPos().x + line.getPos().x + word.getPos().x, page.getPos().y + line.getPos().y + word.getPos().y - pos.y);
          }
        }
      }
    }
  }

  void separateLines()
  {

    if (actorArray == null || pageArray == null || lineArray == null || actorArray.length == 0 || pageArray.length == 0 || lineArray.length == 0)
    {

      //Temporary integer to store page number
      int page = -1;

      //Loops through every line of the script's text file
      for (String s : script)
      {

        //Checks if the line contains only a number
        if (pageNumber(s) != -1)
        {

          //Checks to make sure the new page number is one more than the previous page number (or the first page number reached)
          if (page != -1 && page != pageNumber(s))
          {

            state = MISSINGPAGE;
            break;
          } else
          {

            //Checks if this is the first page number, in which case it reassigns all previous pages to have this page number
            if (page == -1)
            {

              start = pageNumber(s);

              for (Line line : lines)
              {

                line.setPage(start);
              }
            }

            page = pageNumber(s) + 1;
          }
        }

        //This runs if the line is not a number
        else
        {

          //First check if the line has no actors in it
          if (s.indexOf('.') == -1 || !s.substring(0, s.indexOf('.')).toUpperCase().equals(s.substring(0, s.indexOf('.'))))
          {

            for (String word : s.split (" "))
            {

              if (lines.size() > 0)
                lines.get(lines.size() - 1).addWord(word);
            }
          } else
          {

            //Boolean for whether or not the actor currently exists
            boolean actorExists = false;

            //Loop through all the actors
            for (Actor actor : actors)
            {

              //If the Line's Actor exists, add a new Line with the current page number, the Line's Actor, and the words
              if (actor.charName.equals(s.substring(0, s.indexOf('.'))))
              {

                //Add the blank Line with Actor actor and page number page
                lines.add(new Line(s.substring(s.indexOf('.') + 1), actor, page));

                //Break out of the Actor loop and set actorExists to be true
                actorExists = true;
                break;
              }
            }

            //This runs if the Actor does not exist
            if (!actorExists)
            {

              //Adds the Actor to actors and adds the new Line
              actors.add(new Actor(s.substring(0, s.indexOf('.'))));
              lines.add(new Line(s.substring(s.indexOf('.') + 1), actors.get(actors.size() - 1), page));
            }
          }
        }
      }

      /* Not needed
      //Loops through every line to find lines with another line hidden in them
      for (int i = 0; i < lines.size (); i++)
      {

        //Loops through every actor to check if the line has their name capitalized
        for (Actor actor : actors)
        {

          //Loops through every word in lines.get(i) to compare with actor's name
          for (int j = 0; j < lines.get (i).getWords().size(); j++)
          {

            //Checks if the word is the actor's name capitalized with or without a period
            if (lines.get(i).getWord(j).getWord().equals(actor.getCharName()) || lines.get(i).getWord(j).getWord().equals(actor.getCharName() + "."))
            {

              //Separates the line into two separate lines
              lines.get(i).setWord(j + 1, " " + lines.get(i).getWord(j + 1).getWord());
              lines.add(i + 1, new Line(new ArrayList<Word>(lines.get(i).getWords().subList(j + 1, lines.get(i).getWords().size())), actor, lines.get(i).getPage()));
              lines.get(i).setWords(new ArrayList<Word>(lines.get(i).getWords().subList(0, j)));
            }
          }
        }
      }//*/

      assignPositionsNew();
    } else
    {

      for (int i = 0; i < actorArray.length; i += 2)
      {

        actors.add(new Actor(actorArray[i], actorArray[i + 1]));
      }

      for (int i = 0; i < pageArray.length; i += 2)
      {

        pages.add(new Page(Integer.parseInt(pageArray[i]), vectorFromString(pageArray[i + 1])));
      }

      start = pages.get(0).getNumber();

      int counter = 0;

      while (counter < lineArray.length)
      {

        Actor actor = actors.get(Integer.parseInt(lineArray[counter]));
        Page page = pages.get(Integer.parseInt(lineArray[counter + 1]) - start);
        PVector p = vectorFromString(lineArray[counter + 2]);
        lines.add(new Line(actor, page.getNumber(), p));
        counter += 3;

        for (int i = counter + 1; i < counter + 1 + 2 * Integer.parseInt (lineArray[counter]); i += 2)
        {
          lines.get(lines.size() - 1).addWord(new Word(lineArray[i], vectorFromString(lineArray[i + 1])));
        }

        counter += 1 + 2 * Integer.parseInt(lineArray[counter]);
        page.addLine(lines.get(lines.size() - 1));
      }
    }

    if (noteArray == null || noteArray.length == 0)
    {

      currentRehearsal = 1;
    } else
    {

      int counter = 0;

      while (counter < noteArray.length)
      {
        println(counter);
        switch(Integer.parseInt(noteArray[counter]))
        {

        case 0:

          notes.add(new SkipNote());
          counter++;

          for (int i = counter + 1; i < counter + 1 + Integer.parseInt (noteArray[counter]); i++)
          {

            notes.get(notes.size() - 1).addActor(actors.get(Integer.parseInt(noteArray[i])));
          }

          notes.get(notes.size() - 1).giveToActors();
          counter += 1 + Integer.parseInt(noteArray[counter]);
          int temp0 = Integer.parseInt(noteArray[counter]);
          counter++;

          for (int i = 0; i < temp0; i++)
          {

            notes.get(notes.size() - 1).addLine(lines.get(Integer.parseInt(noteArray[counter])));
            counter++;

            for (int j = counter + 1; j < counter + 1 + Integer.parseInt (noteArray[counter]); j++)
            {

              notes.get(notes.size() - 1).addWord(notes.get(notes.size() - 1).getLine(notes.get(notes.size() - 1).getLines().size() - 1).getWord(Integer.parseInt(noteArray[j])));
            }

            counter += 1 + Integer.parseInt(noteArray[counter]);
          }

          notes.get(notes.size() - 1).setRehearsal(Integer.parseInt(noteArray[counter]));
          counter++;
          break;

        case 1:

          notes.add(new ParaphraseNote());
          counter++;

          for (int i = counter + 1; i < counter + 1 + Integer.parseInt (noteArray[counter]); i++)
          {

            notes.get(notes.size() - 1).addActor(actors.get(Integer.parseInt(noteArray[i])));
          }

          notes.get(notes.size() - 1).giveToActors();
          counter += 1 + Integer.parseInt(noteArray[counter]);
          int temp1 = Integer.parseInt(noteArray[counter]);
          counter++;

          for (int i = 0; i < temp1; i++)
          {

            notes.get(notes.size() - 1).addLine(lines.get(Integer.parseInt(noteArray[counter])));
            counter++;

            for (int j = counter + 1; j < counter + 1 + Integer.parseInt (noteArray[counter]); j++)
            {

              notes.get(notes.size() - 1).addWord(notes.get(notes.size() - 1).getLine(notes.get(notes.size() - 1).getLines().size() - 1).getWord(Integer.parseInt(noteArray[j])));
            }

            counter += 1 + Integer.parseInt(noteArray[counter]);
          }

          notes.get(notes.size() - 1).actorSaid(noteArray[counter]);
          notes.get(notes.size() - 1).setRehearsal(Integer.parseInt(noteArray[counter + 1]));
          counter += 2;
          break;

        case 2:

          notes.add(new CallForLineNote());
          counter++;

          for (int i = counter + 1; i < counter + 1 + Integer.parseInt (noteArray[counter]); i++)
          {

            notes.get(notes.size() - 1).addActor(actors.get(Integer.parseInt(noteArray[i])));
          }

          notes.get(notes.size() - 1).giveToActors();
          counter += 1 + Integer.parseInt(noteArray[counter]);
          int temp2 = Integer.parseInt(noteArray[counter]);
          counter++;

          for (int i = 0; i < temp2; i++)
          {

            notes.get(notes.size() - 1).addLine(lines.get(Integer.parseInt(noteArray[counter])));
            counter++;

            for (int j = counter + 1; j < counter + 1 + Integer.parseInt (noteArray[counter]); j++)
            {

              notes.get(notes.size() - 1).addWord(notes.get(notes.size() - 1).getLine(notes.get(notes.size() - 1).getLines().size() - 1).getWord(Integer.parseInt(noteArray[j])));
            }

            counter += 1 + Integer.parseInt(noteArray[counter]);
          }

          notes.get(notes.size() - 1).setRehearsal(Integer.parseInt(noteArray[counter]));
          counter++;
          break;
        }
      }

      currentRehearsal = Integer.parseInt(noteArray[counter - 1]) + 1;
    }
  }

  void assignPositionsNew()
  {

    //Assign positions to each page, line, and word
    //Begin with temporary variable declarations for page and line
    float tempPagePos = startPos.y;
    float tempLinePos = 2 * textHeight + yMargin;

    //Loop through the lines
    for (Line line : lines)
    {

      //Check if this line is on a new page
      if (pages.size() <= line.getPage() - start)
      {

        //If so, adjust the page and line position temporary variables accordingly
        tempPagePos += tempLinePos + 2 * textHeight + yMargin;
        tempLinePos = 2 * textHeight + yMargin;
        //Add a new page with its proper position
        pages.add(new Page(line.getPage(), new PVector(xMargin, tempPagePos)));
      }

      //Add this line to the last page and give the line its position
      pages.get(pages.size() - 1).addLine(line);
      line.setPos(0, tempLinePos);
      //Declare a temporary variable for word position
      PVector tempWordPos = new PVector(textWidth(line.getActor().getCharName() + ". "), 0);

      //Loop through the words assigning positions
      for (Word word : line.getWords ())
      {

        //Check if the word is on the next line, if so adjust word and line positions accordingly
        if (pages.get(pages.size() - 1).getPos().x + line.getPos().x + tempWordPos.x + textWidth(word.getWord()) > width - xMargin)
        {

          tempWordPos.set(0, tempWordPos.y + 2 * textHeight);
          tempLinePos += 2 * textHeight;
        }

        //Iterate through
        word.setPos(tempWordPos.x, tempWordPos.y);
        tempWordPos.x += textWidth(word.getWord() + " ");
      }

      //Iterate through
      tempLinePos += 2 * textHeight;
    }
  }

  void assignPositionsOld()
  {

    float diffOld = selected.get(selected.size() - 1).getPos().y - selected.get(0).getPos().y;
    float diffNew = 0;
    PVector tempWordPos = new PVector(textWidth(selectedLines.get(0).getActor().getCharName() + ". "), 0);

    for (Word word : selectedLines.get (0).getWords())
    {

      if (pages.get(selectedLines.get(0).getPage() - start).getPos().x + selectedLines.get(0).getPos().x + tempWordPos.x + textWidth(word.getWord()) > width - xMargin)
      {

        tempWordPos.set(0, tempWordPos.y + 2 * textHeight);
        diffNew += 2 * textHeight;
      }

      word.setPos(tempWordPos.x, tempWordPos.y);
      tempWordPos.x += textWidth(word.getWord() + " ");
    }

    if (diffOld != diffNew)
    {

      for (int i = pages.get (selectedLines.get (0).getPage() - start).getLines().indexOf(selectedLines.get(0)) + 1; i < pages.get(selectedLines.get(0).getPage() - start).getLines().size(); i++)
      {

        pages.get(selectedLines.get(0).getPage() - start).getLine(i).setPos(pages.get(selectedLines.get(0).getPage() - start).getLine(i).getPos().x, pages.get(selectedLines.get(0).getPage() - start).getLine(i).getPos().y + diffNew - diffOld);
      }

      for (int i = selectedLines.get (0).getPage() - start + 1; i < pages.size(); i++)
      {

        pages.get(i).setPos(pages.get(i).getPos().x, pages.get(i).getPos().y + diffNew - diffOld);
      }
    }
  }

  //Check to see if s is an integer, returns s or -1
  int pageNumber(String s)
  {

    try
    {

      return Integer.parseInt(s.split(" ")[0]);
    }

    catch(Exception e)
    {

      return -1;
    }
  }

  void addButtons()
  {

    //State DISPLAYSCRIPT
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(DISPLAYSCRIPT).add(new Button(width - xMargin, yMargin, "QUIT", true, false));
    //Jump to Page button
    buttons.get(DISPLAYSCRIPT).add(new Button(width - 4 * xMargin - textWidth("QUIT"), yMargin, "JUMP TO PAGE: " + pages.get(pages.size() - 1).getNumber() * 10, true, false));
    //Save button
    buttons.get(DISPLAYSCRIPT).add(new Button(xMargin, yMargin, "SAVE", true, true));
    //Edit script button
    buttons.get(DISPLAYSCRIPT).add(new Button(4 * xMargin + textWidth("SAVE"), yMargin, "EDIT SCRIPT", true, true));
    //State MISSINGPAGE
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(MISSINGPAGE).add(buttons.get(DISPLAYSCRIPT).get(0));
    //State UNSAVEDQUIT
    buttons.add(new ArrayList<Button>());
    //Save button
    buttons.get(UNSAVEDQUIT).add(new Button(width / 2 - 2 * xMargin, height / 2 + textHeight + yMargin, "YES", true, false));
    //Don't save button
    buttons.get(UNSAVEDQUIT).add(new Button(width / 2 + 2 * xMargin, height / 2 + textHeight + yMargin, "NO", true, true));
    //Cancel button
    buttons.get(UNSAVEDQUIT).add(new Button((width - textWidth("CANCEL")) / 2, height / 2 + 2 * textHeight + 4 * yMargin, "CANCEL", true, true));
    //State JUMPTOPAGE
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(JUMPTOPAGE).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    buttons.get(JUMPTOPAGE).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    buttons.get(JUMPTOPAGE).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Edit script button
    buttons.get(JUMPTOPAGE).add(buttons.get(DISPLAYSCRIPT).get(3));
    //State HIGHLIGHTING
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(HIGHLIGHTING).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    buttons.get(HIGHLIGHTING).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    buttons.get(HIGHLIGHTING).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Edit script button
    buttons.get(HIGHLIGHTING).add(buttons.get(DISPLAYSCRIPT).get(3));
    //State ASSIGNINGNOTE
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Edit script button
    buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(3));
    //State EDITINGSCRIPT
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(EDITINGSCRIPT).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    buttons.get(EDITINGSCRIPT).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    buttons.get(EDITINGSCRIPT).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Back button
    buttons.get(EDITINGSCRIPT).add(new Button(4 * xMargin + textWidth("SAVE"), yMargin, "BACK", true, true));
    //Edit words button
    buttons.get(EDITINGSCRIPT).add(new Button(7 * xMargin + textWidth("SAVEBACK"), yMargin, "EDIT WORD(S)", true, true));
    //Separate line button
    //buttons.get(EDITINGSCRIPT).add(new Button(10 * xMargin + textWidth("SAVEBACKEDIT WORD(S)"), yMargin, "SEPARATE LINE", true, true));
    //Add line button
    //buttons.get(EDITINGSCRIPT).add(new Button(xMargin, 4 * yMargin + textHeight, "ADD LINE", true, true));
    //Remove line button
    //buttons.get(EDITINGSCRIPT).add(new Button(4 * xMargin + textWidth("ADD LINE"), 4 * yMargin + textHeight, "REMOVE LINE", true, true));
    //State HIGHLIGHTINGEDIT
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(HIGHLIGHTINGEDIT).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    buttons.get(HIGHLIGHTINGEDIT).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    buttons.get(HIGHLIGHTINGEDIT).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Back button
    buttons.get(HIGHLIGHTINGEDIT).add(buttons.get(EDITINGSCRIPT).get(3));
    //Edit words button
    buttons.get(HIGHLIGHTINGEDIT).add(buttons.get(EDITINGSCRIPT).get(4));
    //Separate line button
    //buttons.get(HIGHLIGHTINGEDIT).add(buttons.get(EDITINGSCRIPT).get(5));
    //Add line button
    //buttons.get(HIGHLIGHTINGEDIT).add(buttons.get(EDITINGSCRIPT).get(6));
    //Remove line button
    //buttons.get(HIGHLIGHTINGEDIT).add(buttons.get(EDITINGSCRIPT).get(7));
    //State ASSIGNINGEDIT
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(ASSIGNINGEDIT).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    buttons.get(ASSIGNINGEDIT).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    buttons.get(ASSIGNINGEDIT).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Back button
    buttons.get(ASSIGNINGEDIT).add(buttons.get(EDITINGSCRIPT).get(3));
    //Edit words button
    buttons.get(ASSIGNINGEDIT).add(buttons.get(EDITINGSCRIPT).get(4));
    //Separate line button
    //buttons.get(ASSIGNINGEDIT).add(buttons.get(EDITINGSCRIPT).get(5));
    //Add line button
    //buttons.get(ASSIGNINGEDIT).add(buttons.get(EDITINGSCRIPT).get(6));
    //Remove line button
    //buttons.get(ASSIGNINGEDIT).add(buttons.get(EDITINGSCRIPT).get(7));
    //State ASSIGNINGPPHRASE
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(ASSIGNINGPPHRASE).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    buttons.get(ASSIGNINGPPHRASE).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    buttons.get(ASSIGNINGPPHRASE).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Edit script button
    buttons.get(ASSIGNINGPPHRASE).add(buttons.get(DISPLAYSCRIPT).get(3));
    //State JUMPTOPAGEEDIT
    buttons.add(new ArrayList<Button>());
    //Quit button
    buttons.get(JUMPTOPAGEEDIT).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    buttons.get(JUMPTOPAGEEDIT).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    buttons.get(JUMPTOPAGEEDIT).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Back button
    buttons.get(JUMPTOPAGEEDIT).add(buttons.get(EDITINGSCRIPT).get(3));
    //Edit words button
    buttons.get(JUMPTOPAGEEDIT).add(buttons.get(EDITINGSCRIPT).get(4));
    //Separate line button
    //buttons.get(JUMPTOPAGEEDIT).add(buttons.get(EDITINGSCRIPT).get(5));
    //Add line button
    //buttons.get(JUMPTOPAGEEDIT).add(buttons.get(EDITINGSCRIPT).get(6));
    //Remove line button
    //buttons.get(JUMPTOPAGEEDIT).add(buttons.get(EDITINGSCRIPT).get(7));
    //State SEPARATELINE
    //buttons.add(new ArrayList<Button>());
    //Quit button
    //buttons.get(SEPARATELINE).add(buttons.get(DISPLAYSCRIPT).get(0));
    //Jump to Page button
    //buttons.get(SEPARATELINE).add(buttons.get(DISPLAYSCRIPT).get(1));
    //Save button
    //buttons.get(SEPARATELINE).add(buttons.get(DISPLAYSCRIPT).get(2));
    //Back button
    //buttons.get(SEPARATELINE).add(buttons.get(EDITINGSCRIPT).get(3));
    //Edit words button
    //buttons.get(SEPARATELINE).add(buttons.get(EDITINGSCRIPT).get(4));
    //Separate line button
    //buttons.get(SEPARATELINE).add(buttons.get(EDITINGSCRIPT).get(5));
    //Add line button
    //buttons.get(SEPARATELINE).add(buttons.get(EDITINGSCRIPT).get(6));
    //Remove line button
    //buttons.get(SEPARATELINE).add(buttons.get(EDITINGSCRIPT).get(7));
  }

  void buttonClick(int s, int i)
  {

    //
    switch(s)
    {

    case DISPLAYSCRIPT:
    case HIGHLIGHTING:
    case ASSIGNINGNOTE:
    case ASSIGNINGPPHRASE:

      switch(i)
      {

      case 0:

        if (saved)
        {
          exit();
        }
        else
        {
          state = UNSAVEDQUIT;
        }

        break;

      case 1:

        state = JUMPTOPAGE;
        buttons.get(s).get(i).setTyping(true);
        typing = "";
        buttons.get(s).get(i).setText("JUMP TO PAGE: " + typing);
        break;

      case 2:

        if (!saved)
          saveData();

        break;

      case 3:

        state = EDITINGSCRIPT;
        break;
      }

      break;

    case HIGHLIGHTINGEDIT:
    case ASSIGNINGEDIT:

      switch(i)
      {

      case 0:

        if (saved)
        {

          exit();
        } else
        {

          state = UNSAVEDQUIT;
        }

        break;

      case 1:

        //DEAL WITH THIS LATER
        state = JUMPTOPAGEEDIT;
        buttons.get(s).get(i).setTyping(true);
        typing = "";
        buttons.get(s).get(i).setText("JUMP TO PAGE: " + typing);
        break;

      case 2:

        if (!saved)
          saveData();

        break;
      }

      break;
    }


    //Check current state, then inside another switch to check which button has been clicked
    switch(s)
    {

    case MISSINGPAGE:

      switch(i)
      {

      case 0:

        if (saved)
        {

          exit();
        } else
        {

          state = UNSAVEDQUIT;
        }

        break;
      }

      break;

    case UNSAVEDQUIT:

      switch(i)
      {

      case 0:

        saveData();
        exit();
        break;

      case 1:

        exit();
        break;

      case 2:

        state = prevState;
        break;
      }

      break;

    case JUMPTOPAGE:

      switch(i)
      {

      case 0:

        if (saved)
        {

          exit();
        } else
        {

          state = UNSAVEDQUIT;
        }

        break;

      case 2:

        if (!saved)
          saveData();

        break;

      case 3:

        state = EDITINGSCRIPT;
        break;
      }

      break;

    case JUMPTOPAGEEDIT:

      switch(i)
      {

      case 0:

        if (saved)
        {

          exit();
        } else
        {

          state = UNSAVEDQUIT;
        }

        break;

      case 2:

        if (!saved)
          saveData();

        break;

      case 3:

        state = DISPLAYSCRIPT;
        break;

      case 4:

        editButton = true;
        break;
      }

      break;

    case ASSIGNINGNOTE:

      switch(i)
      {

      case 4:

        notes.add(new SkipNote(selectedLines, selected));
        saved = false;
        buttons.get(ASSIGNINGNOTE).clear();
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(0));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(1));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(2));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(3));
        state = DISPLAYSCRIPT;
        break;

      case 5:

        notes.add(new ParaphraseNote(selectedLines, selected));
        buttons.get(ASSIGNINGNOTE).clear();
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(0));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(1));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(2));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(3));
        typing = "";
        state = ASSIGNINGPPHRASE;
        break;

      case 6:

        notes.add(new CallForLineNote(selectedLines, selected));
        saved = false;
        buttons.get(ASSIGNINGNOTE).clear();
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(0));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(1));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(2));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(3));
        state = DISPLAYSCRIPT;
        break;

      case 7:

        notes.add(new MissedCueNote(selectedLines, selected));
        saved = false;
        buttons.get(ASSIGNINGNOTE).clear();
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(0));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(1));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(2));
        buttons.get(ASSIGNINGNOTE).add(buttons.get(DISPLAYSCRIPT).get(3));
        state = DISPLAYSCRIPT;
        break;
      }

      break;

    case EDITINGSCRIPT:

      switch(i)
      {

      case 0:

        if (saved)
        {

          exit();
        } else
        {

          state = UNSAVEDQUIT;
        }

        break;

      case 1:

        state = JUMPTOPAGEEDIT;
        buttons.get(s).get(i).setTyping(true);
        typing = "";
        buttons.get(s).get(i).setText("JUMP TO PAGE: " + typing);
        break;

      case 2:

        if (!saved)
          saveData();

        break;

      case 3:

        state = DISPLAYSCRIPT;
        break;

      case 4:

        editButton = true;
        break;

      case 5:

        state = SEPARATELINE;
        break;
      }

      break;
    }

    prevState = s;
  }

  void prepareMenu(float x, float y)
  {

    PVector tlp = new PVector();
    PVector brp = new PVector();

    //This should use textWidth() of the longest button option
    if (x + textWidth(Menu.LONGEST) + 2 * xMargin > width)
    {

      if (y + Menu.COUNT * textHeight > height)
      {

        tlp.set(x - 2 * xMargin - textWidth(Menu.LONGEST), y - Menu.COUNT * textHeight);
      } else
      {

        tlp.set(x - 2 * xMargin - textWidth(Menu.LONGEST), y);
      }
    } else
    {

      if (y + Menu.COUNT * textHeight > height)
      {

        tlp.set(x, y - Menu.COUNT * textHeight);
      } else
      {

        tlp.set(x, y);
      }
    }

    menu = new Menu(tlp, textWidth(Menu.LONGEST));

    for (Button button : menu.getButtons ())
    {

      buttons.get(ASSIGNINGNOTE).add(button);
    }
  }

  void saveData()
  {

    String[] saveActors = new String[2 * actors.size()];
    int i = 0;

    for (Actor actor : actors)
    {

      saveActors[i] = actor.getCharName();
      saveActors[i + 1] = actor.getActorName();
      i += 2;
    }

    saveStrings(prefix + "/actors.txt", saveActors);
    int numWords = 0;
    int numLines = 0;

    for (Line line : lines)
    {

      numLines++;

      for (Word word : line.getWords ())
      {

        numWords++;
      }
    }

    String[] saveWords = new String[4 * numLines + 2 * numWords];
    i = 0;

    for (Line line : lines)
    {

      saveWords[i] = String.valueOf(actors.indexOf(line.getActor()));
      saveWords[i + 1] = String.valueOf(line.getPage());
      saveWords[i + 2] = line.getPos().toString();
      saveWords[i + 3] = String.valueOf(line.getWords().size());
      i += 4;

      for (Word word : line.getWords ())
      {

        saveWords[i] = word.getWord();
        saveWords[i + 1] = word.getPos().toString();
        i += 2;
      }
    }

    saveStrings(prefix + "/lines.txt", saveWords);
    String[] savePages = new String[2 * pages.size()];
    i = 0;

    for (Page page : pages)
    {

      savePages[i] = String.valueOf(page.getNumber());
      savePages[i + 1] = page.getPos().toString();
      i += 2;
    }

    saveStrings(prefix + "/pages.txt", savePages);

    int noteCount = 0;

    for (Note note : notes)
    {

      switch(note.getType())
      {

      case 0:
      case 2:
      case 3:

        noteCount += 4 + note.getActors().size() + 2 * note.getLines().size() + note.getWords().size();
        break;

      case 1:

        noteCount += 5 + note.getActors().size() + 2 * note.getLines().size() + note.getWords().size();
        break;
      }
    }

    String[] saveNotes = new String[noteCount];
    i = 0;

    for (Note note : notes)
    {

      switch(note.getType())
      {

      case 0:
      case 2:
      case 3:

        saveNotes[i] = String.valueOf(note.getType());
        saveNotes[i + 1] = String.valueOf(note.getActors().size());
        i += 2;

        for (Actor actor : note.getActors ())
        {

          saveNotes[i] = String.valueOf(actors.indexOf(actor));
          i++;
        }

        saveNotes[i] = String.valueOf(note.getLines().size());
        i++;

        for (Line line : note.getLines ())
        {

          saveNotes[i] = String.valueOf(lines.indexOf(line));
          i++;
          int wordCount = 0;

          for (Word word : note.getWords ())
          {

            if (line.getWords().indexOf(word) != -1)
              wordCount++;
          }

          saveNotes[i] = String.valueOf(wordCount);
          i++;

          for (Word word : note.getWords ())
          {

            if (line.getWords().indexOf(word) != -1)
            {

              saveNotes[i] = String.valueOf(line.getWords().indexOf(word));
              i++;
            }
          }
        }

        saveNotes[i] = String.valueOf(note.getRehearsal());
        i++;
        break;

      case 1:

        saveNotes[i] = String.valueOf(note.getType());
        saveNotes[i + 1] = String.valueOf(note.getActors().size());
        i += 2;

        for (Actor actor : note.getActors ())
        {

          saveNotes[i] = String.valueOf(actors.indexOf(actor));
          i++;
        }

        saveNotes[i] = String.valueOf(note.getLines().size());
        i++;

        for (Line line : note.getLines ())
        {

          saveNotes[i] = String.valueOf(lines.indexOf(line));
          i++;
          int wordCount = 0;

          for (Word word : note.getWords ())
          {

            if (line.getWords().indexOf(word) != -1)
              wordCount++;
          }

          saveNotes[i] = String.valueOf(wordCount);
          i++;

          for (Word word : note.getWords ())
          {

            if (line.getWords().indexOf(word) != -1)
            {

              saveNotes[i] = String.valueOf(line.getWords().indexOf(word));
              i++;
            }
          }
        }

        saveNotes[i] = note.getSaid();
        saveNotes[i + 1] = String.valueOf(note.getRehearsal());
        i += 2;
        break;
      }
    }

    saveStrings(prefix + "/savedNotes.txt", saveNotes);
    noteCount = currentRehearsal * (3 * actors.size() + 3);

    for (Note note : notes)
    {

      switch(note.getType())
      {

      case 0:
      case 2:
      case 3:

        noteCount += note.getActors().size() * (note.getLines().size() + 1);
        break;

      case 1:

        noteCount += note.getActors().size() * (note.getLines().size() + 2);
        break;
      }
    }

    String[] showNotes = new String[noteCount];
    i = 0;

    for (int j = currentRehearsal; j >= 1; j--)
    {

      showNotes[i] = "REHEARSAL " + j;
      showNotes[i + 1] = "";
      showNotes[i + 2] = "";
      i += 3;

      for (Actor actor : actors)
      {

        showNotes[i] = actor.toString();
        showNotes[i + 1] = "";
        i += 2;

        for (Note note : actor.getNotes ())
        {

          if (note.getRehearsal() == j)
          {

            switch(note.getType())
            {

            case 0:

              showNotes[i] = "Page " + note.getLine(0).getPage() + ", SKIPPED:";
              i++;

              if (note.getLines().size() == 1)
              {

                showNotes[i] = actor.toString() + ". ";

                for (int k = 1; k < 6 && k < note.getLine (0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "... ";

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(0)) - 3; k < note.getLine(0).getWords().indexOf(note.getWord(0)); k++)
                {

                  if (k >= 0)
                    showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                for (Word word : note.getWords ())
                {

                  showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 1; k < note.getLine(0).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 4 && k < note.getLine(0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "...";
                i++;
              } else
              {

                showNotes[i] = actor.toString() + ". ";

                for (int k = 1; k < 6 && k < note.getLine (0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "... ";

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(0)) - 3; k < note.getLine(0).getWords().indexOf(note.getWord(0)); k++)
                {

                  if (k >= 0)
                    showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                for (Word word : note.getLine (0).getWords())
                {

                  if (note.getWords().indexOf(word) != -1)
                    showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                i++;

                for (int k = 1; k < note.getLines ().size() - 1; k++)
                {

                  showNotes[i] = note.getLine(k).getActor().toString() + ".";

                  for (Word word : note.getLine (k).getWords())
                  {

                    showNotes[i] += word.getWord().toUpperCase() + " ";
                  }

                  i++;
                }

                showNotes[i] = note.getLine(note.getLines().size() - 1).getActor().toString() + ".";

                for (Word word : note.getWords ())
                {

                  if (note.getLine(note.getLines().size() - 1).getWords().indexOf(word) != -1)
                    showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                for (int k = note.getLine (note.getLines ().size() - 1).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 1; k < note.getLine(note.getLines().size() - 1).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 4 && k < note.getLine(note.getLines().size() - 1).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(note.getLines().size() - 1).getWord(k).getWord() + " ";
                }

                showNotes[i] += "...";
                i++;
              }

              break;

            case 1:

              showNotes[i] = "Page " + note.getLine(0).getPage();
              i++;

              if (note.getLines().size() == 1)
              {

                showNotes[i] = actor.toString() + ". ";

                for (int k = 1; k < 6 && k < note.getLine (0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "... ";

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(0)) - 3; k < note.getLine(0).getWords().indexOf(note.getWord(0)); k++)
                {

                  if (k >= 0)
                    showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                for (Word word : note.getWords ())
                {

                  showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 1; k < note.getLine(0).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 4 && k < note.getLine(0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "...";
                showNotes[i + 1] = "ACTOR SAID: " + note.getSaid();
                i += 2;
              } else
              {

                showNotes[i] = actor.toString() + ". ";

                for (int k = 1; k < 6 && k < note.getLine (0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "... ";

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(0)) - 3; k < note.getLine(0).getWords().indexOf(note.getWord(0)); k++)
                {

                  if (k >= 0)
                    showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                for (Word word : note.getLine (0).getWords())
                {

                  if (note.getWords().indexOf(word) != -1)
                    showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                i++;

                for (int k = 1; k < note.getLines ().size() - 1; k++)
                {

                  showNotes[i] = note.getLine(k).getActor().toString() + ".";

                  for (Word word : note.getLine (k).getWords())
                  {

                    showNotes[i] += word.getWord().toUpperCase() + " ";
                  }

                  i++;
                }

                showNotes[i] = note.getLine(note.getLines().size() - 1).getActor().toString() + ".";

                for (Word word : note.getWords ())
                {

                  if (note.getLine(note.getLines().size() - 1).getWords().indexOf(word) != -1)
                    showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                for (int k = note.getLine (note.getLines ().size() - 1).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 1; k < note.getLine(note.getLines().size() - 1).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 4 && k < note.getLine(note.getLines().size() - 1).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(note.getLines().size() - 1).getWord(k).getWord() + " ";
                }

                showNotes[i] += "...";
                showNotes[i + 1] = "ACTOR SAID: " + note.getSaid();
                i += 2;
              }

              break;

            case 2:

              showNotes[i] = "Page " + note.getLine(0).getPage() + ", CALLED FOR LINE:";
              i++;

              if (note.getLines().size() == 1)
              {

                showNotes[i] = actor.toString() + ". ";

                for (int k = 1; k < 6 && k < note.getLine (0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "... ";

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(0)) - 3; k < note.getLine(0).getWords().indexOf(note.getWord(0)); k++)
                {

                  if (k >= 0)
                    showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                for (Word word : note.getWords ())
                {

                  showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 1; k < note.getLine(0).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 4 && k < note.getLine(0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "...";
                i++;
              } else
              {

                showNotes[i] = actor.toString() + ". ";

                for (int k = 1; k < 6 && k < note.getLine (0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "... ";

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(0)) - 3; k < note.getLine(0).getWords().indexOf(note.getWord(0)); k++)
                {

                  if (k >= 0)
                    showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                for (Word word : note.getLine (0).getWords())
                {

                  if (note.getWords().indexOf(word) != -1)
                    showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                i++;

                for (int k = 1; k < note.getLines ().size() - 1; k++)
                {

                  showNotes[i] = note.getLine(k).getActor().toString() + ".";

                  for (Word word : note.getLine (k).getWords())
                  {

                    showNotes[i] += word.getWord().toUpperCase() + " ";
                  }

                  i++;
                }

                showNotes[i] = note.getLine(note.getLines().size() - 1).getActor().toString() + ".";

                for (Word word : note.getWords ())
                {

                  if (note.getLine(note.getLines().size() - 1).getWords().indexOf(word) != -1)
                    showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                for (int k = note.getLine (note.getLines ().size() - 1).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 1; k < note.getLine(note.getLines().size() - 1).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 4 && k < note.getLine(note.getLines().size() - 1).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(note.getLines().size() - 1).getWord(k).getWord() + " ";
                }

                showNotes[i] += "...";
                i++;
              }

              break;

            case 3:

              showNotes[i] = "Page " + note.getLine(0).getPage() + ", MISSED CUE:";
              i++;

              if (note.getLines().size() == 1)
              {

                showNotes[i] = actor.toString() + ". ";

                for (int k = 1; k < 6 && k < note.getLine (0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "... ";

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(0)) - 3; k < note.getLine(0).getWords().indexOf(note.getWord(0)); k++)
                {

                  if (k >= 0)
                    showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                for (Word word : note.getWords ())
                {

                  showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 1; k < note.getLine(0).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 4 && k < note.getLine(0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "...";
                i++;
              } else
              {

                showNotes[i] = actor.toString() + ". ";

                for (int k = 1; k < 6 && k < note.getLine (0).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                showNotes[i] += "... ";

                for (int k = note.getLine (0).getWords().indexOf(note.getWord(0)) - 3; k < note.getLine(0).getWords().indexOf(note.getWord(0)); k++)
                {

                  if (k >= 0)
                    showNotes[i] += note.getLine(0).getWord(k).getWord() + " ";
                }

                for (Word word : note.getLine (0).getWords())
                {

                  if (note.getWords().indexOf(word) != -1)
                    showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                i++;

                for (int k = 1; k < note.getLines ().size() - 1; k++)
                {

                  showNotes[i] = note.getLine(k).getActor().toString() + ".";

                  for (Word word : note.getLine (k).getWords())
                  {

                    showNotes[i] += word.getWord().toUpperCase() + " ";
                  }

                  i++;
                }

                showNotes[i] = note.getLine(note.getLines().size() - 1).getActor().toString() + ".";

                for (Word word : note.getWords ())
                {

                  if (note.getLine(note.getLines().size() - 1).getWords().indexOf(word) != -1)
                    showNotes[i] += word.getWord().toUpperCase() + " ";
                }

                for (int k = note.getLine (note.getLines ().size() - 1).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 1; k < note.getLine(note.getLines().size() - 1).getWords().indexOf(note.getWord(note.getWords().size() - 1)) + 4 && k < note.getLine(note.getLines().size() - 1).getWords().size(); k++)
                {

                  showNotes[i] += note.getLine(note.getLines().size() - 1).getWord(k).getWord() + " ";
                }

                showNotes[i] += "...";
                i++;
              }

              break;
            }
          }
        }

        showNotes[i] = "";
        i++;
      }
    }

    saveStrings(prefix + "/NOTES.txt", showNotes);
    println("YAY YOU SAVED!");
    saved = true;
  }

  PVector vectorFromString(String s)
  {
    return(new PVector(Float.parseFloat(s.substring(2, s.indexOf(","))), Float.parseFloat(s.substring(s.indexOf(",") + 2, s.indexOf(",", s.indexOf(",") + 1)))));
  }
  
  void exit()
  {
    set_script_null();
  }
}

