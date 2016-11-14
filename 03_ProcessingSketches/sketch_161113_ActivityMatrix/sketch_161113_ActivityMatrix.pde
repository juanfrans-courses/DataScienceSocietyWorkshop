// Import libraries
import processing.pdf.*;

// Global Objects
Table stationTable;
PFont font;

void setup(){
  size(670,1100);
  noLoop();
  loadData();
  createGraph();
}

void createGraph(){
  beginRecord(PDF, "ImbalanceMatrix.pdf");
  colorMode(HSB, 360, 100, 100);
  font = createFont("NeutraTextLight.otf", 2, true);
  textFont(font);
  background(0, 0, 20);
  String stationName;
  textAlign(RIGHT);
  noStroke();
  for (int i=0; i<stationTable.getRowCount(); i++){
    stationName = stationTable.getString(i, "StationName");
    fill(0, 0, 100);
    text(stationName, 45, 25+i*3);
    for (int j=0; j<24; j++){
      float hourValue = stationTable.getInt(i, (j+1));
      float alphaValue;
      if (hourValue >= 0){
        alphaValue = map(hourValue, 0, 50, 5, 100);
        fill(180, 100, 100, alphaValue);
      }
      else{
        alphaValue = map(hourValue, 0, -50, 5, 100);
        fill(24, 100, 100, alphaValue);
      }
      rect(50 + j*25, 23.5 + i*3, 24.5, 2.5);
    }
  }
  endRecord();
}

void loadData(){
  stationTable = loadTable("201510_tripSummary.csv", "header");
  println("Data loaded... " + str(stationTable.getRowCount()) + " stations read...");
}