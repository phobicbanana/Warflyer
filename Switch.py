#import GPIO and Subprocess

import RPi.GPIO as GPIO
import subprocess

#set GPIO numbering layout and define pin 16 as input
GPIO.setmode(GPIO.BOARD)
GPIO.setup(16,GPIO.IN)

print "LAND THE DRONE TO ACTIVATE SCRIPT!"

#empty while loop that exits when button pressed
while GPIO.input(16)==0:
    pass #passing the operation
subprocess.call("/root/Warflyer.sh", shell=True)

#cleanup the GPIO pins before ending
GPIO.cleanup()
