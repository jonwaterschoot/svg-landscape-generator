
import controlP5.*;
ControlP5 cp5;

void setup() {
  
  size(800, 600);
  cp5 = new ControlP5(this);
  
  cp5.addSlider("baseHeight")
     .setPosition(20, 20)
     .setRange(50, 200)
     .setValue(100);
     
  cp5.addSlider("peakHeight")
     .setPosition(20, 40)
     .setRange(50, 300)
     .setValue(150);
     
  cp5.addSlider("roughness")
     .setPosition(20, 60)
     .setRange(0, 20)
     .setValue(5);
     
  cp5.addSlider("sharpness")
     .setPosition(20, 80)
     .setRange(0.5, 2)
     .setValue(1);
}
// Mountain generation parameters
float baseHeight;      // Base height of mountains
float peakHeight;      // Maximum height of peaks
float roughness;       // Roughness of the mountain surface
float sharpness;       // Controls how pointed the peaks are
int numMountains = 3;  // Number of mountain ranges


void draw() {
  background(255);
  
  // Draw multiple mountain ranges
  for (int m = 0; m < numMountains; m++) {
    drawMountainRange(m);
  }
  
  // Uncomment for SVG export
  // exit();
}

void drawMountainRange(int index) {
  float yOffset = map(index, 0, numMountains-1, 50, 0);
  float opacity = map(index, 0, numMountains-1, 255, 100);
  
  beginShape();
  // Start from left bottom
  vertex(0, height);
  
  // Generate mountain points
  for (float x = 0; x <= width; x += 10) {
    float noiseVal = noise(x * 0.003 + index, frameCount * 0.001);
    float y = map(noiseVal, 0, 1, 
                  height - baseHeight - yOffset,
                  height - baseHeight - peakHeight - yOffset);
    
    // Add sharpness
    y = pow(y/height, sharpness) * height;
    // Add roughness
    y += random(-roughness, roughness);
    
    vertex(x, y);
  }
  
  // Complete the shape
  vertex(width, height);
  endShape(CLOSE);
}
