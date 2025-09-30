""""
Elouan Delorme
21 aout 2025
introduction au microbit

code démonstrateur avec 10 programmes
bouton a : incrémenter le programme
bouton b : executer

0
1
2
3
4
5
6
7
8
9

"""




# Imports go at the top
from microbit import *
import speech
import random
import music

# on commence avec les programme 0
p = 0

# Code in a 'while True: ' loop repeats forever
while True:
    #choix du programme avec bouton a
    display.show(p)
    if button_a.was_pressed():
        p = p + 1
        if p == 10:
            p = 0

    # le bouton b execute le programme actuel (0..9)
    if button_b.is_pressed():
        if p == 0:
            display.show(Image.ALL_CLOCKS)
            sleep(500)
        if p == 1:
            display.scroll('anticonstitutionellement')
        if p == 2:
            display.scroll(temperature())
        if p == 3:
            audio.play(Sound.SLIDE)
        if p == 4:
            display.scroll('HI!!')
            speech.say('HI!!')
        if p == 5:
            display.scroll(compass.heading())
            
        
        if p == 6:
            display.show(random.randint(1, 6))
        
        if p == 7:
            display.scroll(int(4.9))
        
        if p == 8:
            number = 0
            while number < 10:
                display.scroll(number)
                number = number + 1
            display.scroll('finish')
        
        if p == 9:
            for i in range(3):  
                display.scroll('hello')
            

    if pin_logo.is_touched():
        display.show(Image.DUCK)
        sleep(400)
        music.play(music.BA_DING)
        display.clear()
    
    
   
    
        
    
    
