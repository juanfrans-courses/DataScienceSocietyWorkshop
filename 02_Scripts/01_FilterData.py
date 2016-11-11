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