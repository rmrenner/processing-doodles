/*

 Recursively subdivides a space into little randomly-colored rectangles.
 
 Here's what the variables do:
 
 Variables that control subdivisions:
 
 min_cell_size: stop subdividing if the width or height of a cell is <= min_cell_size.
 
 cell_margin: any cell subdivisions will be at least cell_margin pixels away from the wall.
 
 line_size: if we draw the subdividing lines, they will be line_size in width.
 
 div_both_x/div_both_y: when subdividing an area, controls whether both sides of the divided area are recursively subdivided next. If false, only the larger sub-area gets divided up further.
 cell_both_x/cell_both_y: if true, creates a cell whenever the program decides not to subdivide an area. (ie, if (div_both_x == false OR div_both_y == false) OR (cell size <= min cell size)  If false, it only creates a cell when cell size <= min cell size
 
 Right now my favorite values for the cell settings are:
 min_cell_size = 45;
 cell_margin = 20;
 line_size = 10;
 
 Color settings:
 
 This sketch uses HSB (Hue, Saturation, Brightness) color mode.
 
 The results of this sketch are often more aesthetically pleasing if the colors selected are fixed in respect to one or two components of an HSB color.
 
 The global h, s, b float values are there to be the reference value from which the randomized colors vary.
 */

float min_cell_size = random(45, 200);
float cell_margin = random(20, (min_cell_size-2)/2);
boolean div_both_x = random(1.0)>= .5;
boolean div_both_y = random(1.0)>= .5;
boolean cell_both_x = random(1.0)>= .5;
boolean cell_both_y = random(1.0)>= .5;

float line_size = random(5, 30);

float h;    //the dominant hue for the scene.
float s;
float b;
color bg_color;    //empty cells
int line_color_mode; //borders between cells
int cell_color_mode; //filled-in cells

boolean show_lines = random(1.0)>= .5;
boolean show_cells = !show_lines || random(1.0)>= .5;

ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<Line> cells = new ArrayList<Line>();

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
    this.myColor = color(255, 255, 255);
  }
}

void setup()
{
  fullScreen();
  setup_colors();
  setup_lines(0, width, 0, height);
}

void setup_colors()
{
  h = random(360);
  s = random(10, 100);
  b = random(10, 100);
  colorMode(HSB, 360, 100, 100);
  line_color_mode = int(random(8));
  cell_color_mode = int(random(8));
}

color lineColor()
{
  switch(line_color_mode)
  {
  case 0:
    return anyColor();
  case 1:
    return fixedH();
  case 2:
    return fixedS();
  case 3:
    return fixedB();
  case 4:
    return randomH();
  case 5:
    return randomS();
  case 6:
    return randomB();
  case 7:
    return baseColor();
  default:
    return color(0, 0, 0);
  }
}

color cellColor()
{
  switch(cell_color_mode)
  {
  case 0:
    return anyColor();
  case 1:
    return fixedH();
  case 2:
    return fixedS();
  case 3:
    return fixedB();
  case 4:
    return randomH();
  case 5:
    return randomS();
  case 6:
    return randomB();
  case 7:
    return baseColor();
  default:
    return color(0, 0, 0);
  }
}

color anyColor()
{
  return color(random(360), random(10, 100), random(10, 100));
}

color baseColor()
{  
  return color(h, s, b);
}

color fixedH()
{
  return color(h, random(10, 100), random(10, 100));
}

color fixedS()
{
  return color(random(360), s, random(10, 100));
}

color fixedB()
{
  return color(random(360), random(10, 100), b);
}

color randomH()
{
  return color(random(360), s, b);
}
color randomS()
{
  return color(h, random(10, 100), b);
}
color randomB()
{
  return color(h, s, random(10, 100));
}

void draw()
{
  background(bg_color);
  if (show_cells)
  {  
    draw_cells();
  }
  if (show_lines)
  {
    draw_lines();
  }
}

void draw_lines()
{
  strokeCap(PROJECT);
  strokeWeight(line_size);
  for (Line l : lines)
  {
    stroke(l.myColor);
    line(l.start.x, l.start.y, l.end.x, l.end.y);
  }
}

void draw_cells()
{
  rectMode(CORNERS);
  noStroke();
  for (Line c : cells)
  { 
    fill(c.myColor);
    rect(c.start.x, c.start.y, c.end.x, c.end.y);
  }
}

/* Randomly subdivides the specified space.
 Refuses to subdivide spaces <= min_cell_size */
void setup_lines(float x0, float x1, float y0, float y1)
{
  float dx = abs(x1-x0); //calculate horiz size of area
  float dy = abs(y1-y0); //calculate vert size of area

  //if either dimension is less than min cell size, stop recursing
  if (dx <= min_cell_size || dy <= min_cell_size)
  {
    cells.add(new Line(new PVector(x0, y0), new PVector(x1, y1), cellColor()));
    return;
  }

  float pivot;
  Line l;
  if (dx >= dy)
  {
    //Width > Height or Square. Make vertical line.
    pivot = random(x0+cell_margin, x1-cell_margin);
    l = new Line(new PVector(pivot, y0), new PVector(pivot, y1), lineColor());
    lines.add(l);

    //This line creates two new regions to consider:
    if (div_both_x)
    {
      setup_lines(x0, pivot, y0, y1);
      setup_lines(pivot, x1, y0, y1);
    } else
    {
      //Variant: only subdivide the larger region.
      if (pivot-x0>=x1-pivot)
      {
        //subdivide the larger region
        setup_lines(x0, pivot, y0, y1);
        
        //create a cell out of the smaller region
        if(cell_both_x)
        { cells.add(new Line(new PVector(pivot, y0), new PVector(x1, y1), cellColor())); }
      } else
      {
        //subdivide the larger region
        setup_lines(pivot, x1, y0, y1);
        
        //create a cell out of the smaller region
        if(cell_both_x)
        { cells.add(new Line(new PVector(x0, y0), new PVector(pivot, y1), cellColor())); }
      }
    }
  } else
  {
    //Height > Width. Make horizontal line.
    pivot = random(y0+cell_margin, y1-cell_margin);
    l = new Line(new PVector(x0, pivot), new PVector(x1, pivot), lineColor());
    lines.add(l);
    if (div_both_y)
    {
      setup_lines(x0, x1, y0, pivot);
      setup_lines(x0, x1, pivot, y1);
    } else
    { //subdivide only the larger region
      if (pivot-y0>=y1-pivot)
      {
        
        //subdivide larger region
        setup_lines(x0, x1, y0, pivot);
        
        //create a cell out of the smaller region
        if(cell_both_y)
        { cells.add(new Line(new PVector(x0, pivot), new PVector(x1, y1), cellColor())); }

      } else
      {
        //subdivide larger region
        setup_lines(x0, x1, pivot, y1);

        //create a cell out of the smaller region
        if(cell_both_y)
        { cells.add(new Line(new PVector(x0, y0), new PVector(x1, pivot), cellColor())); }

      }
    }
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'c' || key == 'C') show_cells = !show_cells;
  if (key == 'l' || key == 'L') show_lines = !show_lines;
}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", java.util.Calendar.getInstance());
}