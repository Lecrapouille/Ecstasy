# Ecstasy

Ecstasy is a 3D game made in Delphi version 5 and OpenGL (<= 2.1), and some DirectX stuffs (for sound) for Windows Xp made in 2003 at EPITA school.

Ecstasy was one of our first team projects (and game), so sorry this is not an optimized and free-bug game, use it 'as it' !

### Wanted

I'm looking for Delphi developers. ~~I'm curious to check if Ecstasy can work on recent Windows (>= 7) and therefore if the project can compile with a more recent Delphi.~~ Update: thank to [dslutej](https://github.com/dslutej) the game is compiling on Windows 10 (64-bits) and Delphi 10.2.1. See [here](https://github.com/Lecrapouille/Ecstasy/issues/4) for more information.

### Screenshot

![alt tag](https://github.com/Lecrapouille/Ecstasy/blob/master/doc/screenshot.jpg)

:) :) :) !!! Warning: Never take this substance when driving !!! :) :) :)

### Features are
* infinite-sized city because generated randomly on a torus world (nice way to say I apply modulo on positions).
* cars stopped at traffic lights.
* developement report (requested by our teachers).
* the player car has a basic physic model (physic is explained in the pdf).

Note: In 2017, for the fun, I currently fixing lot of bugs and finishing some features.

Not implemented:
* english language (sorry it's was, at begining, a student project). It will take too much time for translating the code.
* missing a fixed frame rate (will be fixed in 2017).
* ~~off-road partially implemented (will be fixed in 2017).~~
* simple optim to avoid game slowing down on hudge traffic jam. (will be fixed in 2017).
* no collision detection: cars and buildings (will be fixed in 2017 but just for buildings).
* no IA (collision avoidance, IA cars do not turn; no police cars to catch the player).
* city generation with a better procedural process.
* More physics (like pumping effect on wheel depending on acceleration). (maybe will be added one day).

### Player control

* F1 key: change the camera view (inside or outside the car).
* Numeric keys: 4, 6, 2, 8 for changing the camera position and angle.
* Up/down: accelerate or brake.
* Left/Right key (or mouse): change the wheel angle.
* Tabular key: Change the gear (driving or reverse).

### Notes

* This project needs Borland Delphi 5. The main project is named `Ecstasy.dpr`. If you need Delphi5 for Windows XP (if people still use XP): send me an e-mail. You are welcome to check if this project works on different Windows and Delphi.
* This is a french project (code + doc). Translations (even for the code source) upon request by e-mail.
* More french documentation is given on my [webpage](http://q.quadrat.free.fr/ecstasy-fr.html) concerning how to add more cars in the game.
* 3D models (car and buildings) are exported into ASE file format (use 3D Studio Max for example)
* You will need the `data` directory near the `Ecstasy.exe` to be loaded.

### Diving inside the code

The city is just a grid of urban zones (aka 2D matrix). City size if finite but bounds are connected, that is why the city is finaly infinite. As mathematical point of view, you are driving on a torus world. The city matrix looks like this:
```
  +-------------+--------------+-----+
  |    ...      |      ...     | ... |
  +-------------+--------------+-----+
  | block[1,0]  |  block[1,1]  | ... |
  +-------------+--------------+-----+
  | block[0,0]  |  block[1,0]  | ... |
  +-------------+--------------+-----+
```

A block (aka urban zone) is another kind of matrix: a rectangle made of two roads (horizontally and vertically), a cross-road with traffic lights, and in the remaining space there either buildings or a river or an off-road terrain. A road is a 4-ways road: direct way (low and fast ways) and indirect (low and fast). Let see one block:
```
      +---------+----------------------------+            Z
      |0 cross 1|0    road #1               1|             \
      |  road   |                            |              \Blue
      |3       2|3                          2|               \
      +---------+----------------------------+               (+)------------> Y
      |0       1|                            |                |             Green
      |    r    |          buildings         |                |
      |    o    |             or             |                |
      |    a    |            river           |                |
      |    d    |             or             |                v
      |   #0    |          off-road          |               Red
      |3       2|                            |                X
      +---------+----------------------------+
```
Numbers 0 .. 3 indicates the vertices order. Roads and crossroads are just made with 2 OpenGL triangles. Use theses informations for getting cars altitude and in which part they are driving (which roads).

You can display the word axis wit the dessinerRepere(x,y,z) procedure. The X-axis is red, the Y-axis is green and the Z-axis is blue (and its direction is up).

We give a random altitude to all crossroads (crossroad have all its vertices on the same altitude). Like this roads have a known slope. The off-road terrain is a matrix of rectangles sub-divided into two triangles (like any game with a height-map). The pavement/sidewalk for buildings is made of two triangles (that is enough good visualy and simple). It's now very easy to compute the altitude anywhere on the city.

A 4-ways road looks like the following (same behavior for road0 and road1):
```
  +--------------------------------------+
  |     <----      low way               |
  +--  --  --  --  --  --  --  --  --  --+ direct way
  |     <----     fast way               |
  +======================================+
  |     ---->      low way               |
  +--  --  --  --  --  --  --  --  --  --+ indirect way
  |     ---->     fast way               |
  +--------------------------------------+
```

The traffic jam is just a dynamic list (linked-list) of vehicles. Each car know the velocity and position of the previous one. When a car changes of block (it was on the head of the linked-list) it's just detached form this list and placed on the queue of the list of the new block. The head car does not know information about the previous car (the last of the other block) but just know the state of the traffic light: it stops when passing from green to orange.

Car velocity is made of attractive and repulsive forces depending on the distance.

The dynamic of the player car is explained [on my other github project](https://github.com/Lecrapouille/PrincipeMoindreAction). Traductions upon request (again ;)
