import processing.svg.*;

PGraphics maskGraphics;
PImage maskImage;

void setup() {
  size(800, 600, SVG, "mountains.svg");
  noLoop(); // Draw only once
}

void draw() {
  background(255); // White background for SVG
  strokeWeight(1); // Set line thickness
  noFill();

  // Slightly curved base line
  beginShape();
  vertex(0, height * 0.8);
  bezierVertex(width * 0.25, height * 0.85, width * 0.75, height * 0.85, width, height * 0.8);
  endShape();

  // Base line detail
  decorateBaseLine(0, width, height * 0.8, height * 0.85);

  int numLayers = (int) random(3, 7);
  float layerStep = width / (numLayers + 1);

  // Store mountain shapes for clipping
  PShape[] mountainShapes = new PShape[numLayers];

  // Generate mountain shapes (without drawing yet)
  for (int i = numLayers - 1; i >= 0; i--) {
    mountainShapes[i] = createMountainLayerShape(i, numLayers, layerStep);
  }

  // Draw layers from back to front with clipping
  for (int i = numLayers - 1; i >= 0; i--) {
      // Create mask graphics
      maskGraphics = createGraphics(width, height);
      
      // Create a mask image from the PShape (except for the last/backmost layer)
      if (i < numLayers - 1) {
          maskImage = createMaskImage(mountainShapes[i]);
          
          // Apply the mask
          mask(maskImage);
      }
      

      // Draw the mountain layer using the pre-created shape
      shape(mountainShapes[i]);

      // Draw peak divisions and shading (now that we have proper clipping)
      drawMountainLayerDetails(i, numLayers, layerStep);

      // Reset by applying a fully opaque mask
      if (i < numLayers - 1) {
        PGraphics clearMask = createGraphics(width, height);
        clearMask.beginDraw();
        clearMask.background(255); // Fill with opaque white
        clearMask.endDraw();
        mask(clearMask.get());
      }
  }

  println("SVG export complete!");
}

PShape createMountainLayerShape(int layerIndex, int totalLayers, float layerStep) {
  float baseHeight = height * 0.8;
  float layerHeight = map(layerIndex, 0, totalLayers - 1, height * 0.5, height * 0.1);
  float xOffset = layerStep * (layerIndex + 1);
  xOffset += random(-layerStep * 0.2, layerStep * 0.2);

  // Correctly using baseY in the vertex calculations
  float baseY = bezierPoint(height * 0.8, height * 0.85, height * 0.85, height * 0.8, xOffset/width);

  int numPeaks = 1 + (int)random(2);
  float peakX = xOffset;
  float peakY = baseY - layerHeight;
  float peakHeightVariation = random(0.8, 1.2);
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
      y += random(-layerHeight * 0.05, layerHeight * 0.05);
      mountainShape.vertex(x, y);
    }
  }

  mountainShape.vertex(peakX, peakY);

  for (int p = 0; p < numPeaks; p++) {
    for (float x = peakX + (xOffset + layerHeight - peakX) / numPeaks * p; x < peakX + (xOffset + layerHeight - peakX) / numPeaks * (p + 1); x += random(5, 15)) {
      float y = map(x, peakX, xOffset + layerHeight, peakY, baseY);
      y += random(-layerHeight * 0.05, layerHeight * 0.05);
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

void drawMountainLayerDetails(int layerIndex, int totalLayers, float layerStep) {
  float baseHeight = height * 0.8;
  float layerHeight = map(layerIndex, 0, totalLayers - 1, height * 0.5, height * 0.1);
  float xOffset = layerStep * (layerIndex + 1);
  xOffset += random(-layerStep * 0.2, layerStep * 0.2);

  float baseY = bezierPoint(height * 0.8, height * 0.85, height * 0.85, height * 0.8, xOffset/width);

  int numPeaks = 1 + (int)random(2);
  float peakX = xOffset;
  float peakY = baseY - layerHeight;
  float peakHeightVariation = random(0.8, 1.2);
  peakY *= peakHeightVariation;

  // Main peak division
  drawPeakDivision(peakX, peakY, layerHeight, true);

  // Smaller bumps (on the sides of the main peak)
  addSmallerBumps(xOffset - layerHeight, peakX, baseY, peakY, layerHeight, true); // Left side
  addSmallerBumps(peakX, xOffset + layerHeight, peakY, baseY, layerHeight, false); // Right side
}

void drawPeakDivision(float x, float y, float mountainHeight, boolean isMainPeak) {
  float angle = random(0, PI/4); // 0 to 45 degrees
  float length = isMainPeak ? random(mountainHeight * 0.2, mountainHeight * 0.6) : random(mountainHeight * 0.1, mountainHeight * 0.2);

  float endX = x - cos(angle) * length;
  float endY = y + sin(angle) * length;

  // Draw the main division line with irregular segments
  for (float i = 0; i < length; i += random(3, 8)) {
    float startX = x - cos(angle) * i;
    float startY = y + sin(angle) * i;
    float nextI = min(i + random(3, 8), length);
    float nextX = x - cos(angle) * nextI;
    float nextY = y + sin(angle) * nextI;
    line(startX, startY, nextX, nextY);

    // Add accent lines on top
    if (isMainPeak && random(1) < 0.5) {
      float accentLength = random(5, 15);
      float accentAngle = angle + random(-PI/8, PI/8);
      float accentEndX = startX - cos(accentAngle) * accentLength;
      float accentEndY = startY + sin(accentAngle) * accentLength;
      line(startX, startY, accentEndX, accentEndY);
    }
  }

  // Shading on the left side
  if (isMainPeak) {
    addShading(x, y, endX, endY, mountainHeight);
  }
}

void addSmallerBumps(float startX, float endX, float startY, float endY, float mountainHeight, boolean isLeftSide) {
  for (float x = startX; x < endX; x += random(mountainHeight * 0.2, mountainHeight * 0.4)) {
    if (random(1) < 0.7) { // Probability of adding a bump
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

      drawPeakDivision(x, y, mountainHeight * 0.5, false); // Smaller division for bumps
    }
  }
}

void addShading(float startX, float startY, float endX, float endY, float mountainHeight) {
  float distance = dist(startX, startY, endX, endY);
  for (float i = 0; i < distance; i += random(mountainHeight * 0.05, mountainHeight * 0.15)) {
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
      line(x1, y1, x2, y2);
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
      float sketchLength = random(10, 30);
      beginShape();
      for (float i = 0; i < sketchLength; i++) {
        vertex(x + i, bezierPoint(startY, startY + (endY-startY)/2, startY + (endY-startY)/2, endY, (x+i) / width) + random(-2, 2));
      }
      endShape();
    }
  }
}
