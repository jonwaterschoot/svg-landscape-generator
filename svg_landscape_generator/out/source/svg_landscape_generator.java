/* autogenerated by Processing revision 1293 on 2024-12-23 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import processing.svg.*;
import controlP5.*;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class svg_landscape_generator extends PApplet {







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
float waterDensity = 0.005f; // Adjusted initial density
int minWaterLines = 50; // Increased minimum number of lines
int maxWaterLines = 200; // Increased maximum number of lines

// New variable for water seed
float waterSeed = 0;
float waterLineLength = 200; // Default water line length

// Water Noise parameters
float noiseScaleX = 0.02f;
float noiseScaleY = 0.02f;

// New parameters for line spacing
float horizontalSpacing = 1; // Default horizontal spacing
float verticalSpacingFactor = 1; // Factor to adjust vertical spacing

// Sun parameters
float sunSize = 100;
float sunX = 200;
float sunY = 200;

// Horizon position
float horizonPosition = 1.0f / 3.0f; // Default horizon at 1/3 height

// Mountain parameters
float mountainAmplitude = 150;
float mountainFrequency = 0.01f;

// Additional mountain parameters
float baseHeight = 100;
float peakHeight = 150;
float roughness = 5;
float sharpness = 1;
int numMountains = 3;

// Add these variables at the top of your file
int numMountainPoints = 100; // Number of points to define the mountain shape
int numLines = 100; // Number of lines for the water

public void setup() {
  /* size commented out by preprocessor */;

  // Calculate display dimensions maintaining aspect ratio AFTER fullscreen()
  float aspectRatio = (float)canvasWidth / canvasHeight;
  if ((float)width / height > aspectRatio) {
    displayHeight = height;
    displayWidth = (int)(height * aspectRatio);
  } else {
    displayWidth = width;
    displayHeight = (int)(width / aspectRatio);
  }

  /* smooth commented out by preprocessor */;
  noiseDetail(8, 0.5f); // Set noise detail for static noise
  cp5 = new ControlP5(this);

  // ControlP5 element dimensions and positioning (fixed pixels, top-left)
  int cp5Width = 400;
  int cp5Height = 25;
  int cp5X = 20;
  int cp5YStart = 20;
  int cp5Spacing = 35; // Increased spacing for better margin

  // Rearranged the sliders and added new sliders for spacing
  cp5.addSlider("waterDensity", 0, 0.01f, waterDensity, cp5X, cp5YStart, cp5Width, cp5Height)
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

  cp5.addSlider("horizontalSpacing", 0.1f, 10, horizontalSpacing, cp5X, cp5YStart + cp5Spacing * 4, cp5Width, cp5Height)
     .setLabel("Horizontal Spacing")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       horizontalSpacing = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("verticalSpacingFactor", 0.1f, 4, verticalSpacingFactor, cp5X, cp5YStart + cp5Spacing * 5, cp5Width, cp5Height)
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

  cp5.addSlider("baseHeight", 50, 200, baseHeight, cp5X, cp5YStart + cp5Spacing * 10, cp5Width, cp5Height)
     .setLabel("Base Height")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       baseHeight = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("peakHeight", 50, 300, peakHeight, cp5X, cp5YStart + cp5Spacing * 11, cp5Width, cp5Height)
     .setLabel("Peak Height")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       peakHeight = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("roughness", 0, 20, roughness, cp5X, cp5YStart + cp5Spacing * 12, cp5Width, cp5Height)
     .setLabel("Roughness")
     .setColorLabel(color(105)) // Set label color to dark gray
     .onChange(e -> {
       roughness = e.getController().getValue();
       drawScene();
     });

  // Add the export SVG button
  cp5.addButton("exportSVG")
     .setLabel("Export to SVG")
     .setPosition(cp5X, cp5YStart + cp5Spacing * 13)
     .setSize(cp5Width, cp5Height)
     .onClick(e -> exportSVG());

  frameRate(15); // Set framerate to 15 frames per second
  drawScene(); // Initial draw
}

public void draw() {
  // Empty draw function ensures no unnecessary looping
}

public void drawScene() {
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

  // Sun (Draw BEFORE mountains and water)
  if (sunY < horizonY) {
    stroke(255, 0, 0);
    fill(255, 255, 255);
    strokeWeight(2); // Double thickness for sun stroke
    ellipseMode(CENTER);
    ellipse(sunX, sunY, sunSize * 2, sunSize * 2); // Double thickness for sun diameter
  }

  // Mountainscape
  drawMountains(horizonY);

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

public void drawMountains(int horizonY) {
  noFill();
  stroke(100); // Set the color for the mountains
  strokeWeight(2);

  for (int m = 0; m < numMountains; m++) {
    drawMountainRange(m, horizonY);
  }
}

public void drawMountainRange(int index, int horizonY) {
  float yOffset = map(index, 0, numMountains - 1, 50, 0);
  float opacity = map(index, 0, numMountains - 1, 255, 100);
  stroke(100, opacity);

  beginShape();
  vertex(0, horizonY);

  for (float x = 0; x <= canvasWidth; x += 10) {
    float noiseVal = noise(x * 0.003f + index);
    float y = map(noiseVal, 0, 1,
                  horizonY - baseHeight - yOffset,
                  horizonY - peakHeight - yOffset);

    // Add sharpness
    y = pow(y / canvasHeight, sharpness) * canvasHeight;
    // Add roughness
    y += random(-roughness, roughness);

    vertex(x, y);
  }

  vertex(canvasWidth, horizonY);
  endShape(CLOSE);
}

public void drawWater(int horizonY) {
  stroke(0);
  strokeWeight(2);
  noFill();

  int numLines = (int)map(waterDensity, 0, 0.01f, maxWaterLines * 10, minWaterLines);

  for (int i = 0; i < numLines; i++) {
    float yBase = map(pow(map(i, 0, numLines - 1, 0, 1), 2), 0, 1, horizonY, canvasHeight);
    float lineOffset = noise(i * 0.1f + waterSeed) * 20 - 10;

    float lineAmplitude = map(yBase, horizonY, canvasHeight, waterAmplitude * 0.1f, waterAmplitude);
    float lineFrequency = random(0.005f, 0.02f);
    float phaseOffset = random(TWO_PI);

    float segmentLength = map(yBase, horizonY, canvasHeight, waterLineLength * 0.1f, waterLineLength);
    float segmentStart = random(0, canvasWidth - segmentLength);
    float segmentEnd = segmentStart + segmentLength;

    float verticalSpacing = map(yBase, horizonY, canvasHeight, 5 * verticalSpacingFactor, 20 * verticalSpacingFactor);
    float y = yBase + lineOffset;

    if (y > horizonY && y < canvasHeight) {
      beginShape();
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
          stroke(255, 0, 0);
          strokeWeight(4);
        } else {
          stroke(0);
          strokeWeight(2);
        }

        vertex(px, finalY);
      }
      endShape();
    }
  }
}

// Update the exportSVG function
public void exportSVG() {
  String currentDateTime = new SimpleDateFormat("ddMMyy_HHmm").format(new Date());
  String filename = String.format("landscape_%04d_%s.svg", exportCounter++, currentDateTime);

  PGraphics pg = createGraphics(canvasWidth, canvasHeight, SVG, filename);
  pg.beginDraw();
  pg.background(255);

  pg.clip(0, 0, canvasWidth, canvasHeight);

  int horizonY = (int) (canvasHeight * horizonPosition);

  pg.scale(1, 1);
  pg.fill(200);
  pg.rect(0, 0, canvasWidth, horizonY);

  // Sun (Draw BEFORE mountains and water)
  if (sunY < horizonY) {
    pg.stroke(255, 0, 0);
    pg.fill(255, 255, 255);
    pg.strokeWeight(2);
    pg.ellipseMode(CENTER);
    pg.ellipse(sunX, sunY, sunSize * 2, sunSize * 2);
  }

  drawMountains(pg, horizonY);
  drawWater(pg, horizonY);

  pg.endDraw();
  pg.dispose();

  println("SVG exported: " + filename);
}

public void drawMountains(PGraphics pg, int horizonY) {
  pg.noFill();
  pg.stroke(100);
  pg.strokeWeight(2);

  for (int m = 0; m < numMountains; m++) {
    drawMountainRange(pg, m, horizonY);
  }
}

public void drawMountainRange(PGraphics pg, int index, int horizonY) {
  float yOffset = map(index, 0, numMountains - 1, 50, 0);
  float opacity = map(index, 0, numMountains - 1, 255, 100);
  pg.stroke(100, opacity);

  pg.beginShape();
  pg.vertex(0, horizonY);

  for (float x = 0; x <= canvasWidth; x += 10) {
    float noiseVal = noise(x * 0.003f + index);
    float y = map(noiseVal, 0, 1,
                  horizonY - baseHeight - yOffset,
                  horizonY - peakHeight - yOffset);

    y = pow(y / canvasHeight, sharpness) * canvasHeight;
    y += random(-roughness, roughness);

    pg.vertex(x, y);
  }

  pg.vertex(canvasWidth, horizonY);
  pg.endShape(CLOSE);
}

public void drawWater(PGraphics pg, int horizonY) {
  pg.stroke(0);
  pg.strokeWeight(2);
  pg.noFill();

  int numLines = (int)map(waterDensity, 0, 0.01f, maxWaterLines * 10, minWaterLines);

  for (int i = 0; i < numLines; i++) {
    float yBase = map(pow(map(i, 0, numLines - 1, 0, 1), 2), 0, 1, horizonY, canvasHeight);
    float lineOffset = noise(i * 0.1f + waterSeed) * 20 - 10;
    float lineAmplitude = map(yBase, horizonY, canvasHeight, waterAmplitude * 0.1f, waterAmplitude);
    float lineFrequency = random(0.005f, 0.02f);
    float phaseOffset = random(TWO_PI);
    float segmentLength = map(yBase, horizonY, canvasHeight, waterLineLength * 0.1f, waterLineLength);
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


  public void settings() { fullScreen();
smooth(); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "svg_landscape_generator" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}