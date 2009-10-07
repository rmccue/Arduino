import serial
import time
ser = serial.Serial(7)
ser.flush()
time.sleep(2)
ser.write("C")