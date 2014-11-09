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

ArrayList<String> Scripts = new ArrayList<String>();

int scroll_pos = 0;
PVector menu_pos_min;
PVector menu_pos_max;
String script_file_prefix = "";

void setup()
{
  //Set the screen size to full screen
  size(displayWidth, displayHeight);

  menu_pos_min = new PVector(100, 100);
  menu_pos_max = new PVector(width-50, height-50);
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
  File dir = new File(sketchPath+"/data/scripts/");
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
      if (menu_pos_min.x < mouseX && mouseX < menu_pos_max.x)
      {
        fill(200, 150);
      } else
      {
        fill(150, 100);
      }
      rect(menu_pos_min.x, menu_pos_min.y+32*i, menu_pos_max.x-menu_pos_min.x, 30);
      text(f, menu_pos_min.x+30, menu_pos_min.y+32*i);
    }
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
    File dir = new File(sketchPath+"/data/scripts/"+filename+"/script.txt");
    new File(sketchPath+"/data/scripts/"+filename+"/").mkdirs();
    try 
    {
      copyDirectory(f, dir);
      println("Copied script");
    } 
    catch (IOException e) 
    {
      println(e);
    }
    check_files();
  }
}

void mousePressed()
{
  if (script != null)
  {
    script.mousePressed();
  } else
  {
    if (menu_pos_min.x < mouseX && mouseX < menu_pos_max.x && menu_pos_min.y < mouseY && mouseY < menu_pos_max.y)
    {
      selectInput("Select a script", "file_selected");
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

