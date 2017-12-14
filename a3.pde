/*
 * Authors: Max Greenwald and Josh Lee
 * Date: October 23rd, 2017
 * Assignment 3
 */


import processing.awt.PSurfaceAWT.SmoothCanvas;
import javax.swing.JFrame;
import java.awt.Dimension;

import java.util.*; 

Button lineButton = new Button("Line", color(200));
Button barButton = new Button("Bar", color(200));
Button pieButton = new Button("Pie", color(200));

CategoricalSlider dataSlider;

AnimatedChart chart;

void setup() {
  // Setup Canvas
  size(800, 500);
  surface.setResizable(true);
  pixelDensity(displayDensity());
  
  // Setup Canvas Minimum Size
  SmoothCanvas sc = (SmoothCanvas) getSurface().getNative();
  JFrame jf = (JFrame) sc.getFrame();
  Dimension d = new Dimension(400, 330);
  jf.setMinimumSize(d);
  
  // Setup the parser and parse the data
  CSVParser parser = new CSVParser("data.csv");
  int columns = parser.headers.length;
  
  // Generate all the points and create the chart
  Point[] data = new Point[parser.rows.size()];
  for (int i = 0; i < parser.rows.size(); i++) {
    
    // Get the data for the additional data columns
    float[] yData = new float[parser.rows.size()-1];
    for (int j = 1; j < columns; j++) {
      yData[j-1] = Float.parseFloat(parser.rows.get(i).get(parser.headers[j]));
    }
    
    // Get the x and y data for the point 
    String x = parser.rows.get(i).get(parser.headers[0]);
    //float y = Float.parseFloat(parser.rows.get(i).get(parser.headers[1]));
    
    // Initialize the point and add it to the data array
    data[i] = new Point(x, yData);
  }
  
  // Initialize the chart (initially a line chart)
  ArrayList<String> headers = new ArrayList<String>(Arrays.asList(Arrays.copyOfRange(parser.headers, 1, parser.headers.length)));
  chart = new AnimatedChart(data, parser.headers[0], parser.headers[1], headers);

  dataSlider = new CategoricalSlider(chart.getDataHeaders());
  lineButton.setSelected(true);
}

void mouseClicked() {
  if (barButton.mouseOver()) {
    if (chart.animateToChartType(ChartType.BARCHART)) {
      selectAllButtons(false);
      barButton.setSelected(true);
    }
  }
  if (lineButton.mouseOver()) {
    if (chart.animateToChartType(ChartType.LINECHART)) {
      selectAllButtons(false);
      lineButton.setSelected(true);
    }

  }
  if (pieButton.mouseOver()) {
    if (chart.animateToChartType(ChartType.PIECHART)) {
      selectAllButtons(false);
      pieButton.setSelected(true);
    }
  }
}

void mousePressed() {
  dataSlider.startDrag();
}

void mouseDragged() {
  dataSlider.drag();
}

void mouseReleased() {
  dataSlider.stopDrag();
}

void selectAllButtons(boolean selected){ 
  barButton.setSelected(selected);
  lineButton.setSelected(selected);
  pieButton.setSelected(selected);
}

void activateAllButtons(boolean active) {
  lineButton.setActive(active);
  barButton.setActive(active);
  pieButton.setActive(active);
}

void draw() {
  background(255);
  
  chart.render(10, 10, width-20, height-70);
  
  if (chart.isAnimating()) {
    activateAllButtons(false); 
  } else {
    activateAllButtons(true); 
  }
  
  lineButton.render(10, height-50, (width/6)-30, 40); 
  barButton.render((width/6) + 10, height-50, (width/6)-30, 40); 
  pieButton.render((2 * width/6) + 10, height-50, (width/6)-30, 40); 
  
  dataSlider.render(width/2 + 20, height-30,width-20,height-30);
  chart.setCurrentDataHeader(dataSlider.getStringValue());
}