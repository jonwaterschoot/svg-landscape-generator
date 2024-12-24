// ...existing code...

void setup() {
  fullScreen();
  // ...existing code...

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

// Update drawMountainRange and drawMountains functions to remove references to mountainAmplitude, mountainFrequency, and sharpness
void drawMountainRange() {
  // ...existing code...
  // Remove references to mountainAmplitude, mountainFrequency, and sharpness
  // ...existing code...
}

void drawMountains() {
  // ...existing code...
  // Remove references to mountainAmplitude, mountainFrequency, and sharpness
  // ...existing code...
}
