import processing.svg.*;
import controlP5.*;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

ControlP5 cp5;
PShape svg;

// Variables for incremental file naming
int exportCounter = 0;

// Canvas dimensions (export resolution)
int canvasWidth = 4742;
int canvasHeight = 3271;

// Display dimensions (fullscreen with aspect ratio)
int displayWidth;
int displayHeight;

// Water parameters
float waterAmplitude = 20;
float waterDensity = 0.005; // Adjusted initial density
int minWaterLines = 50; // Increased minimum number of lines
int maxWaterLines = 200; // Increased maximum number of lines

// New variable for water seed
float waterSeed = 0;
float waterLineLength = 200; // Default water line length

// Water Noise parameters
float noiseScaleX = 0.02;
float noiseScaleY = 0.02;

// New parameters for line spacing
float horizontalSpacing = 1; // Default horizontal spacing
float verticalSpacingFactor = 1; // Factor to adjust vertical spacing

// Sun parameters
float sunSize = 100;
float sunX = 200;
float sunY = 200;

// Horizon position
float horizonPosition = 1.0 / 3.0; // Default horizon at 1/3 height

// Mountain parameters
float mountainAmplitude = 150;
float mountainFrequency = 0.01;

void setup() {
  fullScreen();

  // Calculate display dimensions maintaining aspect ratio AFTER fullscreen()
  float aspectRatio = (float)canvasWidth / canvasHeight;
  if ((float)width / height > aspectRatio) {
    displayHeight = height;
    displayWidth = (int)(height * aspectRatio);
  } else {
    displayWidth = width;
    displayHeight = (int)(width / aspectRatio);
  }

  smooth();
  noiseDetail(8, 0.5); // Set noise detail for static noise
  cp5 = new ControlP5(this);

  // ControlP5 element dimensions and positioning (fixed pixels, top-left)
  int cp5Width = 400;
  int cp5Height = 25;
  int cp5X = 20;
  int cp5YStart = 20;
  int cp5Spacing = 35; // Increased spacing for better margin

  // Rearranged the sliders and added new sliders for spacing
  cp5.addSlider("waterDensity", 0, 0.01, waterDensity, cp5X, cp5YStart, cp5Width, cp5Height)
     .setLabel("Water Density")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       waterDensity = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("waterAmplitude", 0, 100, waterAmplitude, cp5X, cp5YStart + cp5Spacing, cp5Width, cp5Height)
     .setLabel("Water Amplitude")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       waterAmplitude = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("waterSeed", 0, 100, waterSeed, cp5X, cp5YStart + cp5Spacing * 2, cp5Width, cp5Height)
     .setLabel("Water Seed")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       waterSeed = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("waterLineLength", 50, 500, waterLineLength, cp5X, cp5YStart + cp5Spacing * 3, cp5Width, cp5Height)
     .setLabel("Water Line Length")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       waterLineLength = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("horizontalSpacing", 0.1, 10, horizontalSpacing, cp5X, cp5YStart + cp5Spacing * 4, cp5Width, cp5Height)
     .setLabel("Horizontal Spacing")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       horizontalSpacing = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("verticalSpacingFactor", 0.1, 4, verticalSpacingFactor, cp5X, cp5YStart + cp5Spacing * 5, cp5Width, cp5Height)
     .setLabel("Vertical Spacing Factor")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       verticalSpacingFactor = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("sunSize", 0, canvasWidth / 3, sunSize, cp5X, cp5YStart + cp5Spacing * 6, cp5Width, cp5Height)
     .setLabel("Sun Size")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       sunSize = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("sunX", 0, canvasWidth, sunX, cp5X, cp5YStart + cp5Spacing * 7, cp5Width, cp5Height)
     .setLabel("Sun X Position")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       sunX = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("sunY", 0, canvasHeight / 3, sunY, cp5X, cp5YStart + cp5Spacing * 8, cp5Width, cp5Height)
     .setLabel("Sun Y Position")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       sunY = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("horizonPosition", 0, 1, horizonPosition, cp5X, cp5YStart + cp5Spacing * 9, cp5Width, cp5Height)
     .setLabel("Horizon Position")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       horizonPosition = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("mountainAmplitude", 0, 300, mountainAmplitude, cp5X, cp5YStart + cp5Spacing * 10, cp5Width, cp5Height)
     .setLabel("Mountain Amplitude")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       mountainAmplitude = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("mountainFrequency", 0.001, 0.02, mountainFrequency, cp5X, cp5YStart + cp5Spacing * 11, cp5Width, cp5Height)
     .setLabel("Mountain Frequency")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       mountainFrequency = e.getController().getValue();
       drawScene();
     });

  // Add the export SVG button
  cp5.addButton("exportSVG")
     .setLabel("Export to SVG")
     .setPosition(cp5X, cp5YStart + cp5Spacing * 12)
     .setSize(cp5Width, cp5Height)
     .onClick(e -> exportSVG());

  frameRate(15); // Set framerate to 15 frames per second
  drawScene(); // Initial draw
}

void draw() {
  // Empty draw function ensures no unnecessary looping
}

void drawScene() {
  background(255);

  // Calculate scaling factors for display
  float scaleX = (float)displayWidth / canvasWidth;
  float scaleY = (float)displayHeight / canvasHeight;

  // Apply clipping to match the canvas dimensions
  clip(0, 0, canvasWidth, canvasHeight);

  // Draw to SVG if exporting, otherwise draw to screen
  if (svg != null) {
    scale(1, 1); // No scaling when exporting
  } else {
    scale(scaleX, scaleY);
  }

  // Calculate horizon Y position based on the slider value
  int horizonY = (int) (canvasHeight * horizonPosition);

  // Sky
  fill(200);
  rect(0, 0, canvasWidth, horizonY);

  // Mountainscape
  drawMountains(horizonY);

  // Sun (Draw BEFORE water)
  stroke(255, 0, 0);
  fill(255, 255, 255);
  strokeWeight(2); // Double thickness for sun stroke
  ellipseMode(CENTER);
  ellipse(sunX, sunY, sunSize * 2, sunSize * 2); // Double thickness for sun diameter

  // Water
  drawWater(horizonY);

  // Remove clipping
  noClip();

  if (svg != null) {
    endRecord();
    svg = null; // Reset svg to null after export
  }

  // Draw ControlP5 elements *after* scaling is reset
  if (svg == null) { // Only draw when not exporting
    resetMatrix(); // Very important!
    cp5.draw();
  }
}

void drawMountains(int horizonY) {
  noFill();
  stroke(100); // Set the color for the mountains
  strokeWeight(2);

  beginShape();
  for (int x = 0; x <= canvasWidth; x += 10) {
    float y = horizonY - (noise(x * mountainFrequency) * mountainAmplitude);
    vertex(x, y);
  }
  vertex(canvasWidth, horizonY); // Right corner
  vertex(0, horizonY); // Left corner
  endShape(CLOSE);
}

void drawWater(int horizonY) {
  stroke(0);
  strokeWeight(2);
  noFill();

  int numLines = (int)map(waterDensity, 0, 0.01, maxWaterLines * 10, minWaterLines);

  for (int i = 0; i < numLines; i++) {
    // Gradually increasing the wave height as we move closer to the bottom
    float yBase = map(pow(map(i, 0, numLines - 1, 0, 1), 2), 0, 1, horizonY, canvasHeight);
    float lineOffset = noise(i * 0.1f + waterSeed) * 20 - 10;

    // Generate wave parameters for each line
    float lineAmplitude = map(yBase, horizonY, canvasHeight, waterAmplitude * 0.1, waterAmplitude); // Increasing amplitude
    float lineFrequency = random(0.005, 0.02); // Random frequency for each line
    float phaseOffset = random(TWO_PI); // Random phase shift for each line

    // Adjust line length based on position
    float segmentLength = map(yBase, horizonY, canvasHeight, waterLineLength * 0.1, waterLineLength);
    float segmentStart = random(0, canvasWidth - segmentLength);
    float segmentEnd = segmentStart + segmentLength;

    // Adjust vertical spacing between lines
    float verticalSpacing = map(yBase, horizonY, canvasHeight, 5 * verticalSpacingFactor, 20 * verticalSpacingFactor);
    float y = yBase + lineOffset;

    if (y > horizonY && y < canvasHeight) {
      beginShape();
      for (float px = segmentStart; px < segmentEnd; px += horizontalSpacing) {
        // Generate a unique wave pattern for each line based on its position
        float wave = sin(px * lineFrequency + phaseOffset) * lineAmplitude;

        // Combined wave with noise
        float noiseOffset = noise(px * noiseScaleX, yBase * noiseScaleY) * lineAmplitude;
        float finalY = y + wave + noiseOffset;

        // Reflection Code (Double Thickness)
        float reflectionTop = horizonY;
        float reflectionBottom = canvasHeight;
        float reflectionWidthTop = sunSize * 2;
        float reflectionWidthBottom = sunSize * 4;
        float reflectionCenter = sunX;
        float reflectionLeft = map(yBase, reflectionTop, reflectionBottom,
                                    reflectionCenter - reflectionWidthTop / 2,
                                    reflectionCenter - reflectionWidthBottom / 2);
        float reflectionRight = map(yBase, reflectionTop, reflectionBottom,
                                     reflectionCenter + reflectionWidthTop / 2,
                                     reflectionCenter + reflectionWidthBottom / 2);

        if (y > reflectionTop && y < reflectionBottom && px > reflectionLeft && px < reflectionRight) {
          stroke(255, 0, 0);
          strokeWeight(4);
        } else {
          stroke(0);
          strokeWeight(2);
        }

        vertex(px, finalY); // Use the smoothed Y value
      }
      endShape();
    }
  }
}

public void exportSVG() {
  // Get the current date and time
  String currentDateTime = new SimpleDateFormat("ddMMyy_HHmm").format(new Date());

  // Create a filename with the counter and date/time
  String filename = String.format("landscape_%04d_%s.svg", exportCounter++, currentDateTime);

  // Begin recording to the SVG file with the correct dimensions
  PGraphics pg = createGraphics(canvasWidth, canvasHeight, SVG, filename);
  pg.beginDraw();
  pg.background(255);

  // Apply clipping to the export graphics
  pg.clip(0, 0, canvasWidth, canvasHeight);

  // Calculate horizon Y position based on the slider value
  int horizonY = (int) (canvasHeight * horizonPosition);

  // Draw scene on the export graphics
  pg.scale(1, 1); // No scaling for export
  pg.fill(200);
  pg.rect(0, 0, canvasWidth, horizonY);
  drawMountains(pg, horizonY); // Pass the graphics context
  pg.stroke(255, 0, 0);
  pg.fill(255, 255, 255);
  pg.strokeWeight(2);
  pg.ellipseMode(CENTER);
  pg.ellipse(sunX, sunY, sunSize * 2, sunSize * 2);
  drawWater(pg, horizonY); // Pass the graphics context

  pg.endDraw();
  pg.dispose();
  
  println("SVG exported: " + filename);
}

void drawMountains(PGraphics pg, int horizonY) {
  pg.noFill();
  pg.stroke(100); // Set the color for the mountains
  pg.strokeWeight(2);

  pg.beginShape();
  for (int x = 0; x <= canvasWidth; x += 10) {
    float y = horizonY - (noise(x * mountainFrequency) * mountainAmplitude);
    pg.vertex(x, y);
  }
  pg.vertex(canvasWidth, horizonY); // Right corner
  pg.vertex(0, horizonY); // Left corner
  pg.endShape(CLOSE);
}

void drawWater(PGraphics pg, int horizonY) {
  pg.stroke(0);
  pg.strokeWeight(2);
  pg.noFill();

  int numLines = (int)map(waterDensity, 0, 0.01, maxWaterLines * 10, minWaterLines);

  for (int i = 0; i < numLines; i++) {
    float yBase = map(pow(map(i, 0, numLines - 1, 0, 1), 2), 0, 1, horizonY, canvasHeight);
    float lineOffset = noise(i * 0.1f + waterSeed) * 20 - 10;
    float lineAmplitude = map(yBase, horizonY, canvasHeight, waterAmplitude * 0.1, waterAmplitude);
    float lineFrequency = random(0.005, 0.02);
    float phaseOffset = random(TWO_PI);
    float segmentLength = map(yBase, horizonY, canvasHeight, waterLineLength * 0.1, waterLineLength);
    float segmentStart = random(0, canvasWidth - segmentLength);
    float segmentEnd = segmentStart + segmentLength;
    float verticalSpacing = map(yBase, horizonY, canvasHeight, 5 * verticalSpacingFactor, 20 * verticalSpacingFactor);
    float y = yBase + lineOffset;

    if (y > horizonY && y < canvasHeight) {
      pg.beginShape();
      for (float px = segmentStart; px < segmentEnd; px += horizontalSpacing) {
        float wave = sin(px * lineFrequency + phaseOffset) * lineAmplitude;
        float noiseOffset = noise(px * noiseScaleX, yBase * noiseScaleY) * lineAmplitude;
        float finalY = y + wave + noiseOffset;

        float reflectionTop = horizonY;
        float reflectionBottom = canvasHeight;
        float reflectionWidthTop = sunSize * 2;
        float reflectionWidthBottom = sunSize * 4;
        float reflectionCenter = sunX;
        float reflectionLeft = map(yBase, reflectionTop, reflectionBottom,
                                    reflectionCenter - reflectionWidthTop / 2,
                                    reflectionCenter - reflectionWidthBottom / 2);
        float reflectionRight = map(yBase, reflectionTop, reflectionBottom,
                                     reflectionCenter + reflectionWidthTop / 2,
                                     reflectionCenter + reflectionWidthBottom / 2);

        if (y > reflectionTop && y < reflectionBottom && px > reflectionLeft && px < reflectionRight) {
          pg.stroke(255, 0, 0);
          pg.strokeWeight(4);
        } else {
          pg.stroke(0);
          pg.strokeWeight(2);
        }

        pg.vertex(px, finalY);
      }
      pg.endShape();
    }
  }
}
