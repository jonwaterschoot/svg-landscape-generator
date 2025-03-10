import controlP5.*;

ControlP5 cp5;

float mountainHeight = 200;
float mountainWidth = 150;
float roughness = 0.5;
float lineDensity = 5;
float slant = 0.3;
float baseline = 300;
int numMountains = 3;

void setup() {
  size(800, 600);
  cp5 = new ControlP5(this);

  int cp5Width = 200;
  int cp5Height = 20;
  int cp5X = 20;
  int cp5YStart = 20;
  int cp5Spacing = 25;

  cp5.addSlider("mountainHeight", 50, 300, mountainHeight, cp5X, cp5YStart, cp5Width, cp5Height).setLabel("Mountain Height").onChange(e -> mountainHeight = e.getController().getValue());
  cp5.addSlider("mountainWidth", 50, 200, mountainWidth, cp5X, cp5YStart + cp5Spacing, cp5Width, cp5Height).setLabel("Mountain Width").onChange(e -> mountainWidth = e.getController().getValue());
  cp5.addSlider("roughness", 0, 1, roughness, cp5X, cp5YStart + 2 * cp5Spacing, cp5Width, cp5Height).setLabel("Roughness").onChange(e -> roughness = e.getController().getValue());
  cp5.addSlider("lineDensity", 1, 10, lineDensity, cp5X, cp5YStart + 3 * cp5Spacing, cp5Width, cp5Height).setLabel("Line Density").onChange(e -> lineDensity = e.getController().getValue());
  cp5.addSlider("slant", 0, 1, slant, cp5X, cp5YStart + 4 * cp5Spacing, cp5Width, cp5Height).setLabel("Slant").onChange(e -> slant = e.getController().getValue());
 cp5.addButton("redraw")
     .setValue(0)
     .setPosition(cp5X, cp5YStart + 5 * cp5Spacing)
     .setSize(cp5Width, cp5Height)
     .onClick(theEvent -> { // Lambda expression
       if (theEvent.getAction() == ControlP5.ACTION_PRESSED) {
         redrawMountains();
       }
     });

  redrawMountains(); // Initial draw
}

void draw() {
}

void redrawMountains() {
  background(220);
  for (int i = 0; i < numMountains; i++) {
    drawMountain(100 + i * 250, baseline);
  }
}

void drawMountain(float xOffset, float base) {
  float halfWidth = mountainWidth / 2;

  // Generate mountain shape
  beginShape();
  vertex(xOffset - halfWidth, base);

  float peakHeight = mountainHeight * random(0.8, 1);
  float peakX = xOffset + random(-mountainWidth/4, mountainWidth/4);
  
  //Left side of mountain
  for (float x = xOffset - halfWidth; x <= peakX; x+=5){
    float y = map(x, xOffset - halfWidth, peakX, base, base - peakHeight);
    y += map(noise(x*0.02, random(100)),0,1, -roughness*mountainHeight/4, roughness*mountainHeight/4);
    vertex(x, y);
  }
  
  //Right side of mountain
    for (float x = peakX; x <= xOffset + halfWidth; x+=5){
    float y = map(x, peakX, xOffset + halfWidth, base - peakHeight, base);
    y += map(noise(x*0.02, random(200)),0,1, -roughness*mountainHeight/4, roughness*mountainHeight/4);
    vertex(x, y);
  }
  
  vertex(xOffset + halfWidth, base);
  endShape(CLOSE);

  // Draw shadow
  beginShape();
  vertex(peakX, base - peakHeight);
  
  //left side of the shadow
  for (float x = peakX; x >= xOffset - halfWidth; x-=5){
    float y = map(x, peakX, xOffset - halfWidth, base - peakHeight, base);
    y += map(noise(x*0.02, random(300)),0,1, -roughness*mountainHeight/4, roughness*mountainHeight/4);
    vertex(x, y);
  }

  //jagged ridge
  float ridgeX = peakX + mountainWidth * slant/2;
  for(float x = peakX; x <= ridgeX; x+= 3){
    float y = map(x,peakX, ridgeX, base - peakHeight, base - peakHeight/2);
    y+= random(-mountainHeight/10, mountainHeight/10);
    vertex(x,y);
  }
  vertex(ridgeX, base - peakHeight/2);
  endShape(CLOSE);

  // Draw shadow lines
  stroke(0);
  for (float x = peakX; x >= xOffset - halfWidth; x -= lineDensity) {
    line(x, base - peakHeight, x, base);
  }
  noStroke();
}
