# Robot_Path_Visualizer
tcl file to visualize robot paths and animate a robot with them

to run tcl you have to download and install it...
https://www.activestate.com/activetcl
just get the free community edition

next you will have to change the filepaths of the two files (hopperPath.txt and Field.csv) to match where you place them on your computer.
the desktop is a great spot...

you can change pNum to = whatever number you want, everything is multiplied by it, all of my measurements are in feet.
I multiply everything by 12 so 1 pixel=1 inch, if you want 2 pixels=1 inch, just change: pNum=[expr 12x2], 12x0.5 also works, etc.
