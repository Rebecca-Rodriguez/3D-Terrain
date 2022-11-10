import controlP5.*;

ControlP5 cp5;

// UI objects
Slider rowsSlider, colsSlider, terrainSlider, heightSlider, snowSlider;
Textlabel snowLabel;
Button generateButton;
Textfield filenameText;
Toggle strokeToggle, colorToggle, blendToggle;

// Variables
ArrayList<PVector> points = new ArrayList<PVector>();
ArrayList<Integer> triangles = new ArrayList<>();
PVector cameraPosition = new PVector();
PImage source;
int rows = 0;
int cols = 0;
float gridSize = 0.00;
boolean generate = false;
String fileName = "";

boolean strokeCheck = false;
boolean colorCheck  = false;
boolean blendCheck = false;
float heightMod = 0.00;
float snowThresh = 0.0;

float relativeHeight;
float heightValue;

color snow = color(255, 255, 255);
color grass = color(143, 170, 64);
color rock = color(135, 135, 135);
color dirt = color(160, 126, 84);
color water = color(0, 75, 200);

Camera cameraObject = new Camera();

void setup()
{
  size(1200, 800, P3D);
  pixelDensity(2);

//  cameraPosition = new PVector(100, -100, 100);

  cp5 = new ControlP5(this);

  /*-------------------------- LEFT SIDE --------------------------*/
  // Slider - rows
  rowsSlider = cp5.addSlider("rows", 1, 100)
    .setPosition(15, 15)
    .setSize(150, 15)
    .setValue(10);

  // Slider - columns
  colsSlider = cp5.addSlider("columns", 1, 100)
    .setDecimalPrecision(0)
    .setPosition(15, 50)
    .setSize(150, 15)
    .setValue(10);

  // Slider - terrain
  terrainSlider = cp5.addSlider("terrain size", 20, 50)
    .setPosition(15, 85)
    .setSize(150, 15)
    .setValue(30);

  // Button - Generate
  generateButton = cp5.addButton("generate")
    .setPosition(15, 140)
    .setSize(80, 30);

  // Textfield
  filenameText = cp5.addTextfield("load from file")
    .setPosition(15, 190)
    .setSize(250, 25)
    .setValue("")
    .setAutoClear(false);

  /*-------------------------- RIGHT SIDE --------------------------*/
  // Toggle - stroke
  strokeToggle = cp5.addToggle("stroke")
    .setPosition(350, 15)
    .setSize(60, 30);

  // Toggle - color
  colorToggle = cp5.addToggle("color")
    .setPosition(425, 15)
    .setSize(60, 30);

  // Toggle - color
  blendToggle = cp5.addToggle("blend")
    .setPosition(500, 15)
    .setSize(60, 30);

  // Slider - height
  heightSlider = cp5.addSlider("height modifier", -5, 5)
    .setPosition(350, 85)
    .setSize(150, 15)
    .setValue(0.00);

  // Slider - snow
  snowSlider = cp5.addSlider("snow threshold", 1, 5)
    .setPosition(350, 120)
    .setSize(150, 15);

  reset();
}

void reset()
{
  rows = (int)rowsSlider.getValue();
  cols = (int)colsSlider.getValue();
  gridSize = terrainSlider.getValue();
  fileName = filenameText.getText();
  source = loadImage("data/" + fileName + ".png");
  colorCheck = colorToggle.getBooleanValue();
  blendCheck = blendToggle.getBooleanValue();
  heightMod = heightSlider.getValue();
  snowThresh = snowSlider.getValue();
  generate = false;
}

void draw()
{
  // create projection matrix to convert 3D to 2D
  perspective(radians(90.0f), width/(float)height, 0.1, 1000);

  //camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
  camera(cameraPosition.x, cameraPosition.y, cameraPosition.z,
    0, 0, 0,
    0, 1, 0);
    
  cameraPosition = cameraObject.Update(cameraPosition);

  background(0);

  if (keyPressed)
  {
    if (key == ENTER)
    {
      generate = true;
    }
  }

  if (generate)
  {
    reset();
    getPoints();
    getTriangles();

    if (fileName.contains("terrain0") || fileName.contains("terrain1") || fileName.contains("terrain2") ||
      fileName.contains("terrain3") || fileName.contains("terrain4") || fileName.contains("terrain5") || fileName.contains("terrain6"))
    {
      heightMap();
    } else
    {
      fileName = "";
    }
  }

  strokeCheck = strokeToggle.getBooleanValue();

  drawGrid();

  camera();
  perspective();
}

void mouseDragged(MouseEvent e)
{

  if (cp5.controlWindow.isMouseOver())
  {
    return;
  }

  float deltaX = (mouseX - pmouseX) * 0.15f;
  float deltaY = (mouseY - pmouseY) * 0.15f;

  cameraObject.phi += deltaX;
  cameraObject.theta += deltaY;

  cameraPosition = cameraObject.Update(cameraPosition);

  camera();
  perspective();
}

void mouseWheel(MouseEvent e)
{
  float event = e.getCount();
  cameraObject.Zoom(event);

  cameraPosition = cameraObject.Update(cameraPosition);

  camera();
  perspective();
}

void getPoints()
{
  points.clear();
  float halfGrid = gridSize / 2;
  float rowUnits = gridSize / rows;
  float colUnits = gridSize / cols;

  float x = -halfGrid;
  float z = -halfGrid;

  for (int currentRow = 0; currentRow <= rows; currentRow++)
  {
    for (int currentCol = 0; currentCol <= cols; currentCol++)
    {
      points.add(new PVector(x, 0, z));

      z += colUnits;
    }
    x += rowUnits;
    z = -halfGrid;
  }
}

void getTriangles()
{
  triangles.clear();
  int startingIndex = 0;
  int verticesInRow = cols + 1;

  for (int currentRow = 0; currentRow < rows; currentRow++)
  {
    for (int currentCol = 0; currentCol < cols; currentCol++)
    {
      startingIndex = currentRow * verticesInRow + currentCol;

      triangles.add(startingIndex);                        // this stores the index that needs to later be accessed to create the triangle
      triangles.add(startingIndex + 1);                    // this is the second index of the triangle
      triangles.add(startingIndex + verticesInRow);        // this is the third index of the triangle

      triangles.add(startingIndex + 1);                    // this is the start of the second triangle in the square
      triangles.add(startingIndex + verticesInRow + 1);    // this is the second index of the other triangle
      triangles.add(startingIndex + verticesInRow);        // this is the third index of the other triangle
    }
  }
}

void heightMap()
{
  for (int i = 0; i <= rows; i++)
  {
    for (int j = cols; j >= 0; j--)
    {
      // rows/cols +1 because there are more vert columns than polygon columns
      int x_index = (int) map(j, 0, cols+1, source.width -1, 0);
      int y_index = (int) map(i, 0, rows+1, 0, source.height - 1);
      color currentColor = source.get(x_index, y_index);

      float heightFromColor = map(red(currentColor), 0, 255, 0, 1.0f);

      int vertex_index = i * (cols + 1) + j;
      points.get(vertex_index).y = (-1) * heightFromColor;          // times by -1 because it has to be inverted for y-axis
    }
  }
  source.updatePixels();
}

void drawGrid()
{
  stroke(0);
  color currentColor = 255;

  beginShape(TRIANGLES);

  if (strokeCheck)
  {
    strokeWeight(1);
  } else
  {
    strokeWeight(0);
  }

  for (int i = 0; i < triangles.size(); i++)
  {
    int vertIndex = triangles.get(i);
    PVector vert = points.get(vertIndex);

    if (colorCheck)
    {
      float relativeHeight = abs(vert.y * heightMod / -snowThresh);
      currentColor = setColor(relativeHeight);
    } else
    {
      currentColor = 255;
    }
    fill(currentColor);
//    rotate(vert.x);
    vertex(vert.x, vert.y * heightMod, vert.z);
  }
  endShape();
}

color setColor(float relativeHeight)
{
  float ratio;
  if (relativeHeight >= 0.8 && relativeHeight <= 1.0)
  {
    if (blendCheck)
    {
      ratio = (heightValue-0.8f) / 0.2f;
      return (color)lerp(rock, snow, ratio);
    } else
    {
      return snow;
    }
  } else if (relativeHeight >= 0.4 && relativeHeight <= 0.8)
  {
    if (blendCheck)
    {
      ratio = (heightValue-0.4f) / 0.4f;
      return (color)lerp(grass, rock, ratio);
    } else
    {
      return rock;
    }
  } else if (relativeHeight >= 0.2 && relativeHeight <= 0.4)
  {
    if (blendCheck)
    {
      ratio = (heightValue-0.2f) / 0.2f;
      return (color)lerp(dirt, grass, ratio);
    } else
    {
      return grass;
    }
  } else
  {
    if (blendCheck)
    {
      ratio = (heightValue) / 0.2f;
      return (color)lerp(water, dirt, ratio);
    } else
    {
      return water;
    }
  }
}
