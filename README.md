# Ecstasy

Ecstasy is a 3D game made in Delphi version 5 and OpenGL (<= 2.1) for Windows Xp made in 2003 at EPITA school.

Ecstasy was one of our first team projects (and game), so sorry this is not an optimized and free-bug game, use it 'as it' !

## Wanted

I'm looking for Delphi developers. I'm curious to check if Ecstasy can work on recent Windows (>= 7) and therefore if the project can compile with a more recent Delphi.

## Screenshot:

![alt tag](https://github.com/Lecrapouille/Ecstasy/blob/master/doc/screenshot.jpg)

:) :) :) !!! Warning: Never take this substance when driving !!! :) :) :)

## Features are
* city generated randomly on a torus world.
* cars stopped at traffic lights.
* developement report (requested by our teachers).
* the player car has a basic physic model (physic is explained in the pdf).

Not implemented:
* missing a fixed frame rate (will be fixed in 2017).
* off-road partially implemented (will be fixed in 2017).
* simple optim to avoid game slowing down on hudge traffic jam. (will be fixed in 2017).
* no collision detection: cars and buildings (will be fixed in 2017 but just for buildings). 
* no IA (collision avoidance, cars do not turn). (will never be added)
* city generation with a better procedural process. (will never be added)
* More physics (like pumping effect on wheel depending on acceleration). (maybe will be added one day).

## Player control

* F1 key: change the camera view (inside or outside the car).
* Numeric keys: 4, 6, 2, 8 for changing the camera position and angle.
* Left/Right key (or mouse): change the wheel angle.
* Tabular key: Change the gear (driving or reverse).

## Notes

* This is a french project (code + doc). Translations (even for the code source) upon request by e-mail.
* More french documentation is given on my [webpage](http://q.quadrat.free.fr/ecstasy-fr.html) concerning how to add more cars in the game.
* This project needs Borland Delphi 5 (never tried higher version). If you need Delphi5 for Windows XP (if people still have it): send me an e-mail. The main project is named `Ecstasy.dpr`.
* You will need data/ near the exe to be loaded.
