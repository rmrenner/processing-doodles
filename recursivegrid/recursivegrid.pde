/*color white = color(255,255,255);
color deep_blue = color(16,16,122);
color blue = color(50,50,200);
color lt_blue = color(50,50,255);
color light_yellow = color(236,231,173);
color grey = color(30,30,30);*/
ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<Line> cells = new ArrayList<Line>();
PFont motter_air_bold;

/*
  Right now my favorite values for the cell settings are:
    min_cell_size = 45;
    cell_margin = 20;
    line_size = 10;
*/

float min_cell_size = random(45,200);
float cell_margin = random(20, (min_cell_size-2)/2);
float line_size = random(5,30);
float h;    //the dominant hue for the scene.
float s;
float b;
color bg_color;    //empty cells
color line_color; //borders between cells
color cell_color; //filled-in cells
color banner_color; //text color on the banner
color banner_bg;  //color of the enclosing square
boolean show_lines = random(1.0)>= .5;
boolean show_cells = !show_lines || random(1.0)>= .5;
boolean div_both_x = random(1.0)>= .5;
boolean div_both_y = random(1.0)>= .5;
boolean saved;

class Line
{
  PVector start, end;
  color myColor;

  Line(PVector start, PVector end, color stroke)
  {
    this.start = start;
    this.end = end;
    this.myColor = stroke;
  }

  Line(PVector start, PVector end)
  {
    this.start = start;
    this.end = end;
    this.myColor = color(255,255,255);
  }
}

void setup()
{
  size(2000,2000);
  motter_air_bold = createFont("MotterAir-Bold",100,true);
  setup_colors();
  setup_lines(0,width,0,height);

}

void setup_colors()
{
  h = random(360);
  s = random(10,100);
  b = random(10,100);
  colorMode(HSB, 360,100,100);
  bg_color = banner_bg = randomB();
  line_color = banner_color = color(0,0,0);
  //cell_color = color(h,random(100),random(100));

}

color anyColor()
{
  return color(random(360),random(10,100),random(10,100));
}

color baseColor()
{  return color(h,s,b);
}

color fixedH()
{
  return color(h, random(10,100), random(10,100));
}

color fixedS()
{
  return color(random(360), s, random(10,100));
}

color fixedB()
{
  return color(random(360),random(10,100),b);
}

color randomH()
{
  return color(random(360),s,b);
}
color randomS()
{
  return color(h,random(10,100),b);
}
color randomB()
{
  return color(h,s,random(10,100));
}

void draw()
{
  background(bg_color);
  if(show_cells)
  {  draw_cells(); }
  if(show_lines)
  {draw_lines();}
  //draw_banner();
  if(!saved)
  {
    saved = true;
    saveFrame(""+year()+month()+day()+hour()+minute()+second()+".png");
  }
}

void draw_banner()
{
  noStroke();
  rectMode(CORNER);

  fill(banner_bg);
  rect(0,60,1064,129);
  fill(banner_color);
  textFont(motter_air_bold);
  rect(0,60,1920,15);
  text("hypercorrect",160,148);
  rect(0,174,1920,15);
  rect(1064,60,15,129);
  rect(859,75,16,11);

}

void draw_lines()
{
  //strokeCap(SQUARE);
  strokeWeight(line_size);
  for (Line l: lines)
  {
    stroke(l.myColor);
    line(l.start.x, l.start.y, l.end.x, l.end.y);
  }

}

void draw_cells()
{
  rectMode(CORNERS);
  noStroke();
  fill(cell_color);
  for (Line c: cells)
  { fill(c.myColor);
    rect(c.start.x, c.start.y, c.end.x, c.end.y);
  }
}

/* Randomly subdivides the specified space.
  Refuses to subdivide spaces <= 100px */
void setup_lines(float x0, float x1, float y0, float y1)
{
  float dx = abs(x1-x0); //calculate horiz size of area
  float dy = abs(y1-y0); //calculate vert size of area

  //if either dimension is less than min cell size, stop recursing
  if(dx <= min_cell_size || dy <= min_cell_size)
  {
    cells.add(new Line(new PVector(x0,y0),new PVector(x1,y1),fixedS()));
    return;
  }

  float pivot;
  Line l;
  if(dx >= dy)
  {
    //Width > Height or Square. Make vertical line.
      pivot = random(x0+cell_margin, x1-cell_margin);
      l = new Line(new PVector(pivot, y0), new PVector(pivot, y1),fixedS());
      lines.add(l);

      //This line creates two new regions to consider:
      if(div_both_x)
      {
          setup_lines(x0, pivot, y0, y1);
          setup_lines(pivot, x1, y0, y1);
      
      }
      else
      {
        //Variant: only subdivide the larger region.
        if(pivot-x0>=x1-pivot)
        {
          setup_lines(x0, pivot, y0, y1);
        }
        else
        {
          setup_lines(pivot, x1, y0, y1);
        }
      }
  }
  else
  {
    //Height > Width. Make horizontal line.
    pivot = random(y0+cell_margin, y1-cell_margin);
    l = new Line(new PVector(x0, pivot), new PVector(x1, pivot),fixedS());
    lines.add(l);
    if(div_both_y)
    {
      setup_lines(x0, x1, y0, pivot);
      setup_lines(x0, x1, pivot, y1);

    }
    else
    { //subdivide only the larger region
      if(pivot-y0>=y1-pivot)
        {
          setup_lines(x0, x1, y0, pivot);
        }
      else
        {
          setup_lines(x0, x1, pivot, y1);
        }
    }

  }
}