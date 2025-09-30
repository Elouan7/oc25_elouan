# Imports go at the top
from microbit import *
import music


# Code in a 'while True:' loop repeats forever
while True:
    if pin_logo.is_touched():
        display.show(Image.DUCK)
        audio.play(Sound.SPRING)
        display.scroll(display.read_light_level())
        

    
   
    
        
    
    
