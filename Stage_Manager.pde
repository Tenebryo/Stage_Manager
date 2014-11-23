import java.io.*;
import java.util.*;
import java.nio.channels.*;


//Font
static int textHeight;
static PFont font;

//Margins
int xMargin;
int yMargin;

//Rehearsal number
static int currentRehearsal;

Script script;

void set_script_null()
{
  println("Exiting...");
  script = null;
  check_files();
}

ArrayList<String> Scripts = new ArrayList<String>();

int scroll_pos = 0;
PVector menu_pos_min;
PVector menu_pos_max;
PVector new_script_btn_min;
PVector new_script_btn_max;
String script_file_prefix = "";

void setup()
{
  //Set the screen size to full screen
  size(displayWidth, displayHeight);

  menu_pos_min = new PVector(100, 100);
  menu_pos_max = new PVector(width-50, height-50);
  new_script_btn_min = new PVector(10, 100);
  new_script_btn_max = new PVector(90, height-10);
  //Font
  textHeight = 20;
  font = createFont("Arial", textHeight, true);
  textFont(font);
  //Margins
  xMargin = 20;
  yMargin = 20;
  check_files();
}

void check_files()
{
  Scripts.clear();
  File dir = new File(dataPath("scripts/"));
  File[] files = dir.listFiles();
  if (files != null)
  {
    for (File f : files)
    {
      if (f.isDirectory())
      {
        Scripts.add(f.getName());
      }
    }
  } else
  {
    dir.mkdirs();
  }
}

void draw()
{
  if (script == null)
  {
    select_script();
  } else
  {
    script.draw();
  }
}


void select_script()
{
  background(0, 0, 50);
  if (Scripts.size() > 0)
  {
    int i = scroll_pos;
    noStroke();
    for (String f : Scripts)
    {
      if (menu_pos_min.x < mouseX && mouseX < menu_pos_max.x &&
        mouseY > menu_pos_min.y - i*32 && mouseY < menu_pos_min.y - i*32 + 30 &&
        mouseY > menu_pos_min.y && mouseY < menu_pos_max.y)
      {
        fill(200, 150);
      } else
      {
        fill(150, 100);
      }
      rect(menu_pos_min.x, menu_pos_min.y-32*i, menu_pos_max.x-menu_pos_min.x, 31);
      text(f, menu_pos_min.x + 10, menu_pos_min.y-32*i + 24);
      i += 32;
    }
    //rect(menu_pos_min.x, menu_pos_min.y+32*i, menu_pos_max.x-menu_pos_min.x, 30);
    fill(0, 0, 50);
    rect(menu_pos_min.x, 0, menu_pos_max.x-menu_pos_min.x, menu_pos_min.y);
    rect(menu_pos_min.x, menu_pos_max.y, menu_pos_max.x-menu_pos_min.x, height-menu_pos_max.y);

    if (new_script_btn_min.x < mouseX && mouseX < new_script_btn_max.x && 
      new_script_btn_min.y < mouseY && mouseY < new_script_btn_max.y)
    {
      fill(200, 150);
    } else
    {
      fill(150, 100);
    }
    rect(new_script_btn_min.x, new_script_btn_min.y, new_script_btn_max.x - new_script_btn_min.x, new_script_btn_max.y - new_script_btn_min.y);
    text("A\nd\nd\n \na\n \nN\ne\nw\n \nS\nc\nr\ni\np\nt", new_script_btn_min.x + 20, new_script_btn_min.y + 32);
  } else
  {
    if (menu_pos_min.x < mouseX && mouseX < menu_pos_max.x && menu_pos_min.y < mouseY && mouseY < menu_pos_max.y)
    {
      fill(200, 150);
    } else
    {
      fill(150, 100);
    }
    rect(menu_pos_min.x, menu_pos_min.y, menu_pos_max.x-menu_pos_min.x, menu_pos_max.y-menu_pos_min.y);
    text("No Scripts found...\nClick to load a new script.", menu_pos_min.x+20, menu_pos_min.y+20, menu_pos_max.x-menu_pos_min.x, menu_pos_max.y-menu_pos_min.y);
  }
}

void file_selected(File f)
{
  if (f == null)
  {
    return;
  } else
  {
    println(f.getName());
    String filename = f.getName().replaceFirst("[.][^.]+$", "");
    File dir = new File(dataPath("scripts/"+filename+"/script.txt"));
    new File(dataPath("scripts/"+filename+"/")).mkdirs();
    try 
    {
      copyDirectory(f, dir);
      println("Copied script");
      mkFile(dataPath("scripts/"+filename+"/actors.txt"));
      mkFile(dataPath("scripts/"+filename+"/lines.txt"));
      mkFile(dataPath("scripts/"+filename+"/NOTES.txt"));
      mkFile(dataPath("scripts/"+filename+"/pages.txt"));
    } 
    catch (IOException e) 
    {
      println(e);
    }
    check_files();
  }
}

File mkFile(String path) throws IOException
{
  File dir = new File(path.replaceFirst("[/\\\\][^/\\\\]+$", ""));
  dir.mkdirs();
  File t = new File(path);
  t.createNewFile();
  return t;
}

void mousePressed()
{
  if (script != null)
  {
    script.mousePressed();
  } else
  {
    if (Scripts.size() > 0)
    {
      int i = scroll_pos;
      noStroke();
      for (String f : Scripts)
      {
        if (menu_pos_min.x < mouseX && mouseX < menu_pos_max.x &&
          mouseY > menu_pos_min.y - i*32 && mouseY < menu_pos_min.y - i*32 + 30 &&
          mouseY > menu_pos_min.y && mouseY < menu_pos_max.y)
        {
          script = new Script(dataPath("scripts/"+f));
        }
        i += 32;
      }
      if (new_script_btn_min.x < mouseX && mouseX < new_script_btn_max.x && 
          new_script_btn_min.y < mouseY && mouseY < new_script_btn_max.y)
      {
        selectInput("Select a script", "file_selected");
      }
    } else
    {
      if (menu_pos_min.x < mouseX && mouseX < menu_pos_max.x && menu_pos_min.y < mouseY && mouseY < menu_pos_max.y)
      {
        selectInput("Select a script", "file_selected");
      }
    }
  }
}

void mouseDragged()
{
  if (script != null)
  {
    script.mouseDragged();
  }
}

void mouseReleased()
{
  if (script != null)
  {
    script.mouseReleased();
  }
}

void keyPressed()
{
  if (script != null)
  {
    script.keyPressed();
  }
}

//Set the application to be full screen
boolean sketchFullScreen()
{
  return true;
}

void copyDirectory(File sourceLocation, File targetLocation)
throws IOException {

  if (sourceLocation.isDirectory()) {
    if (!targetLocation.exists()) {
      targetLocation.mkdir();
    }

    String[] children = sourceLocation.list();
    for (int i=0; i<children.length; i++) {
      copyDirectory(new File(sourceLocation, children[i]), 
      new File(targetLocation, children[i]));
    }
  } else {

    InputStream in = new FileInputStream(sourceLocation);
    OutputStream out = new FileOutputStream(targetLocation);

    // Copy the bits from instream to outstream
    byte[] buf = new byte[1024];
    int len;
    while ( (len = in.read (buf)) > 0) {
      out.write(buf, 0, len);
    }
    in.close();
    out.close();
  }
}

