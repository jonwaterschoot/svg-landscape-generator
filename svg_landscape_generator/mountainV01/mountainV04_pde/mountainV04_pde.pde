import controlP5.*;

ControlP5 cp5;

// Variables to hold the parameters controlled by sliders
float peakX, peakY; // No initial values here
float endX, endY;
int baseX1 = 50;
int baseY = 300;
int baseX2 = 550;
float mainRidgeEndX; 
float shadowMargin = 10; 
float shadowCurvature = 1; 
int numShadowLines = 10; 

void setup() {
  size(600, 400);
  cp5 = new ControlP5(this);

  // ControlP5 element dimensions and positioning
  int cp5Width = 200; 
  int cp5Height = 25;
  int cp5X = 20;
  int cp5YStart = 20;
  int cp5Spacing = 30; 

  // Slider for peakX
  cp5.addSlider("peakX", baseX1 + 100, baseX2 - 100, (baseX1 + baseX2) / 2, cp5X, cp5YStart, cp5Width, cp5Height)
    .setLabel("Peak X")
    .setColorLabel(color(105))
    .onChange(e -> {
      peakX = e.getController().getValue();
      drawScene();
    });
  peakX = (baseX1 + baseX2) / 2; // Initialize peakX with the slider's default value

  // Slider for peakY
  cp5.addSlider("peakY", 50, 150, 100, cp5X, cp5YStart + cp5Spacing, cp5Width, cp5Height)
    .setLabel("Peak Y")
    .setColorLabel(color(105))
    .onChange(e -> {
      peakY = e.getController().getValue();
      drawScene();
    });
  peakY = 100; // Initialize peakY with the slider's default value

  // Slider for endX (with constraints)
  cp5.addSlider("endX", baseX1 + (baseX2 - baseX1) * 0.35, baseX1 + (baseX2 - baseX1) * 0.50, baseX1 + (baseX2 - baseX1) * 0.425, cp5X, cp5YStart + 2 * cp5Spacing, cp5Width, cp5Height)
    .setLabel("End X")
    .setColorLabel(color(105))
    .onChange(e -> {
      endX = e.getController().getValue();
      drawScene();
    });

  // Button to regenerate the drawing
  cp5.addButton("regenerate", 1, cp5X, cp5YStart + 3 * cp5Spacing, 100, cp5Height)
    .setLabel("Regenerate")
    .setColorLabel(color(105))
    .onClick(e -> {
      drawScene();
    });

  drawScene(); // Initial drawing
}
void drawScene() {
  background(220);
  noFill();
  stroke(0);

  // Calculate endX as a percentage of the distance between peakX and baseX2
  float baseWidth = baseX2 - baseX1;
  float peakOffset = peakX - baseX1; 

  if (peakX < baseX1 + baseWidth * 0.5) { 
    endX = peakX + (baseWidth - peakOffset) * 0.2; 
  } else {
    endX = peakX - peakOffset * 0.2; 
  }

    // --- Draw the mountain outline ---
  beginShape();
  vertex(baseX1, baseY);
  curveVertex(baseX1 + 50, baseY - 50);
  curveVertex(peakX - 50, peakY + 50);
  curveVertex(peakX, peakY);
  curveVertex(peakX + 50, peakY + 50);
  curveVertex(baseX2 - 50, baseY - 50);
  vertex(baseX2, baseY);
  endShape();

  // --- Draw the inner squiggly line ---
  beginShape();
  vertex(peakX, peakY); 
  float[] lineXPositions = new float[10]; 
  float[] lineYPositions = new float[10]; 
  for (int i = 1; i < 10; i++) {
    float baseX = lerp(peakX, endX, i/10.0);
    float lineY = lerp(peakY, baseY, i/10.0); 
    float lineX = baseX + random(-15, 15); 
    lineY = lineY + random(-10, 10);
    lineX = constrain(lineX, baseX1, peakX); 
    vertex(lineX, lineY);
    lineXPositions[i] = lineX; 
    lineYPositions[i] = lineY;
  }
  vertex(endX, baseY); 
  endShape();

  // --- Draw shadow lines (on the left side only) ---
  for (int i = 1; i < 10; i++) {
    float shadowLineX = lineXPositions[i];
    float shadowLineY1 = lineYPositions[i]; 

    // Find intersection with the mountain outline (more precise)
    float shadowLineY2 = shadowLineY1; 
    for (float y = shadowLineY1; y >= 0; y -= 1) { // Smaller step for accuracy
      // Check a point slightly to the left AND above
      if (!isPointInsideMountain(shadowLineX - 1, y - 1)) { 
        shadowLineY2 = y;
        break;
      }
    }

    // Add slight curve and tilt (adjusted for left side and upwards)
    float midX = shadowLineX - random(5, 10); 
    float midY = (shadowLineY1 + shadowLineY2) / 2 - random(5, 10); 

    // Draw shadow line
    noFill();
    beginShape();
    vertex(shadowLineX, shadowLineY1);
    curveVertex(shadowLineX, shadowLineY1); 
    curveVertex(midX, midY); 
    curveVertex(shadowLineX, shadowLineY2); 
    curveVertex(shadowLineX, shadowLineY2); 
    endShape();
  }
}

// Helper function to check if a point is inside the mountain
boolean isPointInsideMountain(float x, float y) {
  if (x > baseX1 && x < baseX2 && y > peakY && y < baseY) {
    return true;
  } else {
    return false;
  }
}

void draw() {
  // No need to redraw continuously
}
