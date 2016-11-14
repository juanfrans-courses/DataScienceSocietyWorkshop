import processing.pdf.*;

Table hourTable;
Table balanceTable;
int middleCircle = 20;
float divisionFactor = .6668;
int numberOfDials = 15;
int sidePadding = 90;
int spaceBetweenDials = 105;
int verticalSpaceBetween = 100;
float increments = 3;
int position = 0;
float factor = 500;
int totalRadius = 40;

PFont smallFont;
PFont font;

void setup() {
  size(1675, 2384);
  noLoop();
  smooth();
  font = createFont("NeutraTextLight.otf", 6, true);
  smallFont = createFont("NeutraTextLight.otf", 3, true);
  createGraph();
  println("All done...");
}

void createGraph() {
  beginRecord(PDF, "Test_03.pdf");
  colorMode(HSB, 360, 100, 100);
  textAlign(CENTER, CENTER);
  background(0, 0, 20);

  //Read the files
  hourTable = loadTable("Activity_Matrix.csv", "header");
  println("Done loading the activity table, there are " + hourTable.getRowCount() + " rows in the table...");
  balanceTable = loadTable("Oct_Balance_Hour.csv", "header");
  println("Done loading the balance table...");

  //Get data out of the table
  for (int i=0; i<hourTable.getRowCount (); i++) {
    String stationName = hourTable.getString(i, 0);
    float maxTrips = 0;
    float totalTrips = 0;
    float trips = 0;
    float percentage = 0;
    int balance = 0;
    int colorValue;
    for (int j=0; j<25; j++) {
      trips = hourTable.getInt(i, j);
      maxTrips = max(trips, maxTrips);
      totalTrips = totalTrips + trips;
    }

    //Build the framework for the dials
    position = i;
    fill(0, 0, 20);
    noStroke();
    ellipse(sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween), 72, 72);
    for (int j = 0; j<4; j++) {
      noFill();
      strokeWeight(.25);
      stroke(0, 0, 60);
      //ellipse(sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween), middleCircle+(increments*4*j)+increments*2, middleCircle+(increments*4*j)+increments*2);
    }
    for (int j = 0; j<5; j++) {
      noFill();
      strokeWeight(.25);
      stroke(0, 0, 30);
      ellipse(sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween), middleCircle+(increments*4*j), middleCircle+(increments*4*j));
    }
    for (int j = 1; j<5; j++) {
      fill(0, 0, 20);
      noStroke();
      rectMode(CENTER);
      rect((sidePadding+30+(position%numberOfDials)*spaceBetweenDials)+0.25, (verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween)-middleCircle/2-(increments*2*j))+1, 5, 3);
      fill(0, 0, 40);
      textFont(smallFont);
      text(round(j*increments*2*factor/1000)+"%", sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween)-middleCircle/2-(increments*2*j)-1);
    }

    //Build the bars in the dials
    //    for (int j=1; j<25; j++) {
    //      trips = hourTable.getInt(i, j);
    //      strokeWeight(0.5);
    //      strokeCap(SQUARE);
    //      stroke(255, 100, 255);
    //      pushMatrix();
    //      translate(sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween));
    //      rotate(radians(360.0/24*j));
    //      line(0, 0, 0, -middleCircle/2+(trips/27/divisionFactor)*(-1));
    //      popMatrix();
    //    }

    //Build the main markers
    for (int j=1; j<25; j++) {
      trips = hourTable.getInt(i, j);
      percentage = trips/totalTrips;
      balance = balanceTable.getInt(i, j+2);
      noStroke();
      colorValue = 0;
      //fill(0, 0, 30);
      //arc(sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween), middleCircle/2+percentage*factor, middleCircle/2+percentage*factor, radians(-90+((j-1)*360/24)), radians(-90+(j*360/24)));
      if (balance >= 0) {
        fill(180, 100, 100, map(balance, 0, 100, 45, 100));
      } else {
        fill(24, 100, 100, map(balance, 0, -100, 45, 100));
      }
      arc(sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween), middleCircle/2+percentage*factor, middleCircle/2+percentage*factor, radians(-90+((j-1)*360/24)), radians(-90+(j*360/24)));
    }

    //Add the inner circle
    fill(0, 0, 20);
    noStroke();
    ellipse(sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween), middleCircle, middleCircle);
    fill(0, 0, 60);
    noStroke();
    textFont(font);
    text(stationName, sidePadding+30+(position%numberOfDials)*spaceBetweenDials, verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween)-47);
    fill(0, 0, 40);
    textFont(smallFont);    
    for (int j=1; j<9; j++) {
      int hour = j*3;
      String am = "AM";
      if (hour > 11 && hour<24) {
        am = "PM";
      } else {
        am = "AM";
      }
      if (hour > 12) {
        hour = hour - 12;
      }
      text(hour + am, sidePadding+30+(position%numberOfDials)*spaceBetweenDials+totalRadius*cos(radians(-90+(360/8*j))), verticalSpaceBetween/2+(floor(position/numberOfDials)*verticalSpaceBetween+totalRadius*sin(radians(-90+(360/8*j)))));
    }
  }

  endRecord();
}

