# 3D-Terrain

This project is a grid of vertex and triangle data that creates a 3D terrain algorithmically. Additional features include color and changing the elevation of points.

**Key features**:
* Grid can be resized using the Rows, Columns, and Terrain Size sliders, and the Generate button
* Terrain can be modified by loading a heightmap entered in the textfield
* Orbit camera implemented, moves when the user clicks and drags their mouse
* Height modifier slider implemented and functional: Terrain can be raised or lowered based on the value of the slider (up for positive values, down for negative values)
* Snow threshold slider implemented and functional. “Snow” can be increased or reduced appropriately according to the snow threshold
* Toggle drawing wireframes over the terrain
* Toggle between white polygons and colored terrain. Colored terrain is draw with 4 "levels" according to the project spec - water, grass, rock, snow
* Switch between basic color and interpolated color. Interpolated color “lerps” between color levels, and adds a dirt/mud later between water and grass
