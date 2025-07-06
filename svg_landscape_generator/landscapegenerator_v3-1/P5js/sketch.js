// sketch.js - Instance Mode - Manual p.canvas Fix

const sketch = (p) => { // 'p' is the p5 instance

    // --- Canvas and Export Dimensions ---
    const canvasWidth = 4742; // For SVG export
    const canvasHeight = 3271; // For SVG export

    // --- Display Canvas Dimensions (smaller, for browser window) ---
    let sketchDisplayWidth;  // Renamed from displayWidth
    let sketchDisplayHeight; // Renamed from displayHeight
    const maxDisplayDim = 800; // Max dimension for the on-screen display canvas

    // --- Landscape Parameters ---
    let params = {
        horizonLineRatio: 0.5,
        sunRadius: 200,
        sunXPositionRatio: 0.5,
        sunYPositionSkyRatio: 0.3,
        mountainRoughness: 0.2,
        mountainPeakCount: 20,
        waterLineDensity: 80,
        reflectionIntensity: 0.7,
        cloudCount: 15,
        cloudComplexity: 5,
        cloudSize: 80,
    };

    // --- Noise seeds ---
    let mountainSeed;
    let cloudSeed;

    // --- GUI Elements ---
    let sliders = {};
    let valueSpans = {}; 

    // --- Variable for SVG export counter ---
    let exportCounter = 0;

    p.setup = () => {
        let aspectRatio = canvasWidth / canvasHeight;
        if (canvasWidth / canvasHeight > p.windowWidth / (p.windowHeight - 200)) { 
            sketchDisplayWidth = p.min(p.windowWidth - 40, maxDisplayDim * (canvasWidth/canvasHeight) ); 
            sketchDisplayHeight = sketchDisplayWidth / aspectRatio;
        } else {
            sketchDisplayHeight = p.min(p.windowHeight - 250, maxDisplayDim); 
            sketchDisplayWidth = sketchDisplayHeight * aspectRatio;
        }
        
        console.log("In p.setup(): About to call p.createCanvas().");
        let displayCanvasObject = p.createCanvas(sketchDisplayWidth, sketchDisplayHeight);
        console.log(`In p.setup(): p.createCanvas(${sketchDisplayWidth}, ${sketchDisplayHeight}) called.`);
        console.log("In p.setup(): Object returned by p.createCanvas():", displayCanvasObject);
        
        // --- Attempting manual assignment of p.canvas ---
        if (displayCanvasObject && displayCanvasObject.elt) {
            p.canvas = displayCanvasObject.elt; // Manually assign the canvas DOM element
            console.log("In p.setup(): Manually assigned displayCanvasObject.elt to p.canvas.");
        } else {
            console.warn("In p.setup(): displayCanvasObject.elt is not available for manual assignment.");
        }
        // --- End of manual assignment ---

        console.log("In p.setup(): p.canvas after p.createCanvas() (and potential manual assignment):", p.canvas);

        if(p.canvas && p.canvas.tagName) { // Check for tagName, a property of DOM elements
            console.log("In p.setup(): p.canvas exists and appears to be a DOM element. tagName:", p.canvas.tagName);
        } else {
            console.warn("In p.setup(): p.canvas does NOT appear to be a valid DOM element or is not what's expected. p.canvas:", p.canvas);
        }

        // Temporarily remove parenting to isolate canvas creation
        if (displayCanvasObject) { 
           try {
               displayCanvasObject.parent('canvas-container');
               console.log("In p.setup(): displayCanvas.parent('canvas-container') called.");
               console.log("In p.setup(): p.canvas AFTER displayCanvas.parent():", p.canvas);
                if(p.canvas && p.canvas.tagName) {
                   console.log("In p.setup(): p.canvas (after parent) exists and is DOM element:", p.canvas.tagName);
               } else {
                   console.warn("In p.setup(): p.canvas (after parent) does NOT appear to be a valid DOM element.");
               }
           } catch (e) {
               console.error("Error calling displayCanvas.parent():", e);
           }
        } else {
           console.warn("In p.setup(): displayCanvasObject from p.createCanvas() is null or undefined, cannot call .parent()");
        }


        mountainSeed = p.millis();
        cloudSeed = p.millis() + 1000;

        const controlsDiv = p.select('#controls'); 
        if (!controlsDiv) {
            console.warn("Could not find #controls div in HTML! GUI will not be created.");
        } else {
            function createSliderWithLabel(paramName, minVal, maxVal, step, labelText) {
                let controlItem = p.createDiv();
                controlItem.addClass('control-item');
                controlItem.parent(controlsDiv);

                let label = p.createSpan(labelText + ': ');
                label.parent(controlItem);
                label.style('margin-right', '10px');

                sliders[paramName] = p.createSlider(minVal, maxVal, params[paramName], step);
                sliders[paramName].parent(controlItem);
                sliders[paramName].style('flex-grow', '1'); 
                sliders[paramName].input(() => {
                    params[paramName] = sliders[paramName].value();
                    if (step === 1) {
                        params[paramName] = p.floor(params[paramName]);
                    }
                    if (valueSpans[paramName]) valueSpans[paramName].html(String(params[paramName])); 
                });
                
                valueSpans[paramName] = p.createSpan(String(params[paramName])); 
                valueSpans[paramName].parent(controlItem);
                valueSpans[paramName].style('min-width', '40px'); 
                valueSpans[paramName].style('text-align', 'right');
            }
            
            createSliderWithLabel('horizonLineRatio', 0.2, 0.8, 0.01, 'Horizon Line');
            createSliderWithLabel('sunRadius', 50, 800, 10, 'Sun Radius');
            // ... (rest of sliders)
            createSliderWithLabel('sunXPositionRatio', 0, 1, 0.01, 'Sun X Pos');
            createSliderWithLabel('sunYPositionSkyRatio', 0.1, 0.9, 0.01, 'Sun Y Sky Pos');
            createSliderWithLabel('mountainRoughness', 0.05, 0.8, 0.01, 'Mtn Roughness');
            createSliderWithLabel('mountainPeakCount', 3, 70, 1, 'Mtn Peaks');
            createSliderWithLabel('waterLineDensity', 10, 200, 1, 'Water Lines');
            createSliderWithLabel('reflectionIntensity', 0.1, 1.0, 0.01, 'Reflection');
            createSliderWithLabel('cloudCount', 0, 50, 1, 'Cloud Count');
            createSliderWithLabel('cloudComplexity', 3, 15, 1, 'Cloud Lines');
            createSliderWithLabel('cloudSize', 20, 200, 5, 'Cloud Size');


            let regenerateButton = p.createButton('Regenerate Art Style');
            regenerateButton.parent(controlsDiv);
            regenerateButton.mousePressed(() => {
                mountainSeed = p.millis();
                cloudSeed = p.millis() + 1000;
            });

            let exportButton = p.createButton('Export to SVG (Test)');
            exportButton.parent(controlsDiv);
            // Switch back to full SVG export if minimal test works with manual p.canvas
            exportButton.mousePressed(saveArtworkAsSVG); 
            // exportButton.mousePressed(saveArtworkAsSVG_MinimalTest); 
        }
        console.log("End of p.setup().");
    };

    p.draw = () => {
        p.background(220); 
        p.push(); 
        let scaleFactor = p.min(sketchDisplayWidth / canvasWidth, sketchDisplayHeight / canvasHeight);
        p.scale(scaleFactor); 
        drawSceneContent(p); 
        p.pop(); 
    };

    function drawSceneContent(pg) {
        let actualHorizonY = canvasHeight * params.horizonLineRatio;
        let actualSunX = canvasWidth * params.sunXPositionRatio;
        let skyHeight = actualHorizonY;
        let actualSunY = skyHeight * params.sunYPositionSkyRatio;

        pg.push(); 
        pg.background(255); 
        pg.stroke(0);       
        pg.strokeWeight(1.5); 

        pg.line(0, actualHorizonY, canvasWidth, actualHorizonY);
        drawSun(pg, actualSunX, actualSunY, params.sunRadius, actualHorizonY);
        drawSunReflection(pg, actualSunX, params.sunRadius, actualHorizonY, params.waterLineDensity, params.reflectionIntensity);
        drawMountains(pg, actualHorizonY, params.mountainPeakCount, params.mountainRoughness, mountainSeed);
        drawClouds(pg, actualHorizonY, params.cloudCount, params.cloudComplexity, params.cloudSize, cloudSeed);
        drawWaterLines(pg, actualHorizonY, params.waterLineDensity);
        pg.pop(); 
    }

    function drawSun(pg, sunX, sunY, r, horizonY) {
        pg.push(); 
        pg.noFill();
        pg.stroke(0);
        pg.strokeWeight(2);
        const segments = 100;
        if (sunY + r < 0 || sunY - r > horizonY) {
            pg.pop(); return;
        }
        if (sunY + r <= horizonY) { 
            pg.beginShape();
            for (let i = 0; i < segments; i++) {
                let angle = p.TWO_PI / segments * i; 
                let x = sunX + p.cos(angle) * r;    
                let y = sunY + p.sin(angle) * r;    
                pg.vertex(x, p.max(0, y));          
            }
            pg.endShape(p.CLOSE); 
            pg.pop(); return;
        }
        pg.beginShape();
        for (let i = 0; i <= segments; i++) {
            let angle1 = p.TWO_PI / segments * i;
            let x1 = sunX + p.cos(angle1) * r;
            let y1 = sunY + p.sin(angle1) * r;
            let angle2_candidate = p.TWO_PI / segments * (i + 1);
            let x2_candidate = sunX + p.cos(angle2_candidate) * r;
            let y2_candidate = sunY + p.sin(angle2_candidate) * r;
            let p1_visible_in_sky = y1 <= horizonY && y1 >= 0;
            if (p1_visible_in_sky) { pg.vertex(x1, y1); }
            let p2_candidate_visible_in_sky = y2_candidate <= horizonY && y2_candidate >= 0;
            if (p1_visible_in_sky !== (y2_candidate <= horizonY) && i < segments) {
                if (p.abs(y2_candidate - y1) > 0.0001) { 
                    let t = (horizonY - y1) / (y2_candidate - y1);
                    if (t >= 0 && t <= 1) {
                        let intersectX = x1 + t * (x2_candidate - x1);
                        pg.vertex(intersectX, horizonY);
                    }
                }
            }
            if ((y1 > 0 && y2_candidate < 0 || y1 < 0 && y2_candidate > 0) && i < segments) {
                if (p.abs(y2_candidate - y1) > 0.0001) {
                    let t = (0 - y1) / (y2_candidate - y1);
                    if (t > 0 && t < 1) {
                        let intersectX = x1 + t * (x2_candidate - x1);
                        if (y1 < 0 && p2_candidate_visible_in_sky) { pg.vertex(intersectX, 0); } 
                        else if (y1 >= 0 && y2_candidate < 0) { pg.vertex(intersectX, 0); }
                    }
                }
            }
        }
        pg.endShape(); pg.pop();
    }

    function drawSunReflection(pg, sunX, sunOriginalRadius, horizonY, density, intensity) {
        pg.push(); pg.stroke(0, 0, 0, 150); pg.strokeWeight(1.5);
        let waterHeight = canvasHeight - horizonY;
        if (waterHeight <= 0) { pg.pop(); return; }
        let maxReflectionWidth = sunOriginalRadius * 2 * intensity;
        for (let i = 0; i < density; i++) {
            let lineProgress = i / density; 
            let yPos = horizonY + p.pow(lineProgress, 1.5) * waterHeight; 
            yPos = p.min(yPos, canvasHeight - 5); 
            let lineLength = p.map(lineProgress, 0, 1, sunOriginalRadius * 0.1 * intensity, sunOriginalRadius * 1.5 * intensity); 
            lineLength = p.constrain(lineLength, 5, canvasWidth * 0.9); 
            let xStart = sunX - lineLength / 2; let xEnd = sunX + lineLength / 2;
            xStart = p.constrain(xStart, 0, canvasWidth); xEnd = p.constrain(xEnd, 0, canvasWidth);
            if (yPos > horizonY && yPos < canvasHeight && xStart < xEnd) {
                let breakChance = 0.3; 
                let segments = p.max(1, p.floor(lineLength / 50)); 
                let segmentLength = (xEnd - xStart) / segments;
                for(let j=0; j < segments; j++) {
                    if(p.random(1) > breakChance || segments === 1) { 
                        let segX1 = xStart + j * segmentLength;
                        let segX2 = xStart + (j+1) * segmentLength;
                        let yOffset = p.random(-1,1) * p.map(lineProgress, 0, 1, 1, 5); 
                        pg.line(segX1, yPos + yOffset, segX2, yPos + yOffset);
                    }
                }
            }
        }
        pg.pop();
    }

    function drawMountains(pg, horizonY, peakCount, roughness, seed) {
        pg.push(); pg.noFill(); pg.stroke(0); pg.strokeWeight(1.5); 
        p.noiseSeed(seed); 
        let mountainHeightVariation = canvasHeight * 0.15 * roughness; 
        let baseMountainHeight = canvasHeight * 0.05; 
        pg.beginShape(); pg.vertex(0, horizonY); 
        for (let i = 0; i <= peakCount; i++) {
            let x = p.map(i, 0, peakCount, 0, canvasWidth);
            let noiseXParam = x * 0.002 * (1.0 / p.max(0.1, roughness)); 
            let noiseYParam = roughness * 50 + i * 0.02; 
            let noiseVal = p.noise(noiseXParam, noiseYParam); 
            let peakHeight = p.map(noiseVal, 0, 1, -mountainHeightVariation, mountainHeightVariation);
            let y = horizonY - baseMountainHeight - peakHeight;
            y = p.max(y, canvasHeight * 0.02); y = p.min(y, horizonY);        
            pg.vertex(x, y);
        }
        pg.vertex(canvasWidth, horizonY); pg.endShape(); pg.pop();
    }

    function drawClouds(pg, horizonY, numClouds, complexity, avgSize, seed) {
        pg.push(); pg.stroke(0,0,0, 100); pg.strokeWeight(1);   
        // p.randomSeed(seed); // Using global p.random for clouds
        for (let i = 0; i < numClouds; i++) {
            let cloudBaseY = p.random(horizonY * 0.05, horizonY * 0.75); 
            let cloudX = p.random(canvasWidth * -0.1, canvasWidth * 1.1); 
            let sizeFactor = p.map(cloudBaseY, 0, horizonY, 1.5, 0.3); 
            let currentCloudSize = avgSize * sizeFactor * p.random(0.7, 1.3);
            currentCloudSize = p.max(currentCloudSize, 10); 
            let cx = cloudX; let cy = cloudBaseY;
            for (let j = 0; j < complexity; j++) {
                let angle = p.random(p.TWO_PI);
                let len = p.random(currentCloudSize * 0.2, currentCloudSize * 0.6);
                let x1 = cx + p.random(-currentCloudSize*0.3, currentCloudSize*0.3);
                let y1 = cy + p.random(-currentCloudSize*0.1, currentCloudSize*0.1);
                let x2 = x1 + p.cos(angle) * len; let y2 = y1 + p.sin(angle) * len;
                if (y1 < horizonY -2 && y2 < horizonY -2 && y1 > 2 && y2 > 2) { 
                   pg.line(x1, y1, x2, y2);
                }
            }
        }
        pg.pop();
    }

    function drawWaterLines(pg, horizonY, density) {
        pg.push(); pg.stroke(0, 0, 0, 200); pg.strokeWeight(1);
        let waterHeight = canvasHeight - horizonY;
        if (waterHeight <= 0) { pg.pop(); return; }
        // p.randomSeed(horizonY + density * 100 + waterHeight); // Using global p.random
        for (let i = 0; i < density; i++) {
            let progress = i / density; 
            let yPos = horizonY + p.pow(progress, 1.8) * waterHeight; 
            yPos = p.min(yPos, canvasHeight - 2); 
            let minLength = canvasWidth * 0.02; let maxLength = canvasWidth * 0.4; 
            let currentLength = p.map(p.pow(progress, 0.7), 0, 1, minLength, maxLength); 
            let xStart = p.random(0, canvasWidth - currentLength);
            let xEnd = xStart + currentLength;
            xStart = p.constrain(xStart, 0, canvasWidth); xEnd = p.constrain(xEnd, 0, canvasWidth);
            if (yPos > horizonY && yPos < canvasHeight && xStart < xEnd) {
                pg.line(xStart, yPos, xEnd, yPos);
            }
        }
        pg.pop();
    }
    
    function saveArtworkAsSVG_MinimalTest() {
        // This function is kept for focused testing if needed, but the main button now calls the full version.
        console.log("saveArtworkAsSVG_MinimalTest() called.");
        
        if (p.canvas && p.canvas.tagName) { // Check for tagName
            console.log("Main p.canvas is a DOM element. tagName:", p.canvas.tagName);
        } else {
            console.warn("Main p.canvas is NOT a DOM element or is undefined at SVG export attempt. p.canvas:", p.canvas);
        }

        let pgSVG;
        const svgTestWidth = 200;
        const svgTestHeight = 100;
        let filename = `test_svg_export_${exportCounter++}.svg`;

        try {
            console.log(`Attempting: pgSVG = p.createGraphics(${svgTestWidth}, ${svgTestHeight}, "svg");`);
            pgSVG = p.createGraphics(svgTestWidth, svgTestHeight, "svg");
            console.log("p.createGraphics for SVG call completed. pgSVG object:", pgSVG);

            if (pgSVG && typeof pgSVG.elt !== 'undefined' && pgSVG.elt.tagName.toLowerCase() === 'svg') { 
                console.log("SVG PGraphics object seems valid (has .elt and is an SVG element).");
                pgSVG.background(0, 255, 0); 
                pgSVG.fill(255, 0, 0);    
                pgSVG.rect(10, 10, 50, 30);
                console.log("Simple drawing on pgSVG completed.");
                p.save(pgSVG, filename);
                console.log(`Minimal SVG exported as ${filename}`);
            } else {
                console.error("Failed to create a valid SVG PGraphics object. pgSVG:", pgSVG, "pgSVG.elt:", (pgSVG ? pgSVG.elt : "N/A"));
            }
        } catch (err) {
            console.error("Error during minimal SVG export process:", err);
        }
    }

    function saveArtworkAsSVG() {
        console.log("saveArtworkAsSVG() function called (Full Version).");
        
        if (p.canvas && p.canvas.tagName) { // Check for tagName
            console.log("Main p.canvas is a DOM element. tagName:", p.canvas.tagName);
        } else {
            console.warn("Main p.canvas is NOT a DOM element or is undefined at SVG export attempt. p.canvas:", p.canvas);
            // If p.canvas is not correctly set, p5.svg.js might fail.
        }

        let date = new Date();
        let day = p.nf(date.getDate(), 2); 
        let month = p.nf(date.getMonth() + 1, 2);
        let year = p.str(date.getFullYear()).slice(-2); 
        let hours = p.nf(date.getHours(), 2);
        let minutes = p.nf(date.getMinutes(), 2);
        let seconds = p.nf(date.getSeconds(), 2);
        let exportCounterStr = p.nf(exportCounter, 4); 
        
        let filename = `landscape_p5_${day}${month}${year}_${hours}${minutes}${seconds}_${exportCounterStr}.svg`;
        let pgSVG;

        try {
            console.log(`Attempting to create SVG graphics: p.createGraphics(${canvasWidth}, ${canvasHeight}, "svg")`);
            pgSVG = p.createGraphics(canvasWidth, canvasHeight, "svg"); 
            console.log("SVG PGraphics object created (or attempted):", pgSVG); 

            // More robust check for a valid SVG PGraphics object from p5.svg.js
            if (pgSVG && typeof pgSVG.elt !== 'undefined' && pgSVG.elt.tagName && pgSVG.elt.tagName.toLowerCase() === 'svg' && typeof pgSVG.push === 'function') {
                console.log("SVG PGraphics object seems valid for drawing.");
            } else {
                console.error("Failed to create a valid SVG PGraphics object! Object:", pgSVG);
                if (pgSVG && pgSVG.elt) {
                    console.log("pgSVG.elt exists:", pgSVG.elt, "nodeName:", pgSVG.elt.nodeName);
                } else if (pgSVG) {
                    console.log("pgSVG.elt does NOT exist or pgSVG is not a Graphics object.");
                } else {
                    console.log("pgSVG itself is null or undefined.");
                }
                return; // Stop if SVG context isn't valid
            }

            drawSceneContent(pgSVG); 
            
            console.log("Drawing to SVG PGraphics finished.");
            p.save(pgSVG, filename); 
            console.log(`SVG exported as ${filename}`);
            exportCounter++; 

        } catch (err) {
            console.error("Error during SVG export process:", err);
        }
    }


    p.windowResized = () => {
        let aspectRatio = canvasWidth / canvasHeight;
         if (canvasWidth / canvasHeight > p.windowWidth / (p.windowHeight - 200)) {
            sketchDisplayWidth = p.min(p.windowWidth - 40, maxDisplayDim * (canvasWidth/canvasHeight) );
            sketchDisplayHeight = sketchDisplayWidth / aspectRatio;
        } else {
            sketchDisplayHeight = p.min(p.windowHeight - 250, maxDisplayDim);
            sketchDisplayWidth = sketchDisplayHeight * aspectRatio;
        }
        p.resizeCanvas(sketchDisplayWidth, sketchDisplayHeight);
    };
};

new p5(sketch);
