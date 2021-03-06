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