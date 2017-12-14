public class AnimatedChart {
  
  /////////////////////
  // Class Variables
  /////////////////////
  
  public Point[] data;
  private ArrayList<String> dataHeaders;
  private String xLabel, yLabel;
  private float yMax = 0;
  private float total = 0;
  private int currentDataHeaderIndex = 0;
  
  float w, h;

  private float flattenedBar = 0;
  private float animTheta = 0;
  private float movedPosition = 0;
  private boolean animating = false;
  private boolean firstTime = true;
  private int startFrame, endFrame;
  private float startPercentage, targetPercentage, currentPercentage;
  private Animation currentAnimation;
  
  private ArrayList<Animation> animations = new ArrayList<Animation>();
  private ArrayList<ChartType> animationQueue = new ArrayList<ChartType>();
  
  private int labelWidth = 50;
  
  AnimatedChart(Point[] data, String xLabel, String yLabel, ArrayList<String> dataHeaders) {
    
    // Setup the data, headers, and labels
    this.data = data;
    this.xLabel = xLabel;
    this.yLabel = yLabel; 
    this.dataHeaders = dataHeaders;
    
    this.calculateDataStats();
    
    // Add all the possible animations with callbacks
    animations.add(new Animation(ChartType.LINECHART, ChartType.BARCHART, 5.0, new AnimationMethod() {
      void call(float percent) {
        renderLineToBarAnimation(percent);
      }
    }));
    animations.add(new Animation(ChartType.BARCHART, ChartType.PIECHART, 9.0, new AnimationMethod() {
      void call(float percent) {
        renderBarToPieAnimation(percent);
      }
    }));
    
    // Set the first animatio to the current animation
    this.currentAnimation = animations.get(0);
    this.currentPercentage = this.currentAnimation.percentage(this.currentAnimation.from);
  }
  
  void calculateDataStats() {
    // Calculate the data total and maximum 
    this.yMax = 0;
    for (int i = 0; i < this.data.length; i++) {
      
      this.total += this.data[i].y(this.currentDataHeaderIndex);
      this.yMax = max(this.data[i].y(this.currentDataHeaderIndex), this.yMax);
    }
  }
  
  ArrayList<String> getDataHeaders() {
    return this.dataHeaders;
  }
  
  void setCurrentDataHeader(String header) {
    this.currentDataHeaderIndex = this.dataHeaders.indexOf(header);
  }
  
  /////////////////////
  // Animation Setup
  /////////////////////
  
  Animation getAnimation(ChartType previous, ChartType current) {
    for (Animation animation: this.animations) {
      if (animation.isAnimationFor(previous, current)) {
        return animation; 
      }
    }
    
    return null;
  }
  
  ArrayList<Animation> getAnimationsForChartType(ChartType type, Animation exclude) {
    ArrayList<Animation> list = new ArrayList<Animation>();
    for (Animation animation: this.animations) {
      if (animation != exclude && animation.includesChartType(type)) {
        list.add(animation);
      }
    }
    
    return list;
  }
  
  ArrayList<ChartType> findPath(ChartType from, ChartType to, Animation prev) {
    ArrayList<ChartType> list = new ArrayList<ChartType>();
    
    ArrayList<Animation> potentialAnimations = this.getAnimationsForChartType(from, prev);
    if (potentialAnimations.isEmpty()) {
      return list; 
    }
    
    for (Animation animation: potentialAnimations) {
      ChartType next = animation.getOtherChartType(from);
      
      // Base Case
      if (next == to) {
        list = new ArrayList<ChartType>();
        list.add(next);
        return list;
      }
      
      ArrayList<ChartType> potentialList = this.findPath(next, to, animation);
      if (potentialList.isEmpty()) {
        continue; 
      }
      potentialList.add(0, next);
      if (list.isEmpty() || potentialList.size() < list.size()) {
        list = potentialList;
      }
    }
    
    return list;
  }
  
  boolean animateToChartType(ChartType newChart) {
    
    ChartType curr = this.currentAnimation.type(this.targetPercentage);
    
    if (newChart == curr || newChart == null || this.animating) {
      return false; 
    }
    
    ArrayList<ChartType> path = this.findPath(curr, newChart, null);
    if (path.isEmpty()) {
      println("No possible animation: skipping"); 
      return false; 
    }
    
    this.performAnimation(path.remove(0));
    this.animationQueue.clear();
    this.animationQueue.addAll(path);
    
    return true;
  }
  
  boolean performAnimation(ChartType newChart) {
    ChartType curr = this.currentAnimation.type(this.targetPercentage);
    Animation animation = this.getAnimation(curr, newChart);
        
    if (newChart == curr || newChart == null || this.animating) {
      return false; 
    }
    
    // No possible animation -> do not animate
    if (animation == null) {
      return false;
    }
    
    // Set animating
    this.animating = true;
    this.startFrame = frameCount;
    this.endFrame = round(this.startFrame + (frameRate * animation.getTime())); // 5 seconds
    
    this.startPercentage = animation.percentage(curr);
    this.targetPercentage = animation.percentage(newChart);
    this.currentAnimation = animation;
    
    return true;
  }
  
  
  
  boolean isAnimating() {
    return this.animating; 
  }
  
  void animate() {
    int frameDiff = this.endFrame - this.startFrame;
    float percentDone = min((float)(frameCount - this.startFrame) / frameDiff, 1);
    this.currentPercentage = percentDone;
    float percentDiff = this.targetPercentage - this.startPercentage;
    this.currentPercentage = this.startPercentage + (percentDone * percentDiff);
    if (this.currentPercentage == this.targetPercentage) {
      this.endAnimation(); 
    }
  }
  
  void endAnimation() {
    this.animating = false; 
    if (!this.animationQueue.isEmpty()) {
      this.performAnimation(this.animationQueue.remove(0)); 
    }
  }

  void render(float x, float y, float w, float h) {
    if (this.animating) {
      this.animate(); 
    }
    
    this.w = w; //<>//
    this.h = h;
    fill(255);
    
    pushMatrix();
    translate(x, y);
    this.currentAnimation.renderAnimation.call(this.currentPercentage);
    popMatrix();
  }
  
  /////////////////////
  // Animation Helper Functions
  /////////////////////
  
   DimensionScale getLabeledAxes(float w, float h) {
    return new DimensionScale(w, h, this.yMax, this.data.length, this.labelWidth); 
  }
  
  void drawLabeledAxes(DimensionScale ds) {
    
    translate(ds.xLabelWidth, 0);
    // Draw the outside border
    rect(0, 0, ds.w, ds.h);
    
    fill(0);
    
    // Draw the Y Axis Labels
    float range = this.yMax;
    int tickCount = 10;
    float unroundedTickSize = range/(tickCount-1);
    float x = ceil((log(unroundedTickSize)-log(10))-1);
    float pow10x = pow(10, x);
    float roundedTickRange = ceil(unroundedTickSize / pow10x) * pow10x;
    
    textAlign(RIGHT, CENTER);
    textSize(12);
    
    float curr = 0;
    while (curr < this.yMax) {
      float currY = this.yMax - curr;
      line(-5, currY * ds.yScale, 5, currY * ds.yScale);
      text(nf(curr, 0, 1), -this.labelWidth, (currY * ds.yScale) - 10, this.labelWidth - 7, 20);
      curr += roundedTickRange;
    }
    
    // Draw the x axis
    for (int i = 0; i < this.data.length; i++) {
      
      // Get the current point's coordinates
      float pointX = (i+1) * ds.xScale;
      
      // Draw the x axis tick mark
      float scaledYMax = this.yMax * ds.yScale;
      line(pointX, scaledYMax - 5, pointX, scaledYMax + 5);
      
      // Draw the x axis labels
      
      pushMatrix();
      translate(pointX, ds.h);
      rotate(PI/-2.0);
      text(this.data[i].x, -this.labelWidth, -10, this.labelWidth - 7, 20);
      popMatrix();
    }
  }
  
  float percentDone(float curr, float low, float high) {
    return (constrain(curr, low, high) - low)/ (high - low);
  }

  float getBarWidth(float xScale) {
    return min(xScale-10, 20); 
  }
  
  private boolean hoveringOverArc(float mouseRadius, float mouseAngle, float diameter, float startAngle, float endAngle) {
    // Check if the mouse is within the donut radius. If not, return false immediately
    if (mouseRadius < (diameter/2) && mouseAngle < endAngle && mouseAngle > startAngle) { //<>//
      return true;
    }
    return false;
  }

  /////////////////////
  // Animations
  /////////////////////
  
  void renderLineToBarAnimation(float percent) {
    DimensionScale ds = getLabeledAxes(this.w, this.h);
    this.drawLabeledAxes(ds);

    for (int i = 0; i < this.data.length; i++) {
        
      float pointX = (i+1) * ds.xScale;
      float pointY = (this.yMax-this.data[i].y(this.currentDataHeaderIndex)) * ds.yScale;
            
      // Draw connecting line to the next point if not the last point
      if (i < this.data.length - 1 && percent < 0.3) {
        float stagePercent = 1 - percentDone(percent, 0, 0.3);
        float nextX = (i+2) * ds.xScale;
        float nextY = (this.yMax-this.data[i+1].y(this.currentDataHeaderIndex)) * ds.yScale;
        
        PVector connector = new PVector(nextX - pointX, nextY - pointY);
        connector.mult(stagePercent);
        
        // Draw the connecting line
        
        line(pointX, pointY, pointX + connector.x, pointY + connector.y);
      }
     
      // Draw the point!
      float pointSize = (1 - this.percentDone(percent, 0.3, 0.6)) * 10;
      
      fill(123, 48, 99);
      ellipse(pointX, pointY, pointSize, pointSize);
      
      if (percent < 0.6) {
        float barWidth = this.getBarWidth(ds.xScale) * this.percentDone(percent, 0.3, 0.6);
        line(pointX - (barWidth/2), pointY, pointX + (barWidth/2), pointY);
      } else {
        float stagePercent = this.percentDone(percent, 0.6, 1.0);
        float barWidth = this.getBarWidth(ds.xScale);
        float scaledYMax = this.yMax * ds.yScale;
        pushMatrix();
        translate(pointX, 0);
        rect(-barWidth/2, pointY, barWidth, (scaledYMax - pointY) * stagePercent);
        popMatrix();
      }
    } 
  }
  
  void renderBarToPieAnimation(float percent) {
    DimensionScale ds = this.getLabeledAxes(this.w, this.h);
    if (percent == 1.0 && firstTime) {
       percent = .99999999;
       firstTime = false;
    }
    
    if (percent == 0) {
      this.drawLabeledAxes(ds); 
      
    } else if (percent == 1.0) {
      this.renderPieChart(ds);
      firstTime = true;
      return; 
    }
    boolean changing = true;
    for (int i = 0; i < this.data.length; i++) { 
      fill(123, 48, 99);
      
      float pointX = (i+1) * ds.xScale;
      float pointY = (this.yMax-this.data[i].y(this.currentDataHeaderIndex)) * ds.yScale;
      float barWidth = this.getBarWidth(ds.xScale);
      float scaledYMax = this.yMax * ds.yScale;
      float diameter = min(this.w, this.h);
      float y = (this.h/2);
      
      if (i < this.data.length && percent < 0.2) {
        float stagePercent = this.percentDone(percent, 0, 0.4);
        
        
        if (percent < 0.00001) {
          pushMatrix();
          translate(pointX, 0);        
          rect(-barWidth/2, pointY, barWidth - barWidth * stagePercent, (scaledYMax - pointY));
          popMatrix();
          if (changing && percent >  0.000001) {
              background(255);
              changing = false;
          }
        } else {
          pushMatrix();
          translate(pointX, 0);        
          rect(-barWidth/2 + 2.7 * barWidth, pointY, barWidth - barWidth * stagePercent, (scaledYMax - pointY));
          popMatrix();
        }
        flattenedBar = barWidth - barWidth * stagePercent;
        
      } else if (percent < 0.4 ) {
        float stagePercent = this.percentDone(percent, 0.2, 0.4);
        
        pushMatrix();
        translate(pointX, 0);
        rect(-barWidth/2 + 2.7 * barWidth - stagePercent * i * 15 , pointY, flattenedBar, (scaledYMax - pointY));
        popMatrix();
        movedPosition = stagePercent * 15;
      } else if (percent < .8) {
        float stagePercent = this.percentDone(percent, 0.4, 0.8);
        float arcTheta = (this.data[i].y(this.currentDataHeaderIndex)/this.total) * TWO_PI;
        float x = (this.w/2) + 180;
        
        pushMatrix();
        translate(pointX, 0);
        rect(-barWidth/2 + 2.7 * barWidth - movedPosition * i, pointY, flattenedBar, (scaledYMax - pointY) - (scaledYMax - pointY) * stagePercent);
        popMatrix();
        strokeWeight(1);
        arc(x, y, diameter * stagePercent, diameter * stagePercent, animTheta, (animTheta + arcTheta));  
        animTheta += arcTheta;
      } else {
        float stagePercent = this.percentDone(percent, 0.8, 1.0);
        float x = (this.w/2) + 180 - 180 * stagePercent;
        float arcTheta = (this.data[i].y(this.currentDataHeaderIndex)/this.total) * TWO_PI;
        
        strokeWeight(1);
        arc(x, y, diameter, diameter, animTheta, (animTheta + arcTheta));  
        animTheta += arcTheta;
      }
    }
  }
  
  void renderPieChart(DimensionScale ds) {
    float diameter = min(this.w, this.h);
    float x = (this.w/2);
    float y = (this.h/2);
    
    strokeWeight(1);
    
    float currTheta = 0;
    boolean shouldDisplayText = false;
    String hoverText = "";
    
    for (int i = 0; i < this.data.length; i++) {
      
      // Draw the pie
      float arcTheta = (this.data[i].y(this.currentDataHeaderIndex)/this.total) * TWO_PI;
      float mouseRadius = sqrt(pow((mouseX - x), 2) + pow((mouseY - y), 2));
      float mouseAngle = atan2((mouseY-y), (mouseX - x));

      if (mouseAngle < 0) {
        mouseAngle += TWO_PI; 
      }
      
      // Check if the current slice is being hovered over and fill appropriately
      boolean hovering = this.hoveringOverArc(mouseRadius, mouseAngle, diameter, currTheta, currTheta + arcTheta);
      if (hovering) {
        fill(100); 
      } else {
        fill(123, 48, 99);
      }

      // Draw the slice
      arc(x, y, diameter, diameter, currTheta, currTheta + arcTheta, PIE);
     
      
      // Set the hover text if necessary
      if (hovering) {
        hoverText = this.data[i].x + " -> " + nf(this.data[i].y(this.currentDataHeaderIndex));
      }
      shouldDisplayText |= hovering;
      
      
      currTheta += arcTheta;
     
    }
    
    // Display the hover text after all the slices have been drawn
    if (shouldDisplayText) {
      fill(255);
      textSize(25);
      
      text(hoverText, mouseX, mouseY-30); 
    }
  }
}
  
class DimensionScale {
  public float w;
  public float h;
  public float xScale;
  public float yScale;
  public float xLabelWidth;
  public float yLabelWidth;
  
  DimensionScale(float w, float h, float dataMax, float dataLength, float labelWidth) {
    this.xLabelWidth = this.getLabelWidth(w, labelWidth);
    this.yLabelWidth = this.getLabelWidth(h, labelWidth);
    
    this.w = w-xLabelWidth;
    this.h = h-yLabelWidth;
   
    this.xScale = this.w/(dataLength + 1);
    this.yScale = this.h/dataMax;
  }
  
  private float getLabelWidth(float dimWidth, float labelWidth) {
    return min(dimWidth/4, labelWidth); 
  }
}