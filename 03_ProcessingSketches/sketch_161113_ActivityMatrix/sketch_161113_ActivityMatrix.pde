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