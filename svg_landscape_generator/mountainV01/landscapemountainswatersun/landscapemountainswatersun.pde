import processing.svg.*;
import controlP5.*;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

ControlP5 cp5;
PShape svg;
PGraphics maskGraphics;
PImage maskImage;

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
float waterDensity = 0.005; 
int minWaterLines = 50; 
int maxWaterLines = 200; 

// Water seed
float waterSeed = 0;
float waterLineLength = 200; 

// Water Noise parameters
float noiseScaleX = 0.02;
float noiseScaleY = 0.02;

// Sun parameters
float sunSize = 100;
float sunX = 200;
float sunY = 200;
float sunDiameter;

// Horizon position
float horizonPosition = 1.0 / 3.0; 

// --- Mountain parameters ---
int numLayers = 5;
float layerStep;
float baseHeightFactor = 0.8; 
float[] layerHeights; 

// Mountain Detail Parameters (For Controls)
float peakVariation = 0.2;
float bumpiness = 0.3; 
float mainDivisionLength = 0.4; 
float shadingDensity = 0.1;  
float roughness = 5;
float roughnessVariation = 0.5;
float lineSpacing = 5;

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
  noiseDetail(8, 0.5); 
  cp5 = new ControlP5(this);

  // Initialize layerHeights array
  layerHeights = new float[numLayers];
  layerStep = displayWidth / (numLayers + 1);
  for (int i = 0; i < numLayers; i++) {
    layerHeights[i] = map(i, 0, numLayers - 1, displayHeight * 0.5, displayHeight * 0.1);
  }

  // ControlP5 element dimensions and positioning 
  int cp5Width = 400;
  int cp5Height = 25;
  int cp5X = 20;
  int cp5YStart = 20;
  int cp5Spacing = 30; 

  // Water Sliders
  cp5.addSlider("waterDensity", 0.01, 0.0, waterDensity, cp5X, cp5YStart, cp5Width, cp5Height)
     .setLabel("Water Density")
     .setColorLabel(color(105))
     .onChange(e -> {
       waterDensity = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("waterAmplitude", 0, 100, waterAmplitude, cp5X, cp5YStart + cp5Spacing, cp5Width, cp5Height)
     .setLabel("Water Amplitude")
     .setColorLabel(color(105))
     .onChange(e -> {
       waterAmplitude = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("waterSeed", 0, 100, waterSeed, cp5X, cp5YStart + cp5Spacing * 2, cp5Width, cp5Height)
     .setLabel("Water Seed")
     .setColorLabel(color(105))
     .onChange(e -> {
       waterSeed = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("waterLineLength", 2, 800, waterLineLength, cp5X, cp5YStart + cp5Spacing * 3, cp5Width, cp5Height)
     .setLabel("Water Line Length")
     .setColorLabel(color(105))
     .onChange(e -> {
       waterLineLength = e.getController().getValue();
       drawScene();
     });

  // Sun Sliders
  cp5.addSlider("sunSize", 0, canvasWidth / 3, sunSize, cp5X, cp5YStart + cp5Spacing * 4, cp5Width, cp5Height)
     .setLabel("Sun Size")
     .setColorLabel(color(105))
     .onChange(e -> {
       sunSize = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("sunX", 0, canvasWidth, sunX, cp5X, cp5YStart + cp5Spacing * 5, cp5Width, cp5Height)
     .setLabel("Sun X Position")
     .setColorLabel(color(105))
     .onChange(e -> {
       sunX = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("sunY", 0, canvasHeight / 3, sunY, cp5X, cp5YStart + cp5Spacing * 6, cp5Width, cp5Height)
     .setLabel("Sun Y Position")
     .setColorLabel(color(105))
     .onChange(e -> {
       sunY = e.getController().getValue();
       drawScene();
     });

  // Horizon Slider
  cp5.addSlider("horizonPosition", 0, 1, horizonPosition, cp5X, cp5YStart + cp5Spacing * 7, cp5Width, cp5Height)
     .setLabel("Horizon Position")
     .setColorLabel(color(105))
     .onChange(e -> {
       horizonPosition = e.getController().getValue();
       drawScene();
     });

  // Mountain Sliders
  cp5.addSlider("numLayers", 1, 10).setValue(numLayers).setPosition(cp5X, cp5YStart + cp5Spacing * 8).setSize(cp5Width, cp5Height)
    .setLabel("Number of Mountain Layers")
    .setColorLabel(color(105))
    .onChange(e -> {
      numLayers = (int)e.getController().getValue();
      layerHeights = new float[numLayers];
      layerStep = displayWidth / (numLayers + 1);
      for (int i = 0; i < numLayers; i++) {
        layerHeights[i] = map(i, 0, numLayers - 1, displayHeight * 0.5, displayHeight * 0.1);
      }
      drawScene();
    });
  
  cp5.addSlider("peakVariation", 0, 1, peakVariation, cp5X, cp5YStart + cp5Spacing * 9, cp5Width, cp5Height)
    .setLabel("Peak Variation")
    .setColorLabel(color(105))
    .onChange(e -> {
      peakVariation = e.getController().getValue();
      drawScene();
    });

  cp5.addSlider("bumpiness", 0, 1, bumpiness, cp5X, cp5YStart + cp5Spacing * 10, cp5Width, cp5Height)
     .setLabel("Bumpiness")
     .setColorLabel(color(105))
     .onChange(e -> {
       bumpiness = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("mainDivisionLength", 0.2, 0.6, mainDivisionLength, cp5X, cp5YStart + cp5Spacing * 11, cp5Width, cp5Height)
     .setLabel("Main Division Length")
     .setColorLabel(color(105))
     .onChange(e -> {
       mainDivisionLength = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("shadingDensity", 0.05, 0.15, shadingDensity, cp5X, cp5YStart + cp5Spacing * 12, cp5Width, cp5Height)
     .setLabel("Shading Density")
     .setColorLabel(color(105))
     .onChange(e -> {
       shadingDensity = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("roughness", 0, 40, roughness, cp5X, cp5YStart + cp5Spacing * 13, cp5Width, cp5Height)
     .setLabel("Roughness")
     .setColorLabel(color(105))
     .onChange(e -> {
       roughness = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("roughnessVariation", 0, 1, roughnessVariation, cp5X, cp5YStart + cp5Spacing * 14, cp5Width, cp5Height)
     .setLabel("Roughness Variation")
     .setColorLabel(color(105))
     .onChange(e -> {
       roughnessVariation = e.getController().getValue();
       drawScene();
     });

  cp5.addSlider("lineSpacing", 1, 20, lineSpacing, cp5X, cp5YStart + cp5Spacing * 15, cp5Width, cp5Height)
     .setLabel("Line Spacing")
     .setColorLabel(color(105))
     .onChange(e -> {
       lineSpacing = e.getController().getValue();
       drawScene();
     });
       
  // Add the export SVG button
  cp5.addButton("exportSVG")
     .setLabel("Export to SVG")
     .setPosition(cp5X, cp5YStart + cp5Spacing * 16)
     .setSize(cp5Width, cp5Height)
     .onClick(e -> exportSVG());

  frameRate(15); 
  drawScene(); 
}

void draw() {
  // Empty draw function
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

  // Calculate horizon Y position
  int horizonY = (int) (canvasHeight * horizonPosition);

  // Sky
  fill(200);
  rect(0, 0, canvasWidth, horizonY);

  // Sun (Draw BEFORE mountains and water)
  if (sunY < horizonY) {
    stroke(255, 0, 0);
    fill(255, 255, 255);
    strokeWeight(2); 
    ellipseMode(CENTER);
    ellipse(sunX, sunY, sunSize * 2, sunSize * 2); 
  }

  // --- Mountainscape Drawing ---
  // Generate mountain shapes
  PShape[] mountainShapes = new PShape[numLayers];
  for (int i = numLayers - 1; i >= 0; i--) {
    mountainShapes[i] = createMountainLayerShape(i, numLayers, layerStep, horizonY);
  }

  // Draw mountains from back to front with clipping
  for (int i = numLayers - 1; i >= 0; i--) {
    // Create mask graphics
    maskGraphics = createGraphics(canvasWidth, canvasHeight);

    // Create a mask image (except for the last/backmost layer)
    if (i < numLayers - 1) {
      maskImage = createMaskImage(mountainShapes[i]);

      // Apply the mask
      mask(maskImage);
    }

    // Draw the mountain layer
    shape(mountainShapes[i]);

    // Draw peak divisions and shading
    drawMountainLayerDetails(i, numLayers, layerStep, horizonY, mountainShapes[i]);

    // Reset by applying a fully opaque mask
    if (i < numLayers - 1) {
      PGraphics clearMask = createGraphics(canvasWidth, canvasHeight);
      clearMask.beginDraw();
      clearMask.background(255); 
      clearMask.endDraw();
      mask(clearMask.get());
    }
  }

  // Water
drawWater(g, horizonY);

  // Remove clipping
  noClip();

  if (svg != null) {
    endRecord();
    svg = null; 
  }

  // Draw ControlP5 elements *after* scaling is reset
  if (svg == null) { 
    resetMatrix(); 
    cp5.draw();
  }
}

PShape createMountainLayerShape(int layerIndex, int totalLayers, float layerStep, int horizonY) {
  float layerHeight = map(layerIndex, 0, totalLayers - 1, displayHeight * 0.5, displayHeight * 0.1);
  float xOffset = layerStep * (layerIndex + 1);
  xOffset += random(-layerStep * peakVariation, layerStep * peakVariation);

  float baseY = bezierPoint(horizonY, horizonY + (displayHeight - horizonY) / 2, horizonY + (displayHeight - horizonY) / 2, displayHeight, xOffset / displayWidth);

  int numPeaks = 1 + (int)random(2);
  float peakX = xOffset;
  float peakY = baseY - layerHeight;
  float peakHeightVariation = random(1 - peakVariation, 1 + peakVariation);
  peakY *= peakHeightVariation;

  // Create a PShape for the mountain
  PShape mountainShape = createShape();
  mountainShape.beginShape();
  mountainShape.stroke(0);
  mountainShape.noFill();
  mountainShape.vertex(xOffset - layerHeight, baseY);

 // Using numPeaks to add more vertices along the mountain outline
  for (int p = 0; p < numPeaks; p++) {
    for (float x = xOffset - layerHeight + (peakX - (xOffset - layerHeight)) / numPeaks * p; x < xOffset - layerHeight + (peakX - (xOffset - layerHeight)) / numPeaks * (p + 1); x += random(5, 15)) {
      float y = map(x, xOffset - layerHeight, peakX, baseY, peakY);
      y += random(-layerHeight * bumpiness, layerHeight * bumpiness);

      // Introduce more variation based on numPeaks
      if(p % 2 == 0){
        y += random(-layerHeight * peakVariation, layerHeight * peakVariation);
      } else {
        y -= random(-layerHeight * peakVariation, layerHeight * peakVariation);
      }

      // Add roughness
      if (random(1) < roughnessVariation) {
        y += random(-roughness, roughness);
      }

      mountainShape.vertex(x, y);
    }
  }

  mountainShape.vertex(peakX, peakY);

  for (int p = 0; p < numPeaks; p++) {
    for (float x = peakX + (xOffset + layerHeight - peakX) / numPeaks * p; x < peakX + (xOffset + layerHeight - peakX) / numPeaks * (p + 1); x += random(5, 15)) {
      float y = map(x, peakX, xOffset + layerHeight, peakY, baseY);
      y += random(-layerHeight * bumpiness, layerHeight * bumpiness);

      // Introduce more variation based on numPeaks
      if(p % 2 == 0){
        y += random(-layerHeight * peakVariation, layerHeight * peakVariation);
      } else {
        y -= random(-layerHeight * peakVariation, layerHeight * peakVariation);
      }

      // Add roughness
      if (random(1) < roughnessVariation) {
        y += random(-roughness, roughness);
      }

      mountainShape.vertex(x, y);
    }
  }
  mountainShape.vertex(xOffset + layerHeight, baseY);
  mountainShape.endShape(CLOSE);

  return mountainShape;
}

PImage createMaskImage(PShape shape) {
  // Draw the shape onto the mask image with white fill
  maskGraphics.beginDraw();
  maskGraphics.clear();
  maskGraphics.noStroke();
  maskGraphics.fill(255); // White color for the mask
  maskGraphics.shape(shape, 0, 0);
  maskGraphics.endDraw();

  maskImage = maskGraphics.get();

  return maskImage;
}

void drawMountainLayerDetails(int layerIndex, int totalLayers, float layerStep, int horizonY, PShape mountainShape) {
  // Get the bounds of the mountain shape
  float minX = mountainShape.getVertexX(0);
  float maxX = mountainShape.getVertexX(0);
  float minY = mountainShape.getVertexY(0);
  float maxY = mountainShape.getVertexY(0);
  for (int i = 1; i < mountainShape.getVertexCount(); i++) {
    float x = mountainShape.getVertexX(i);
    float y = mountainShape.getVertexY(i);
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
  }
  
  float layerHeight = map(layerIndex, 0, totalLayers - 1, displayHeight * 0.5, displayHeight * 0.1);
  float xOffset = layerStep * (layerIndex + 1);
  xOffset += random(-layerStep * peakVariation, layerStep * peakVariation);

  float baseY = bezierPoint(horizonY, horizonY + (displayHeight - horizonY) / 2, horizonY + (displayHeight - horizonY) / 2, displayHeight, xOffset / displayWidth);

  int numPeaks = 1 + (int)random(2);
  float peakX = xOffset;
  float peakY = baseY - layerHeight;
  float peakHeightVariation = random(1 - peakVariation, 1 + peakVariation);
  peakY *= peakHeightVariation;

  // Main peak division
  drawPeakDivision(peakX, peakY, layerHeight, true, minX, maxX, minY, maxY);

  // Smaller bumps (on the sides of the main peak)
  addSmallerBumps(xOffset - layerHeight, peakX, baseY, peakY, layerHeight, true, minX, maxX, minY, maxY); // Left side
  addSmallerBumps(peakX, xOffset + layerHeight, peakY, baseY, layerHeight, false, minX, maxX, minY, maxY); // Right side
}

void drawPeakDivision(float x, float y, float mountainHeight, boolean isMainPeak, float minX, float maxX, float minY, float maxY) {
  float angle = random(0, PI/4); // 0 to 45 degrees
  float length = isMainPeak ? random(mountainHeight * 0.2, mountainHeight * mainDivisionLength) : random(mountainHeight * 0.1, mountainHeight * 0.2);

  float endX = x - cos(angle) * length;
  float endY = y + sin(angle) * length;

  // Draw the main division line with irregular segments
  for (float i = 0; i < length; i += random(3, 8)) {
    float startX = x - cos(angle) * i;
    float startY = y + sin(angle) * i;
    float nextI = min(i + random(3, 8), length);
    float nextX = x - cos(angle) * nextI;
    float nextY = y + sin(angle) * nextI;
    
    if (startX >= minX && startX <= maxX && startY >= minY && startY <= maxY) {
        line(startX, startY, nextX, nextY);
    }

    // Add accent lines on top
    if (isMainPeak && random(1) < 0.5) {
      float accentLength = random(5, 15);
      float accentAngle = angle + random(-PI/8, PI/8);
      float accentEndX = startX - cos(accentAngle) * accentLength;
      float accentEndY = startY + sin(accentAngle) * accentLength;
      
      if (startX >= minX && startX <= maxX && startY >= minY && startY <= maxY) {
          line(startX, startY, accentEndX, accentEndY);
      }
    }
  }

  // Shading on the left side
  if (isMainPeak) {
    addShading(x, y, endX, endY, mountainHeight, minX, maxX, minY, maxY);
  }
}

void addSmallerBumps(float startX, float endX, float startY, float endY, float mountainHeight, boolean isLeftSide, float minX, float maxX, float minY, float maxY) {
  for (float x = startX; x < endX; x += random(mountainHeight * 0.2, mountainHeight * 0.4)) {
    if (random(1) < bumpiness) { // Probability of adding a bump based on bumpiness
      float bumpHeight = random(mountainHeight * 0.1, mountainHeight * 0.3);
      float y;
      if (isLeftSide) {
        y = map(x, startX, endX, startY, endY) - bumpHeight;
      } else {
        y = map(x, startX, endX, startY, endY) - bumpHeight;
      }

      // Draw a small bump using a curve
      float bumpWidth = bumpHeight * random(1, 2);

      beginShape();

      if (isLeftSide) {
        vertex(x - bumpWidth, map(x, startX, endX, startY, endY));
        bezierVertex(x - bumpWidth/2, map(x, startX, endX, startY, endY) - bumpHeight/4, x- bumpWidth/4, y - bumpHeight/2, x, y - bumpHeight/2);
        vertex(x, y - bumpHeight/2);
        bezierVertex(x + bumpWidth/4, y - bumpHeight/2, x + bumpWidth/2, map(x, startX, endX, startY, endY) - bumpHeight/4, x + bumpWidth, map(x, startX, endX, startY, endY));
        vertex(x+bumpWidth, map(x, startX, endX, startY, endY));
      } else {
        vertex(x - bumpWidth, map(x, startX, endX, startY, endY));
        bezierVertex(x - bumpWidth/2, map(x, startX, endX, startY, endY) - bumpHeight/4, x- bumpWidth/4, y - bumpHeight/2, x, y - bumpHeight/2);
        vertex(x, y - bumpHeight/2);
        bezierVertex(x + bumpWidth/4, y - bumpHeight/2, x + bumpWidth/2, map(x, startX, endX, startY, endY) - bumpHeight/4, x + bumpWidth, map(x, startX, endX, startY, endY));
        vertex(x+bumpWidth, map(x, startX, endX, startY, endY));
      }

      endShape();

      drawPeakDivision(x, y, mountainHeight * 0.5, false, minX, maxX, minY, maxY); // Smaller division for bumps
    }
  }
}

void addShading(float startX, float startY, float endX, float endY, float mountainHeight, float minX, float maxX, float minY, float maxY) {
  float distance = dist(startX, startY, endX, endY);
  for (float i = 0; i < distance; i += random(mountainHeight * shadingDensity, mountainHeight * shadingDensity * 3)) {
    float x = lerp(startX, endX, i / distance);
    float y = lerp(startY, endY, i / distance);
    float shadeLength = random(mountainHeight * 0.1, mountainHeight * 0.4);
    float angle = random(-PI / 12, PI / 12) - PI / 2; // Mostly vertical, slightly tilted

    // Draw shading lines with slight variations
    for (int j = 0; j < shadeLength; j += random(2, 5)) {
      float x1 = x + cos(angle) * j + random(-2, 2);
      float y1 = y + sin(angle) * j + random(-2, 2);
      float x2 = x + cos(angle) * (j + random(2, 5)) + random(-2, 2);
      float y2 = y + sin(angle) * (j + random(2, 5)) + random(-2, 2);
      
      // Check if the shading lines are within the mountain's bounds
      if (x1 >= minX && x1 <= maxX && y1 >= minY && y1 <= maxY && x2 >= minX && x2 <= maxX && y2 >= minY && y2 <= maxY) {
          line(x1, y1, x2, y2);
      }
    }
  }
}

void drawWater(PGraphics pg, int horizonY) {
  pg.stroke(0);
  pg.strokeWeight(2);
  pg.noFill();

  int numLines = (int)map(waterDensity, 0, 0.01, maxWaterLines * 10, minWaterLines);

  for (int i = 0; i < numLines; i++) {
    float yBase = map(pow(map(i, 0, numLines - 1, 0, 1), 2), 0, 1, horizonY, canvasHeight);
    // Ensure the input range for map() is valid
    if (horizonY == canvasHeight) {
      yBase = horizonY;
    }
    float lineOffset = noise(i * 0.1f + waterSeed) * 20 - 10;
    float lineAmplitude = map(yBase, horizonY, canvasHeight, waterAmplitude * 0.1, waterAmplitude);
    float lineFrequency = random(0.005, 0.02);
    float phaseOffset = random(TWO_PI);
    float segmentLength = map(yBase, horizonY, canvasHeight, waterLineLength * 0.1, waterLineLength);
    float segmentStart = random(0, canvasWidth - segmentLength);
    float segmentEnd = segmentStart + segmentLength;
    float y = yBase + lineOffset;

    if (y > horizonY && y < canvasHeight) {
      pg.beginShape();
      for (float px = segmentStart; px < segmentEnd; px += 1) {
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


void decorateBaseLine(float startX, float endX, float startY, float endY) {
  for (float x = startX; x < endX; x += random(5, 15)) {
    float y = bezierPoint(startY, startY + (endY-startY)/2, startY + (endY-startY)/2, endY, x / width); // Follow the curve
    y += random(-5, 5); // Add small variations

    // Small squiggles
    if (random(1) < 0.3) {
      beginShape();
      for (int i = 0; i < 5; i++) {
        vertex(x + i * 2, y + random(-3, 3));
      }
      endShape();
    }

    // Short vertical lines
    if (random(1) < 0.2) {
      line(x, y, x, y + random(5, 10));
    }

    // Sketched lines following the curve
    if (random(1) < 0.5) {
        float sketchLength = random(10,30);
        beginShape();
        for(float i = 0; i < sketchLength; i++){
          vertex(x + i, bezierPoint(startY, startY + (endY-startY)/2, startY + (endY-startY)/2, endY, (x+i) / width) + random(-2,2));
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
  
  // --- Mountainscape Drawing ---
  // Generate mountain shapes
  PShape[] mountainShapes = new PShape[numLayers];
  for (int i = numLayers - 1; i >= 0; i--) {
    mountainShapes[i] = createMountainLayerShape(i, numLayers, layerStep, horizonY);
  }

  // Draw mountains from back to front with clipping
  for (int i = numLayers - 1; i >= 0; i--) {
    // Create mask graphics
    maskGraphics = createGraphics(canvasWidth, canvasHeight);

    // Create a mask image from the PShape (except for the last/backmost layer)
    if (i < numLayers - 1) {
      maskImage = createMaskImage(mountainShapes[i]);

      // Apply the mask
      pg.mask(maskImage);
    }

    // Draw the mountain layer using the pre-created shape
    pg.shape(mountainShapes[i]);

    // Draw peak divisions and shading (now that we have proper clipping)
    drawMountainLayerDetailsSVG(pg, i, numLayers, layerStep, horizonY, mountainShapes[i]);

    // Reset by applying a fully opaque mask
    if (i < numLayers - 1) {
      PGraphics clearMask = createGraphics(canvasWidth, canvasHeight);
      clearMask.beginDraw();
      clearMask.background(255); // Fill with opaque white
      clearMask.endDraw();
      pg.mask(clearMask.get());
    }
  }

  drawWater(pg, horizonY);

  pg.endDraw();
  pg.dispose();

  println("SVG exported: " + filename);
}

void drawMountainLayerDetailsSVG(PGraphics pg, int layerIndex, int totalLayers, float layerStep, int horizonY, PShape mountainShape) {
  // Get the bounds of the mountain shape
  float minX = mountainShape.getVertexX(0);
  float maxX = mountainShape.getVertexX(0);
  float minY = mountainShape.getVertexY(0);
  float maxY = mountainShape.getVertexY(0);
  for (int i = 1; i < mountainShape.getVertexCount(); i++) {
    float x = mountainShape.getVertexX(i);
    float y = mountainShape.getVertexY(i);
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
  }
  
  float layerHeight = map(layerIndex, 0, totalLayers - 1, displayHeight * 0.5, displayHeight * 0.1);
  float xOffset = layerStep * (layerIndex + 1);
  xOffset += random(-layerStep * peakVariation, layerStep * peakVariation);

  float baseY = bezierPoint(horizonY, horizonY + (displayHeight - horizonY) / 2, horizonY + (displayHeight - horizonY) / 2, displayHeight, xOffset / displayWidth);

  int numPeaks = 1 + (int)random(2);
  float peakX = xOffset;
  float peakY = baseY - layerHeight;
  float peakHeightVariation = random(1 - peakVariation, 1 + peakVariation);
  peakY *= peakHeightVariation;

  // Main peak division
  drawPeakDivisionSVG(pg, peakX, peakY, layerHeight, true, minX, maxX, minY, maxY);

  // Smaller bumps (on the sides of the main peak)
  addSmallerBumpsSVG(pg, xOffset - layerHeight, peakX, baseY, peakY, layerHeight, true, minX, maxX, minY, maxY); // Left side
  addSmallerBumpsSVG(pg, peakX, xOffset + layerHeight, peakY, baseY, layerHeight, false, minX, maxX, minY, maxY); // Right side
}

void drawPeakDivisionSVG(PGraphics pg, float x, float y, float mountainHeight, boolean isMainPeak, float minX, float maxX, float minY, float maxY) {
  float angle = random(0, PI/4); // 0 to 45 degrees
  float length = isMainPeak ? random(mountainHeight * 0.2, mountainHeight * mainDivisionLength) : random(mountainHeight * 0.1, mountainHeight * 0.2);

  float endX = x - cos(angle) * length;
  float endY = y + sin(angle) * length;

  // Draw the main division line with irregular segments
  for (float i = 0; i < length; i += random(3, 8)) {
    float startX = x - cos(angle) * i;
    float startY = y + sin(angle) * i;
    float nextI = min(i + random(3, 8), length);
    float nextX = x - cos(angle) * nextI;
    float nextY = y + sin(angle) * nextI;
    
    if (startX >= minX && startX <= maxX && startY >= minY && startY <= maxY) {
        pg.line(startX, startY, nextX, nextY);
    }

    // Add accent lines on top
    if (isMainPeak && random(1) < 0.5) {
      float accentLength = random(5, 15);
      float accentAngle = angle + random(-PI/8, PI/8);
      float accentEndX = startX - cos(accentAngle) * accentLength;
      float accentEndY = startY + sin(accentAngle) * accentLength;
      
      if (startX >= minX && startX <= maxX && startY >= minY && startY <= maxY) {
          pg.line(startX, startY, accentEndX, accentEndY);
      }
    }
  }

  // Shading on the left side
  if (isMainPeak) {
    addShadingSVG(pg, x, y, endX, endY, mountainHeight, minX, maxX, minY, maxY);
  }
}

void addSmallerBumpsSVG(PGraphics pg, float startX, float endX, float startY, float endY, float mountainHeight, boolean isLeftSide, float minX, float maxX, float minY, float maxY) {
  for (float x = startX; x < endX; x += random(mountainHeight * 0.2, mountainHeight * 0.4)) {
    if (random(1) < bumpiness) { // Probability of adding a bump based on bumpiness
      float bumpHeight = random(mountainHeight * 0.1, mountainHeight * 0.3);
      float y;
      if (isLeftSide) {
        y = map(x, startX, endX, startY, endY) - bumpHeight;
      } else {
        y = map(x, startX, endX, startY, endY) - bumpHeight;
      }

      // Draw a small bump using a curve
      float bumpWidth = bumpHeight * random(1, 2);

      pg.beginShape();

      if (isLeftSide) {
        pg.vertex(x - bumpWidth, map(x, startX, endX, startY, endY));
        pg.bezierVertex(x - bumpWidth/2, map(x, startX, endX, startY, endY) - bumpHeight/4, x- bumpWidth/4, y - bumpHeight/2, x, y - bumpHeight/2);
        pg.vertex(x, y - bumpHeight/2);
        pg.bezierVertex(x + bumpWidth/4, y - bumpHeight/2, x + bumpWidth/2, map(x, startX, endX, startY, endY) - bumpHeight/4, x + bumpWidth, map(x, startX, endX, startY, endY));
        pg.vertex(x+bumpWidth, map(x, startX, endX, startY, endY));
      } else {
        pg.vertex(x - bumpWidth, map(x, startX, endX, startY, endY));
        pg.bezierVertex(x - bumpWidth/2, map(x, startX, endX, startY, endY) - bumpHeight/4, x- bumpWidth/4, y - bumpHeight/2, x, y - bumpHeight/2);
        pg.vertex(x, y - bumpHeight/2);
        pg.bezierVertex(x + bumpWidth/4, y - bumpHeight/2, x + bumpWidth/2, map(x, startX, endX, startY, endY) - bumpHeight/4, x + bumpWidth, map(x, startX, endX, startY, endY));
        pg.vertex(x+bumpWidth, map(x, startX, endX, startY, endY));
      }

      pg.endShape();

      drawPeakDivisionSVG(pg, x, y, mountainHeight * 0.5, false, minX, maxX, minY, maxY); // Smaller division for bumps
    }
  }
}

void addShadingSVG(PGraphics pg, float startX, float startY, float endX, float endY, float mountainHeight, float minX, float maxX, float minY, float maxY) {
  float distance = dist(startX, startY, endX, endY);
  for (float i = 0; i < distance; i += random(mountainHeight * shadingDensity, mountainHeight * shadingDensity * 3)) {
    float x = lerp(startX, endX, i / distance);
    float y = lerp(startY, endY, i / distance);
    float shadeLength = random(mountainHeight * 0.1, mountainHeight * 0.4);
    float angle = random(-PI / 12, PI / 12) - PI / 2; // Mostly vertical, slightly tilted

    // Draw shading lines with slight variations
    for (int j = 0; j < shadeLength; j += random(2, 5)) {
      float x1 = x + cos(angle) * j + random(-2, 2);
      float y1 = y + sin(angle) * j + random(-2, 2);
      float x2 = x + cos(angle) * (j + random(2, 5)) + random(-2, 2);
      float y2 = y + sin(angle) * (j + random(2, 5)) + random(-2, 2);
      
      // Check if the shading lines are within the mountain's bounds
      if (x1 >= minX && x1 <= maxX && y1 >= minY && y1 <= maxY && x2 >= minX && x2 <= maxX && y2 >= minY && y2 <= maxY) {
          pg.line(x1, y1, x2, y2);
      }
    }
  }
}
