-----------------
ColorbarPlot v0.5
2009 Oct 13
-----------------
ColorbarPlot is a function to plot a ContourPlot, DensityPlot or 3D plot with an attached colorbar to indicate the ranges of the function that is being plotted. The syntax is not exactly the same as for the built-in functions.

Warning! v0.4 and above is not backwards compatibile with versions 0.3 and below. Sorry.

The following functions are supported by ColorbarPlot:
(List)ContourPlot
List)DensityPlot
(List)Plot3D
ListPointPlot3D

An example file, ColorbarPlot-documentation.nb, is distributed with this package to demonstrate its use.

This package has been written with and for Mathematica 7.0.1. It may work in previous versions of Mathematica but definitely not on anything pre v6.

Please send comments and suggestions to us both at
  wspr 81 at gmail dot com 
  michael dot p dot croucher at googlemail dot com

Copyright 2007-2009
Will Robertson (University of Adelaide)
Mike Croucher (University of Manchester)
-----
To-do
- Horizontal colourbar above or below the plot.
- Hybrid contour/density plot.
- More plot types? (Please suggest!)

-------
Changes

v0.5 (MC)
Added options for CTicksStyle and CLabelStyle to allow easy modification of the font styles in the colorbar ticks and label.  

v0.4 (WR)
PlotRange option is now supported for manually chosing the min/max scale of the colorbar.
List-based plots are supported.
CPadding option for adjusting the size of the colorbar.
Colors option replaced with ColorFunction option.

v0.3 (MC)
Added support for Plot3D; tidied up the code a little.

v0.2 (WR)
Inset used as a wrapper around the Row to add the colorbar to the plot so that the final output is a proper Graphics object. This allows MathPSfrag usage, for example.

-------
Licence

This package consists of the files ColorbarPlot.m and ColorbarPlot-example.nb. It may be freely distributed and modified under the terms & conditions of the Apache License, v2.0: <http://www.apache.org/licenses/LICENSE-2.0>
