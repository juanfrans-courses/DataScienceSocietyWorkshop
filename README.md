## Data Visualization with Processing
Workshop for the Columbia Data Science Society by Juan Francisco Saldarriaga (jfs2118@columbia.edu)

### 1. Download Processing and Base Data
* [Processing.org](https://processing.org/)
* There are great tutorials for Processing [here](https://processing.org/tutorials/) and [here](https://www.youtube.com/user/shiffman/playlists?sort=dd&shelf_id=2&view=50).
* [Citibike trip data](https://www.citibikenyc.com/system-data): trip data by month.
* [Citibike station data](https://feeds.citibikenyc.com/stations/stations.json): station data, updated every two minutes (json format).

### 2. Filtering the data
We will only be using data for weekday trips in one week in October 2015. So the first thing we need to do is create a subset of the data with just these trips: 10/05/15 - 10/09/15.
```python
import csv

print 'Reading base data...'
with open('../01_Data/201510-citibike-tripdata.csv', 'rb') as baseData:
    reader = csv.reader(baseData, delimiter=',')
    baseList = list(reader)

print 'There are ' + str(len(baseList)) + ' trips...'

print 'Creating the output file...'
output = open('../01_Data/201510_05_09_trips.csv', 'wb')
output.write(','.join(baseList[0]) + '\n')
selectedTrips = 0
for trip in baseList[1:]:
    tripDate = trip[1].split(' ')[0].split('/')[1]
    if 4 < int(tripDate) < 10:
        output.write(','.join(trip) + '\n')
        selectedTrips += 1
    else:
        pass
print str(selectedTrips) + ' trips were seelcted...'
output.close()
```

### 3. Summarizing the data
Once we've filtered the data we need to summarize into the right format, showing for every station, how many trips per hour happened and what was the balance for every hour. There is probably a much better way of creating this dataset with Pandas but here's my basic Python script:
```python
import csv

print 'Reading base data...'
with open('../01_Data/201510_05_09_trips.csv', 'rb') as baseData:
    reader = csv.reader(baseData, delimiter=',')
    baseList = list(reader)
print 'There are ' + str(len(baseList)) + ' trips...'

print 'Creating a list of the stations...'
stationList = []
for trip in baseList[1:]:
    originName = trip[4]
    destinationName = trip[8]
    if originName not in stationList:
        stationList.append(originName)
    if destinationName not in stationList:
        stationList.append(destinationName)
print 'There are ' + str(len(stationList)) + ' stations...'

print 'Creating the output file...'
output = open('../01_Data/201510_tripSummary.csv', 'wb')
balanceLabels = []
totalLabels = []
for x in range(24):
    balanceLabels.append(('Balance_'+str(x)))
    totalLabels.append(('Total_'+str(x)))
output.write('StationName' + ',' + ','.join(balanceLabels) + ',' + ','.join(totalLabels) + '\n')
stationCount = 0
for station in stationList:
    hourlyBalance = []
    totalHourlyTrips = []
    for hour in range(24):
        balance = 0
        totalTrips = 0
        for trip in baseList[1:]:
            tripHour = int(trip[1].split(' ')[1].split(':')[0])
            if tripHour == hour:
                if station == trip[4]:
                    balance -= 1
                if station == trip[8]:
                    balance += 1
                if station == trip[4] or station == trip[8]:
                    totalTrips += 1
            else:
                continue
        hourlyBalance.append(str(balance))
        totalHourlyTrips.append(str(totalTrips))
    output.write(station + ',' + ','.join(hourlyBalance) + ',' + ','.join(totalHourlyTrips) + '\n')
    stationCount += 1
    print 'Done with station ' + station + ' ' + str(stationCount) + '/' + str(len(stationList))

output.close()
```

### 4. Intro to Processing
```Processing
void setup(){
  size(500,500);
  background(0);
}

void draw(){
  background(0);
  ellipse(mouseX, mouseY, 20, 20);
}
```

### 5. Creating a grid
```Processing
int circleWidth = 20;
int numberOfColumns = 22;
int numberOfRows = 22;
int topMargin = 15;
int rightMargin = 15;
int circleSpacing = 2;
float hueColor = 0;
float saturationColor = 0;

void setup(){
  size(500,500);
  background(0);
  colorMode(HSB, 360, 100, 100);
  pixelDensity(2);
  noLoop();
  noStroke();
  for (int i=0; i < numberOfRows; i++){
    for (int j=0; j < numberOfColumns; j++){
      hueColor = map(i, 0, numberOfRows, 0, 360);
      saturationColor = map(j, 0, numberOfColumns, 50, 100);
      fill(hueColor, saturationColor, 100);
      ellipse(i*(circleWidth+circleSpacing) + rightMargin, j*(circleWidth+circleSpacing) + topMargin, circleWidth, circleWidth);
    }
  }
}
```

### 6. Loading the data into Processing
```Processing
// Global Objects
Table stationTable;

void setup(){
  loadData();
}

void loadData(){
  stationTable = loadTable("201510_tripSummary.csv", "header");
  println(stationTable.getRowCount());
  String stationName;
  int totalImbalance;
  for (int i=0; i<stationTable.getRowCount(); i++){
    totalImbalance = 0;
    stationName = stationTable.getString(i, "StationName");
    for (int j=0; j<24; j++){
      totalImbalance = totalImbalance + stationTable.getInt(i, (1+j));
    }
    println(stationName + " - Total Imbalance = " + str(totalImbalance));
  }
}
```
### 7. Creating a 'Heatmap' of station imbalance
Final code:
```Processing
// Import libraries
import processing.pdf.*;

// Global Objects
Table stationTable;
PFont font;

void setup(){
  size(670,1415);
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
```

### 8. Creating station 'Dials'
```Processing
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
```

### 9. Animating Citibike trips
```Processing
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
```