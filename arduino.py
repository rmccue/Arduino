import serial, sys, time, string
try:
	ser = serial.Serial(23)
except serial.SerialException:
	print("No device connected - exiting")
	sys.exit()

# Read the information, as written by PHP
weather = open('weather.txt')
weather = weather.read()
weather = weather.split(',')

ser.write("C")


# We need to sleep to give the Ardunio time to recover
time.sleep(2)

# F = Fine, green LED
# C = Cloudy, yellow LED
# S = Stormy, red LED
ser.write(weather[2])
ser.flush()

# Low temperature
ser.write("L")
ser.write(weather[0])

# High temperature
ser.write("H")
ser.write(weather[1])

# Tie up loose ends
ser.close()

print("Successfully updated.")