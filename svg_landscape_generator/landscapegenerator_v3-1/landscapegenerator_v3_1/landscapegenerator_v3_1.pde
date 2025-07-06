// begin code template
import processing.svg.*; // Import the SVG library for exporting
import controlP5.*;     // Import the ControlP5 library for GUI elements
import java.io.File;    // Import File class
import java.text.SimpleDateFormat; // Import SimpleDateFormat for date formatting
import java.util.Date;    // Import Date class

ControlP5 cp5;          // Declare a ControlP5 object
PGraphics sceneBuffer;  // Global PGraphics to hold the artwork

// Variables for incremental file naming
int exportCounter = 0;

// --- Canvas and Display Dimensions ---
int canvasWidth = 4742;
int canvasHeight = 3271;
int displayWidth;
int displayHeight;

// --- Landscape Parameters ---
float horizonLineRatio = 0.5;
float sunRadius = 200;
float sunXPositionRatio = 0.5;
float sunYPositionSkyRatio = 0.3;
float mountainRoughness = 0.2;
int   mountainPeakCount = 20;
int   waterLineDensity = 80;
float reflectionIntensity = 0.7; 
int   cloudCount = 15;
int   cloudComplexity = 5;
float cloudSize = 80;

// Noise seeds for mountains and clouds
long mountainSeed;
long cloudSeed;

void setup() {
  fullScreen();

  float aspectRatio = (float)canvasWidth / canvasHeight;
  if ((float)width / height > aspectRatio) {
    displayHeight = height;
    displayWidth = (int)(height * aspectRatio);
  } else {
    displayWidth = width;
    displayHeight = (int)(width / aspectRatio);
  }

  smooth();
  cp5 = new ControlP5(this);

  // Initialize the scene buffer
  sceneBuffer = createGraphics(canvasWidth, canvasHeight);

  mountainSeed = millis();
  cloudSeed = millis() + 1000;

  // --- ControlP5 Setup ---
  int cp5Width = 350;
  int cp5Height = 20;
  int cp5X = 20;
  int cp5YStart = 20;
  int cp5Spacing = 30;
  int currentY = cp5YStart;

  cp5.addSlider("horizonLineRatio")
    .setLabel("Horizon Line (0.2-0.8)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(0.2, 0.8)
    .setValue(horizonLineRatio)
    .setColorLabel(color(255)) 
    .setColorValueLabel(color(255)) 
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10); 
  currentY += cp5Spacing;

  cp5.addSlider("sunRadius")
    .setLabel("Sun Radius (50-800)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(50, 800)
    .setValue(sunRadius)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addSlider("sunXPositionRatio")
    .setLabel("Sun X Position (0-1)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(0.0, 1.0)
    .setValue(sunXPositionRatio)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addSlider("sunYPositionSkyRatio")
    .setLabel("Sun Y Sky Pos (0.1-0.9)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(0.1, 0.9)
    .setValue(sunYPositionSkyRatio)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addSlider("mountainRoughness")
    .setLabel("Mtn Roughness (0.05-0.8)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(0.05, 0.8)
    .setValue(mountainRoughness)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addSlider("mountainPeakCount")
    .setLabel("Mtn Peaks (3-70)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(3, 70)
    .setNumberOfTickMarks(68)
    .setSliderMode(Slider.FIX)
    .setValue(mountainPeakCount)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addSlider("waterLineDensity")
    .setLabel("Water Lines (10-200)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(10, 200)
    .setNumberOfTickMarks(191)
    .setSliderMode(Slider.FIX)
    .setValue(waterLineDensity)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addSlider("reflectionIntensity")
    .setLabel("Reflection (0.1-1.0)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(0.1, 1.0)
    .setValue(reflectionIntensity)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addSlider("cloudCount")
    .setLabel("Cloud Count (0-50)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(0, 50)
    .setNumberOfTickMarks(51)
    .setSliderMode(Slider.FIX)
    .setValue(cloudCount)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addSlider("cloudComplexity")
    .setLabel("Cloud Lines (3-15)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(3, 15)
    .setNumberOfTickMarks(13)
    .setSliderMode(Slider.FIX)
    .setValue(cloudComplexity)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;
  
  cp5.addSlider("cloudSize")
    .setLabel("Cloud Size (20-200)")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width, cp5Height)
    .setRange(20, 200)
    .setValue(cloudSize)
    .setColorLabel(color(255))
    .setColorValueLabel(color(255))
    .setColorForeground(color(100, 150, 255))
    .setColorActive(color(150, 200, 255))
    .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(10);
  currentY += cp5Spacing;

  cp5.addButton("regenerateArt")
    .setLabel("Regenerate Art Style")
    .setPosition(cp5X, currentY)
    .setSize(cp5Width/2 - 5, cp5Height)
    .onClick(e -> {
      mountainSeed = millis();
      cloudSeed = millis() + 1000;
      drawScene(); 
    });

  cp5.addButton("exportButton") 
    .setLabel("Export to SVG")
    .setPosition(cp5X + cp5Width/2 + 5, currentY)
    .setSize(cp5Width/2 - 5, cp5Height)
    .onClick(event -> { 
      println("Export to SVG button clicked. Event: " + event + " Counter before export: " + exportCounter);
      saveArtworkAsSVG(); 
    });
  currentY += cp5Spacing;

  String[] paramNames = {
    "horizonLineRatio", "sunRadius", "sunXPositionRatio", "sunYPositionSkyRatio",
    "mountainRoughness", "mountainPeakCount", "waterLineDensity",
    "reflectionIntensity", "cloudCount", "cloudComplexity", "cloudSize"
  };
  for (String paramName : paramNames) {
    cp5.getController(paramName).onChange(e -> {
      drawScene(); 
    });
  }

  frameRate(30); 
  drawScene(); 
}

void draw() {
  background(200); 

  if (sceneBuffer != null) {
    float scaleFactor = min((float)displayWidth / canvasWidth, (float)displayHeight / canvasHeight);
    float drawW = canvasWidth * scaleFactor;
    float drawH = canvasHeight * scaleFactor;
    float drawX = (width - drawW) / 2; 
    float drawY = (height - drawH) / 2;
    image(sceneBuffer, drawX, drawY, drawW, drawH);
  }
  
  cp5.draw(); 
}


void drawScene() {
  if (sceneBuffer == null) { 
    println("Error: sceneBuffer is null in drawScene!");
    sceneBuffer = createGraphics(canvasWidth, canvasHeight); 
  }

  float actualHorizonY = canvasHeight * horizonLineRatio;
  float actualSunX = canvasWidth * sunXPositionRatio;
  float skyHeight = actualHorizonY; 
  float actualSunY = skyHeight * sunYPositionSkyRatio;

  sceneBuffer.beginDraw();
  sceneBuffer.background(255); 
  sceneBuffer.stroke(0);
  sceneBuffer.strokeWeight(1.5);
  
  sceneBuffer.line(0, actualHorizonY, canvasWidth, actualHorizonY); 
  drawSun(sceneBuffer, actualSunX, actualSunY, sunRadius, actualHorizonY);
  drawSunReflection(sceneBuffer, actualSunX, sunRadius, actualHorizonY, waterLineDensity, reflectionIntensity);
  drawMountains(sceneBuffer, actualHorizonY, mountainPeakCount, mountainRoughness, mountainSeed);
  drawClouds(sceneBuffer, actualHorizonY, cloudCount, cloudComplexity, cloudSize, cloudSeed);
  drawWaterLines(sceneBuffer, actualHorizonY, waterLineDensity);
  
  sceneBuffer.endDraw();
}

// --- Helper: Draw Sun (handles clipping at horizon) ---
void drawSun(PGraphics pg, float sunX, float sunY, float r, float horizonY) {
  pg.pushStyle();
  pg.noFill();
  pg.stroke(0);
  pg.strokeWeight(2);

  int segments = 100;

  if (sunY + r < 0 || sunY - r > horizonY) { 
    pg.popStyle();
    return;
  }

  if (sunY + r <= horizonY) { 
    pg.beginShape();
    for (int i = 0; i < segments; i++) {
      float angle = TWO_PI / segments * i;
      float x = sunX + cos(angle) * r;
      float y = sunY + sin(angle) * r;
      pg.vertex(x, max(0, y)); 
    }
    pg.endShape(CLOSE);
    pg.popStyle();
    return;
  }

  pg.beginShape();
  for (int i = 0; i <= segments; i++) {
    float angle1 = TWO_PI / segments * i;
    float x1 = sunX + cos(angle1) * r;
    float y1 = sunY + sin(angle1) * r;

    float angle2_candidate = TWO_PI / segments * (i + 1);
    float x2_candidate = sunX + cos(angle2_candidate) * r;
    float y2_candidate = sunY + sin(angle2_candidate) * r;
    
    boolean p1_visible_in_sky = y1 <= horizonY && y1 >=0; 

    if (p1_visible_in_sky) {
      pg.vertex(x1, y1);
    }

    boolean p2_candidate_visible_in_sky = y2_candidate <= horizonY && y2_candidate >=0; // Check if next point is in sky

    // If segment crosses horizon (one point above/on, one below, within sky vertically)
    if (p1_visible_in_sky != (y2_candidate <= horizonY) && i < segments) { 
        if (abs(y2_candidate - y1) > 0.0001) { 
            float t = (horizonY - y1) / (y2_candidate - y1);
            if (t >= 0 && t <= 1) { 
                float intersectX = x1 + t * (x2_candidate - x1);
                pg.vertex(intersectX, horizonY);
            }
        }
    }
     // If segment crosses top of canvas (y=0)
    if ((y1 > 0 && y2_candidate < 0 || y1 < 0 && y2_candidate > 0) && i < segments) {
        if (abs(y2_candidate - y1) > 0.0001) {
            float t = (0 - y1) / (y2_candidate - y1); // t for y=0
            if (t > 0 && t < 1) { 
                float intersectX = x1 + t * (x2_candidate - x1);
                // If p1 was above canvas (y1<0) and p2 is on canvas, add intersection then p2 (if visible)
                if (y1 < 0 && p2_candidate_visible_in_sky) {
                     pg.vertex(intersectX, 0);
                     // pg.vertex(x2_candidate, y2_candidate); // p2 will be added in next iteration if visible
                } 
                // If p1 was on canvas (y1>=0) and p2 is above canvas (y2_candidate<0), add intersection
                else if (y1 >= 0 && y2_candidate < 0) {
                     pg.vertex(intersectX, 0);
                }
            }
        }
    }
  }
  pg.endShape(); 
  pg.popStyle();
}


// --- Helper: Draw Sun Reflection ---
void drawSunReflection(PGraphics pg, float sunX, float sunOriginalRadius, float horizonY, int density, float intensity) {
  pg.pushStyle();
  pg.stroke(0, 0, 0, 150); 
  pg.strokeWeight(1.5);

  float waterHeight = canvasHeight - horizonY;
  if (waterHeight <= 0) {
    pg.popStyle();
    return;
  }
  
  randomSeed((long)(sunX + horizonY + intensity * 1000 + sunOriginalRadius)); 

  float maxReflectionWidth = sunOriginalRadius * 2 * intensity;

  for (int i = 0; i < density; i++) {
    float lineProgress = (float)i / density; 
    
    float yPos = horizonY + pow(lineProgress, 1.5f) * waterHeight; 
    yPos = min(yPos, canvasHeight - 5);

    float lineLength = map(lineProgress, 0, 1, sunOriginalRadius * 0.1f * intensity, sunOriginalRadius * 1.5f * intensity);
    lineLength = constrain(lineLength, 5, canvasWidth * 0.9f);

    float xStart = sunX - lineLength / 2;
    float xEnd = sunX + lineLength / 2;

    xStart = constrain(xStart, 0, canvasWidth);
    xEnd = constrain(xEnd, 0, canvasWidth);
    
    if (yPos > horizonY && yPos < canvasHeight && xStart < xEnd) {
      float breakChance = 0.3; 
      int segments = max(1, int(lineLength / 50)); 
      float segmentLength = (xEnd - xStart) / segments;

      for(int j=0; j<segments; j++) {
        if(random(1) > breakChance || segments == 1) { 
          float segX1 = xStart + j * segmentLength;
          float segX2 = xStart + (j+1) * segmentLength;
          float yOffset = random(-1,1) * map(lineProgress, 0, 1, 1, 5); 
          pg.line(segX1, yPos + yOffset, segX2, yPos + yOffset);
        }
      }
    }
  }
  pg.popStyle();
}

// --- Helper: Draw Mountains ---
void drawMountains(PGraphics pg, float horizonY, int peakCount, float roughness, long seed) {
  pg.pushStyle();
  pg.noFill();
  pg.stroke(0);
  pg.strokeWeight(1.5); 

  noiseSeed(seed); 

  float mountainHeightVariation = canvasHeight * 0.15 * roughness; 
  float baseMountainHeight = canvasHeight * 0.05; 

  pg.beginShape();
  pg.vertex(0, horizonY); 

  for (int i = 0; i <= peakCount; i++) {
    float x = map(i, 0, peakCount, 0, canvasWidth);
    float noiseXParam = x * 0.002 * (1.0f / max(0.1f, roughness)); 
    float noiseYParam = roughness * 50 + i * 0.02f; 
    float noiseVal = noise(noiseXParam, noiseYParam);
    
    float peakHeight = map(noiseVal, 0, 1, -mountainHeightVariation, mountainHeightVariation);
    float y = horizonY - baseMountainHeight - peakHeight;
    y = max(y, canvasHeight * 0.02f); 
    y = min(y, horizonY);        
    pg.vertex(x, y);
  }

  pg.vertex(canvasWidth, horizonY); 
  pg.endShape(); 
  pg.popStyle();
}


// --- Helper: Draw Clouds ---
void drawClouds(PGraphics pg, float horizonY, int numClouds, int complexity, float avgSize, long seed) {
  pg.pushStyle();
  pg.stroke(0,0,0, 100); 
  pg.strokeWeight(1);   

  randomSeed(seed); 

  for (int i = 0; i < numClouds; i++) {
    float cloudBaseY = random(horizonY * 0.05f, horizonY * 0.75f); 
    float cloudX = random(canvasWidth * -0.1f, canvasWidth * 1.1f); 

    float sizeFactor = map(cloudBaseY, 0, horizonY, 1.5f, 0.3f); 
    float currentCloudSize = avgSize * sizeFactor * random(0.7f, 1.3f);
    currentCloudSize = max(currentCloudSize, 10); 

    float cx = cloudX;
    float cy = cloudBaseY;

    for (int j = 0; j < complexity; j++) {
      float angle = random(TWO_PI);
      float len = random(currentCloudSize * 0.2f, currentCloudSize * 0.6f);
      float x1 = cx + random(-currentCloudSize*0.3f, currentCloudSize*0.3f);
      float y1 = cy + random(-currentCloudSize*0.1f, currentCloudSize*0.1f);
      float x2 = x1 + cos(angle) * len;
      float y2 = y1 + sin(angle) * len;
      
      if (y1 < horizonY -2 && y2 < horizonY -2 && y1 > 2 && y2 > 2) { 
         pg.line(x1, y1, x2, y2);
      }
    }
  }
  pg.popStyle();
}

// --- Helper: Draw general Water Lines ---
void drawWaterLines(PGraphics pg, float horizonY, int density) {
  pg.pushStyle();
  pg.stroke(0, 0, 0, 200); 
  pg.strokeWeight(1);

  float waterHeight = canvasHeight - horizonY;
  if (waterHeight <= 0) {
    pg.popStyle();
    return;
  }
  
  randomSeed((long)(horizonY + density * 100 + waterHeight)); 

  for (int i = 0; i < density; i++) {
    float progress = (float)i / density; 
    float yPos = horizonY + pow(progress, 1.8f) * waterHeight; 
    yPos = min(yPos, canvasHeight - 2); 

    float minLength = canvasWidth * 0.02f; 
    float maxLength = canvasWidth * 0.4f; 
    float currentLength = map(pow(progress, 0.7f), 0, 1, minLength, maxLength); 

    float xStart = random(0, canvasWidth - currentLength);
    float xEnd = xStart + currentLength;
    
    xStart = constrain(xStart, 0, canvasWidth);
    xEnd = constrain(xEnd, 0, canvasWidth);

    if (yPos > horizonY && yPos < canvasHeight && xStart < xEnd) {
      pg.line(xStart, yPos, xEnd, yPos);
    }
  }
  pg.popStyle();
}

// --- Renamed Export SVG Function with Error Handling and Simplification ---
void saveArtworkAsSVG() {
  println("saveArtworkAsSVG() function called. Current exportCounter: " + exportCounter);
  String currentDateTime = new SimpleDateFormat("ddMMyy_HHmmss").format(new Date());
  // Using "test" in filename to indicate it's from this debugging version
  String filename = String.format("landscape_test_%s_%04d.svg", currentDateTime, exportCounter);
  String fullPath = sketchPath(filename);

  println("Attempting to create PGraphics SVG object for: " + fullPath);
  PGraphics pgSVG = null;

  try {
    pgSVG = createGraphics(canvasWidth, canvasHeight, SVG, fullPath);
    println("PGraphics SVG object creation attempted.");

    if (pgSVG == null) {
      println("CRITICAL ERROR: createGraphics returned null for SVG. Cannot proceed with drawing to SVG.");
      // No further action possible with pgSVG if it's null
      return;
    }
    println("PGraphics SVG object seems to be created (not null).");

    pgSVG.beginDraw();
    println("pgSVG.beginDraw() called.");
    
    // Added clip command, similar to user's old sketch
    pgSVG.clip(0, 0, canvasWidth, canvasHeight);
    println("pgSVG.clip(0, 0, canvasWidth, canvasHeight) called.");


    // pgSVG.clear(); // REMOVED this line as it caused NullPointerException
    // println("pgSVG.clear() was here, now removed."); // Logging the removal

    pgSVG.stroke(0); // Black stroke
    pgSVG.strokeWeight(1.5); // Default stroke weight for the scene
    // pgSVG.line(10, 10, canvasWidth - 10, canvasHeight - 10); // Simple test line - KEEP COMMENTED for now
    // println("Simple diagonal line drawn to pgSVG."); // KEEP COMMENTED for now
    
    // STEP 2: Restore drawing code piece by piece
    
    float actualHorizonY = canvasHeight * horizonLineRatio;
    float actualSunX = canvasWidth * sunXPositionRatio;
    float skyHeight = actualHorizonY;
    float actualSunY = skyHeight * sunYPositionSkyRatio;

    println("Drawing complex scene to pgSVG...");
    pgSVG.line(0, actualHorizonY, canvasWidth, actualHorizonY); // Horizon
    println("Horizon drawn to pgSVG.");

    drawSun(pgSVG, actualSunX, actualSunY, sunRadius, actualHorizonY);
    println("Sun drawn to pgSVG.");
    
    drawSunReflection(pgSVG, actualSunX, sunRadius, actualHorizonY, waterLineDensity, reflectionIntensity);
    println("Sun reflection drawn to pgSVG.");

    drawMountains(pgSVG, actualHorizonY, mountainPeakCount, mountainRoughness, mountainSeed); 
    println("Mountains drawn to pgSVG.");

    drawClouds(pgSVG, actualHorizonY, cloudCount, cloudComplexity, cloudSize, cloudSeed);       
    println("Clouds drawn to pgSVG.");

    drawWaterLines(pgSVG, actualHorizonY, waterLineDensity); 
    println("Water lines drawn to pgSVG.");
    
    println("Complex scene drawing to pgSVG finished.");
    

    pgSVG.endDraw();
    println("pgSVG.endDraw() called.");

    println("Attempting pgSVG.dispose()...");
    pgSVG.dispose(); 
    println("pgSVG.dispose() completed.");

    println("SVG (test) successfully exported: " + fullPath);
    exportCounter++; 
  } catch (Exception e) {
    println("!!!!!!!!!! JAVA EXCEPTION CAUGHT IN saveArtworkAsSVG !!!!!!!!!!!!!");
    e.printStackTrace(System.out); 
  } catch (Error err) {
    println("!!!!!!!!!! JAVA ERROR CAUGHT IN saveArtworkAsSVG !!!!!!!!!!!!!");
    err.printStackTrace(System.out);
  } finally {
    println("Exiting saveArtworkAsSVG function (finally block).");
  }
}

void exit() {
  println("Sketch exit() method called."); 
  super.exit();
}
