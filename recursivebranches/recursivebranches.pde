/*

 Draws diagonal lines across a randomly subdivided space.

 Here's what the variables do:

 Variables that control subdivisions:

 min_cell_size: stop subdividing if the width or height of a cell is <= min_cell_size.

 cell_margin: any cell subdivisions will be at least cell_margin pixels away from the wall.

 line_size: the width of our diagonal strokes

 div_both_x/div_both_y: when subdividing an area, controls whether both sides of the divided area are recursively subdivided next. If false, only the larger sub-area gets divided up further.

 overlap: draws a line across every subdivision of space, even if you're going to be subdividing that space further.

 Right now my favorite values for the cell settings are:
 min_cell_size = 45;
 cell_margin = 20;
 line_size = 10;

 Color settings:

 This sketch uses HSB (Hue, Saturation, Brightness) color mode.

 The results of this sketch are often more aesthetically pleasing if the colors selected are fixed in respect to one or two components of an HSB color.

 The global h, s, b float values are there to be the reference value from which the randomized colors vary.

 line_color_mode: what kind of color scheme of our lines will use.

 The styles are:
    anyColor: each line will be a different random color
    baseColor: each line will share a single randomly-chosen color
    fixedH/fixedS/fixedB: each line will share one element of a randomly-chosen color while other two components will vary.
    randomH/randomS/randomB: each line will share two elements of a randomly-chosen color while the remaining component will vary.
 */

float min_cell_size;
float cell_margin;
boolean div_both_x;
boolean div_both_y;
boolean overlap;
float line_size;

float h;    //the dominant hue for the scene.
float s;
float b;
color bg_color;    //empty cells
int line_color_mode; //borders between cells

ArrayList<Line> lines;

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
    this.myColor = color(0, 100, 100);
  }
}

void setup()
{
  fullScreen();
  setup_parameters();
  lines = new ArrayList<Line>();
  setup_lines(0, width, 0, height);
  setup_colors();
}

void setup_parameters()
{
  min_cell_size = random(45, 200);
  cell_margin = random(20, (min_cell_size-2)/2);
  div_both_x = random(1.0)>= .5;
  div_both_y = random(1.0)>= .5;
  overlap = random(1.0)>= .5;
  line_size = random(5, 30);
}

void setup_colors()
{
  h = random(360);
  s = random(10, 100);
  b = random(10, 100);
  colorMode(HSB, 360, 100, 100);
  line_color_mode = int(random(8));
  for (Line l : lines)
  {
    l.myColor = lineColor();
  }

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
    draw_lines();
}

void draw_lines()
{
  strokeCap(ROUND);
  strokeWeight(line_size);
  for (Line l : lines)
  {
    stroke(l.myColor);
    line(l.start.x, l.start.y, l.end.x, l.end.y);
  }
}

/* Randomly subdivides the specified space.
 Refuses to subdivide spaces <= min_cell_size */
void setup_lines(float x0, float x1, float y0, float y1)
{
  //compute width and height of region
  //x1 should be > x0 & y1 > y0 but we'll abs to be safe
  float dx = abs(x1-x0);
  float dy = abs(y1-y0);

  //give up if the region is too small
  if(dx <= min_cell_size) return;
  if(dy <= min_cell_size) return;

  //time to break up our region into two smaller bits
  //pivot will be where the region splits
  //Lines la and lb will spread out from the pivot
  float pivot;
  Line la,lb;

  if(dx >= dy)
  {
    //region is square or wider than tall
    pivot = random(x0+cell_margin, x1-cell_margin);
    la = new Line(new PVector(x0, y0), new PVector(pivot, y1));
    lb = new Line(new PVector(x1, y0), new PVector(pivot, y1));

    float dleft = pivot-x0;
    float dright = x1-pivot;

    //considering the left half
    if(dleft > min_cell_size && (div_both_x || dleft >= dright))
    {
      //subdivide dleft because it > the minimum size
      //and we're either subdividing both sides or it's the larger side
      setup_lines(x0,pivot,y0,y1);

      //if overlap is true, draw a line across this space
      if(overlap) lines.add(la);
    }
    else
    {
      //dleft can't or won't be subdivided, so add a line
      lines.add(la);
    }

    //considering the right half
    if(dright > min_cell_size && (div_both_x || dright > dleft))
    {
      //subdivide dright. it's the min size
      //and we're either subdividing both sides or it's larger.
      setup_lines(pivot,x1,y0,y1);

      //if overlap is true, draw a line across this space
      if(overlap) lines.add(lb);
    }
    else
    {
      //dright can't be subdivided so add a line
      lines.add(lb);
    }


  }
  else
  {
    //region is taller than wide
    pivot = random(y0+cell_margin, y1-cell_margin);
    la = new Line(new PVector(x0, pivot), new PVector(x1, y0));
    lb = new Line(new PVector(x0, pivot), new PVector(x1, y1));

    float dup = pivot-y0;
    float ddown = y1-pivot;

    //considering the upper half
    if(dup > min_cell_size && (div_both_y || dup >= ddown))
    {
      //subdivide dup because it > the minimum size
      //and we're either subdividing both sides or it's the larger side
      setup_lines(x0,x1,y0,pivot);

      //if overlap is true, draw a line across the space
      if(overlap) lines.add(la);
    }
    else
    {
      //dup can't or won't be subdivided, so add a line
      lines.add(la);
    }

    //considering the lower half
    if(ddown > min_cell_size && (div_both_y || ddown > dup))
    {
      //subdivide ddown. it's the min size
      //and we're either subdividing both sides or it's larger.
      setup_lines(x0,x1,pivot,y1);

      //if overlap draw a line across this space
      if(overlap) lines.add(lb);
    }
    else
    {
      //ddown can't be subdivided so add a line
      lines.add(lb);
    }
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P')
  {
    setup_parameters();
    lines = new ArrayList<Line>();
    setup_lines(0, width, 0, height);
    setup_colors();
  }
  if (key == 'l' || key == 'L')
  {
    lines = new ArrayList<Line>();
    setup_lines(0, width, 0, height);
    setup_colors();
  }
  if (key == 'c' || key == 'C') setup_colors();
}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", java.util.Calendar.getInstance());
}
