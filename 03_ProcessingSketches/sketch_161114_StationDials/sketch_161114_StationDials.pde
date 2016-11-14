// Import Libraries
import processing.pdf.*;

// Global Objects
Table stationTable;
PFont font;
PFont smallFont;

// Global Variables
int leftMargin = 40;
int topMargin = 40;
int numberOfColumns = 15;
int spacing = 42;
float dialSize = 30;
int multiplyingFactor = 7;

void setup(){
  size(670, 1415);
  noLoop();
  loadData();
  createGraph();
  println("All done...");
}

void loadData(){
  stationTable = loadTable("201510_tripSummary.csv", "header");
  println("Data loaded... " + str(stationTable.getRowCount()) + " stations read...");
}

void createGraph(){
  beginRecord(PDF, "StationDials_20161114.pdf");
  colorMode(HSB, 360, 100, 100);
  font = createFont("NeutraTextLight.otf", 6, true);
  smallFont = createFont("NeutraTextLight.otf", 3, true);
  background(0, 0, 20);
  // 01. Building the positions for the cirlces...
  //for (int i=0; i<stationTable.getRowCount(); i++){
  //  ellipse(leftMargin + (i % numberOfColumns) * spacing, topMargin + floor(i / numberOfColumns) * spacing, dialSize, dialSize);
  //}
  // 02. Create dials
  int totalAllTrips = 0;
  noStroke();
  for (int i=0; i<stationTable.getRowCount(); i++){
    float hourlyPercentage = 0;
    float hourlyBalance = 0;
    float totalTrips = 0;
    String stationName = stationTable.getString(i, "StationName");
    for (int j=0; j<24; j++){
      totalTrips = totalTrips + stationTable.getFloat(i, j + 25);
    }
    for (int j=0; j<24; j++){
      hourlyPercentage = stationTable.getFloat(i, j+25) / totalTrips;
      hourlyBalance = stationTable.getFloat(i, j+1);
      if (hourlyBalance >= 0){
        fill(180, 100, 100, map(hourlyBalance, 0, 50, 45, 100));
      }
      else{
        fill(24, 100, 100, map(hourlyBalance, 0, -50, 45, 100));
      }
      arc(leftMargin + (i % numberOfColumns) * spacing, topMargin + floor(i / numberOfColumns) * spacing, 5 + dialSize * hourlyPercentage * multiplyingFactor, 5 + dialSize * hourlyPercentage * multiplyingFactor, radians(-90 + j * 360 / 24), radians(-90 + (j + 1) * 360/24));
    }
    // 03. Add middle circle
    fill(0, 0, 20);
    ellipse(leftMargin + (i % numberOfColumns) * spacing, topMargin + floor(i / numberOfColumns) * spacing, dialSize/5, dialSize/5);
  }
  println(totalAllTrips);
  endRecord();
}