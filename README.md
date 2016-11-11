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
with open('201510-citibike-tripdata.csv', 'rb') as baseData:
    reader = csv.reader(baseData, delimiter=',')
    baseList = list(reader)

print 'There are ' + str(len(baseList)) + ' trips...'

print 'Creating the output file...'
output = open('201510_05_09_trips.csv', 'wb')
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
with open('201510_05_09_trips.csv', 'rb') as baseData:
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
output = open('201510_tripSummary.csv', 'wb')
balanceLabels = []
totalLabels = []
for x in range(24):
    balanceLabels.append(('Balance_'+str(x)))
    totalLabels.append(('Total_'+str(x)))
output.write('StationName' + ',' + ','.join(balanceLabels) + ',' + ','.join(totalLabels) + '\n')
stationCount = 0
for station in stationList:
    hourlyTrips = []
    totalHourlyTrips = []
    for hour in range(24):
        trips = 0
        totalTrips = 0
        for trip in baseList[1:]:
            tripHour = int(trip[1].split(' ')[1].split(':')[1])
            if tripHour == hour:
                if station == trip[4]:
                    trips -= 1
                if station == trip[8]:
                    trips += 1
                if station == trip[4] or station == trip[8]:
                    totalTrips += 1
            else:
                continue
        hourlyTrips.append(str(trips))
        totalHourlyTrips.append(str(totalTrips))
        # print station, hour, trips
    output.write(station + ',' + ','.join(hourlyTrips) + ',' + ','.join(totalHourlyTrips) + '\n')
    stationCount += 1
    print 'Done with station ' + station + ' ' + str(stationCount) + '/' + str(len(stationList))

output.close()
```

### 4. Loading the data into Processing

### 5. Creating a 'Heatmap' of station imbalance

### 6. Creating station 'dials'