// Global variables
Table tripTable;
Trips[] trip;
int totalFrames = 3600;
int totalMinutes = 86400;
float minLat = 40.796510033;
float maxLat = 40.669605447;
float minLon = -74.036965068;
float maxLon = -73.910060482;

void setup(){
  size(800, 800);
  loadData();
  println("All done...");
}

void loadData(){
  tripTable = loadTable("201510_05_09_trips.csv", "header");
  println(str(tripTable.getRowCount()) + " records loaded...");
  trip = new Trips[tripTable.getRowCount()];
  for (int i=0; i<tripTable.getRowCount(); i++){ //******** take this back up to the full dataset *********
    int duration = round(map(tripTable.getInt(i, "tripduration"), 0, totalMinutes, 0, totalFrames));
    String[] starttime = split(split(tripTable.getString(i, "starttime"), " ")[1], ":");
    String[] endtime = split(split(tripTable.getString(i, "stoptime"), " ")[1], ":");
    float startSecond = int(starttime[0]) * 3600 + int(starttime[1]) * 60 + int(starttime[2]);
    float endSecond = int(endtime[0]) * 3600 + int(endtime[1]) * 60 + int(endtime[2]);
    int startFrame = floor(map(startSecond, 0, totalMinutes, 0, totalFrames));
    int endFrame = floor(map(endSecond, 0, totalMinutes, 0, totalFrames));
    String startStation = tripTable.getString(i, "start station name");
    String endStation = tripTable.getString(i, "end station name");
    float startX = map(tripTable.getFloat(i, "start station longitude"), minLon, maxLon, 0, 800);
    float startY = map(tripTable.getFloat(i, "start station latitude"), minLat, maxLat, 0, 800);
    float endX = map(tripTable.getFloat(i, "end station longitude"), minLon, maxLon, 0, 800);
    float endY = map(tripTable.getFloat(i, "end station latitude"), minLat, maxLat, 0, 800);
    int bikeId = tripTable.getInt(i, "bikeid");
    int gender = tripTable.getInt(i, "gender");
    trip[i] = new Trips(duration, startFrame, endFrame, startStation, endStation, startX, startY, endX, endY, bikeId, gender);
  }
}

void draw(){
  noStroke();
  fill(0, 0, 0, 20);
  rect(0, 0, 800, 800);
  fill(250);
  for (int i=0; i<trip.length; i++){
    trip[i].plotRide();
  }
}

class Trips{
  // Class properties
  PVector start, end;
  int tripFrames, startFrame, endFrame;
  
  // Class constructor
  Trips(int duration, int start_frame, int end_frame, String startStation, String endStation, float startX, float startY, float endX, float endY, int bikeId, int gender){
    start = new PVector(startX, startY);
    end = new PVector(endX, endY);
    tripFrames = duration;
    startFrame = start_frame;
    endFrame = end_frame;
  }
  // Class methods
  void plotRide(){
    if (frameCount >= startFrame && frameCount < endFrame){
      float percentTravelled = (float(frameCount) - float(startFrame)) / float(tripFrames);
      PVector currentPosition = new PVector(lerp(start.x, end.x, percentTravelled), lerp(start.y, end.y, percentTravelled));
      ellipse(currentPosition.x, currentPosition.y, 2, 2);
    }
    else{
    }
  }
}