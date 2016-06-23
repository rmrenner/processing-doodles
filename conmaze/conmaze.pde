int grid_w = 40;
int grid_h = 40;
float cell_w, cell_h;
int time;
int refresh_rate;

boolean grid[][];
boolean display[][];

void setup()
{
  size(2000,2000);
  grid_setup();
  time = 0;
  refresh_rate = 30;
  strokeWeight(3);
}

void draw()
{
  background(255);

  grid_draw();
  
  time += 1;

  if(time % refresh_rate == 0)
  { 
    grid_update();
    display_update();
  }
  
}

void grid_setup()
{
  grid = new boolean[grid_w][grid_h];
  display = new boolean[grid_w][grid_h];
  cell_w = width / grid_w;
  cell_h = height / grid_h;
  
  for(int i = 0; i < grid_w; i++)
  {
    for(int j = 0; j < grid_h; j++)
    {
      grid[i][j] = (random(10) < 2);   
    }
  }
}

void grid_update()
{
  boolean[][] g1 = new boolean[grid_w][grid_h];
  for(int i = 0; i < grid_w; i++)
  {
    for(int j = 0; j < grid_h; j++)
    {
      int ns = count_neighbors(grid,i, j);
      if(grid[i][j])
      {
        g1[i][j] = ns == 2 || ns == 3;
      }
      else
      {
        g1[i][j] = ns == 3; 
      }
    }
  }
  grid = g1;
}

void display_update()
{
  for(int i = 0; i < grid_w; i++)
  {
    for(int j = 0; j < grid_h; j++)
    {
        if(grid[i][j])
        {
          display[i][j] = !display[i][j];
        }
    }
  }
}

int count_neighbors(boolean[][] g, int x, int y)
{
      int ns = 0; //neighbors
      //calculate the indices of moore neighborhood
      //a cruelty-free alternative to shitloads of nested ifs
      //to handle edge cases
      int x0 = (x - 1 >= 0) ? x - 1: grid_w - 1;
      int x1 = (x + 1 < grid_w) ? x + 1 : 0;
      int y0 = (y - 1 >= 0) ? y - 1 : grid_h - 1;
      int y1 = (y + 1 < grid_h) ? y + 1 : 0;
      
      ns += g[x0][y0] ? 1 : 0;
      ns += g[x0][y] ? 1 : 0;
      ns += g[x0][y1] ? 1 : 0;
      ns += g[x][y0] ? 1 : 0;
      ns += g[x][y1] ? 1 : 0;
      ns += g[x1][y0] ? 1 : 0;
      ns += g[x1][y] ? 1 : 0;
      ns += g[x1][y1] ? 1 : 0;
      
      return ns;
}

void grid_draw()
{ 
  
  //fill(0,0,0);
  for(int i = 0; i < grid_w; i++)
  {
    for(int j = 0; j < grid_h; j++)
    {
      if(display[i][j])
      {
        line(i*cell_w,j*cell_h,(i+1)*cell_w,(j+1)*cell_h);
        line((i+1)*cell_w,j*cell_h,i*cell_w,(j+1)*cell_h);
      }
      else
      {
        if(count_neighbors(display,i,j)>3)
        {line((i+1)*cell_w,j*cell_h,i*cell_w,(j+1)*cell_h);}
      }
    }
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");

}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", java.util.Calendar.getInstance());
}