# Imports go at the top
from microbit import *
import neopixel



# Code in a 'while True:' loop repeats forever
while True:
    if button_a.was_pressed():
        np = neopixel.NeoPixel(pin8, 60)
        np[0] = (255, 0, 0)
        np[1] = (0, 255, 0)
        np[2] = (0, 0, 255)
        np.show()
