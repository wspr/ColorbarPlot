(* ::Package:: *)

(* ::Title:: *)
(*Readme*)


(* ::Text:: *)
(*ColorbarPlot v0.6*)
(*2010 Jul 7*)
(**)
(*ColorbarPlot is a function to plot a ContourPlot, DensityPlot or 3D plot with an attached colorbar to indicate the ranges of the function that is being plotted. The syntax is not exactly the same as for the built-in functions.*)
(**)
(*Warning! v0.4 and above is not backwards compatibility with versions 0.3 and below. Sorry.*)
(**)
(*The following functions are supported by ColorbarPlot:*)
(* \[Bullet] (List)ContourPlot*)
(* \[Bullet] (List)DensityPlot*)
(* \[Bullet] (List)Plot3D*)
(* \[Bullet] ListPointPlot3D*)
(**)
(*An example file, ColorbarPlot-documentation.nb, is distributed with this package to demonstrate its use.*)
(**)
(*This package should work for Mathematica versions six and later.*)
(**)
(*Please send comments and suggestions to us at*)
(*  wspr 81 at gmail dot com *)
(*  michael dot p dot croucher at googlemail dot com*)
(*   t.zell at gmx dot de*)
(**)
(*Copyright 2007-2010*)
(*Will Robertson (University of Adelaide)*)
(*Mike Croucher (University of Manchester)*)
(*Thomas Zell (University of Cologne)*)


(* ::Title:: *)
(*To-do*)


(* ::Text:: *)
(*Horizontal colourbar above or below the plot.*)


(* ::Text:: *)
(*Hybrid contour/density plot.*)


(* ::Text:: *)
(*More plot types? (Please suggest!)*)


(* ::Title:: *)
(*Changes*)


(* ::Subsubsection:: *)
(*v0.6 (TZ)*)


(* ::Text:: *)
(*More robust data and options handling. Extended the PlotRange option to be almost as powerful as the one of the built-in plot functions (there is still no difference between 'Full' and 'Automatic' for the z-range).*)


(* ::Subsubsection:: *)
(*v0.5 (MC)*)


(* ::Text:: *)
(*Added options for CTicksStyle and CLabelStyle to allow easy modification of the font styles in the colorbar ticks and label.  *)


(* ::Subsubsection:: *)
(*v0.4 (WR)*)


(* ::Text:: *)
(*PlotRange option is now supported for manually chosing the min/max scale of the colorbar.*)


(* ::Text:: *)
(*List-based plots are supported.*)


(* ::Text:: *)
(*CPadding option for adjusting the size of the colorbar.*)


(* ::Text:: *)
(*Colors option replaced with ColorFunction option.*)


(* ::Subsubsection:: *)
(*v0.3 (MC)*)


(* ::Text:: *)
(*Added support for Plot3D; tidied up the code a little.*)


(* ::Subsubsection:: *)
(*v0.2 (WR)*)


(* ::Text:: *)
(*Inset used as a wrapper around the Row to add the colorbar to the plot so that the final output is a proper Graphics object. This allows MathPSfrag usage, for example.*)


(* ::Title::Closed:: *)
(*Licence*)


(* ::Text:: *)
(*This package consists of the files ColorbarPlot.m and ColorbarPlot-example.nb. It may be freely distributed and modified under the terms & conditions of the Apache License, v2.0: <http://www.apache.org/licenses/LICENSE-2.0>*)


(* ::Title:: *)
(*Preamble*)


BeginPackage["ColorbarPlot`"];


ColorbarPlot::usage =
"ColorbarPlot[ F[#1,#2] & , {Xmin, Xmax} , {Ymin, Ymax} , <options> ]:
  Creates a DensityPlot or a ContourPlot or a 3DPlot of the
  function F with an attached colorbar to denote its range.

ColorbarPlot[ {{x1, y1, \[Ellipsis]}, {x2, y2, \[Ellipsis]}, \[Ellipsis]} , <options> ]:
  Creates the List-based versions of the plots above.
  (E.g., ListContourPlot, ListPlot3D, etc.)

This is a list of options that ColorbarPlot accepts and their
default options. Where multiple options are listed, the first 
is the default:

General:
  PlotType \[Rule] \"Density\" | \"Contour\" | \"3D\" | \"Point3D\"
  ColorFunction \[Rule] \"LakeColors\" | etc. \[Ellipsis] 
  PlotRange \[Rule] Automatic | {min, max} | {{xmin, xmax}, {ymin, ymax}} |
    {{xmin ,xmax}, {ymin, ymax}, {zmin, zmax}}

For the plot:
  XLabel \[Rule] \"\"
  YLabel \[Rule] \"\"
  ZLabel \[Rule] \"\"
  Title \[Rule] \"\"
  Height \[Rule] 8*72/2.54  (=8cm)

For the colorbar:
  CLabel \[Rule] \"\"
  CTicks \[Rule] All
  CTickSide \[Rule] Left | Right
  CSide \[Rule] Right | Left
  CTicksStyle->{}
  CLabelStyle->{}
  ColorbarOpts \[Rule] {}


Unknown options to ColorbarPlot are passed transparently
to the underlying plot function. Note that such options
are -not- passed to the colorbar; use the ColorbarOpts 
option for this purpose instead.

The x- and y-ranges of the PlotRange option are passed directly
to the underlying plot function. The z-range handling is not as
intelligent as the one of the built-in plot functions. If set to
'Automatic' it will always cover the full range of the supplied
data, regardless of the subset chosen with the x- and y-range.";


Begin["`Private`"]


(* ::Title:: *)
(*Package*)


(* ::Section:: *)
(*Main ColorbarPlot functions*)


(* ::Subsection:: *)
(*Options*)


Options[ColorbarPlot]={
(* general: *)
  ColorFunction -> "LakeColors",
  PlotType -> "Density",
  PlotRange -> Automatic,
(* for the plot: *)
  XLabel   -> "",
  YLabel   -> "",
  ZLabel   -> "",
  Title    -> "",
  Height   -> 8*72/2.54,
  Overlay  -> "",
(* for the colorbar: *)
  CLabel   -> "",
  CTicks   -> All,
  CTickSide-> Left,
  CSide    -> Right,
  ColorbarOpts -> {},
  CPadding -> Automatic,
  CTicksStyle->{},
  CLabelStyle->{}
};


(* ::Subsection:: *)
(*Contour, Density, 3D plots*)


ColorbarPlot[function_,{___,x1_,x2_},{___,y1_,y2_},opts___] := 
  InternalColorbarPlot["functionplot",
    {function,{x,x1,x2},{y,y1,y2}},opts];


(* ::Subsection:: *)
(*All List-based plots*)


ColorbarPlot[listplotdata_,opts___] := 
  InternalColorbarPlot["listplot",{listplotdata},opts] /;
    If[ArrayQ[listplotdata],
      If[MatchQ[Dimensions[listplotdata], {x_, y_} /; x>1 && y>1], True,
      	Message[ColorbarPlot::dimerr]; False],
      Message[ColorbarPlot::arrayerr]; False];


(* ::Subsection:: *)
(*Helpers*)


(* ::Text:: *)
(*This is like the opposite of FilterRules:*)


FilterOutRules[lst_,items_] := Complement[lst,FilterRules[lst,items]]


(* ::Section:: *)
(*Internal definition for ColorbarPlot*)


(* ::Subsection:: *)
(*Inputs and scoping*)


InternalColorbarPlot[parseplot_,plotinput_,
             opts:OptionsPattern[]] := Module[




(* ::Subsection:: *)
(*Local variables*)


{min = Infinity, max = -Infinity,
 Opt, PlotOpt, MinMaxMon,
 bartype, barticks, 
 colorbar, cbarside, contours, frameticks,
 labels, plot, plottype, inputrange,
 listplot = False, xrange = Full,
 yrange = Full, zrange = {Full, Full} },




(* ::Subsection:: *)
(*The Opt[] function*)


(* ::Text:: *)
(*Convenience command for ColorbarPlot option processing :*)


Opt[x_] := OptionValue[ColorbarPlot,
       FilterRules[{opts},Options[ColorbarPlot]],x];


(* ::Subsection:: *)
(*Plot type processing*)


If[parseplot == "listplot",listplot := True];
Which[




(* ::Subsubsection:: *)
(*(List)ContourPlot*)


Evaluate@Opt@PlotType == "Contour",
  If[listplot,
    plottype = ListContourPlot,
    plottype = ContourPlot];
  bartype = ContourPlot;
  colours = ColorFunction -> 
    (ColorData[Opt@ColorFunction][(#1-zrange[[1]])/(zrange[[2]]-zrange[[1]])]&);
  labels = FrameLabel -> {{Opt@YLabel,None},
                          {Opt@XLabel,Opt@Title}};
,




(* ::Subsubsection:: *)
(*(List)DensityPlot*)


Evaluate@Opt@PlotType == "Density",
  If[listplot,
    plottype = ListDensityPlot,
    plottype = DensityPlot];
  bartype = DensityPlot;
  colours = ColorFunction -> 
    (ColorData[Opt@ColorFunction][(#1-zrange[[1]])/(zrange[[2]]-zrange[[1]])]&);
  labels = FrameLabel -> {{Opt@YLabel,None},
                          {Opt@XLabel,Opt@Title}};
,




(* ::Subsubsection:: *)
(*Hybrid*)


Evaluate@Opt@PlotType == "Hybrid",
  If[listplot,
    plottype = ListDensityPlot,
    plottype = DensityPlot];
  bartype = DensityPlot;
  colours = ColorFunction -> 
    (ColorData[Opt@ColorFunction][(#1-zrange[[1]])/(zrange[[2]]-zrange[[1]])]&);
  labels = FrameLabel -> {{Opt@YLabel,None},
                          {Opt@XLabel,Opt@Title}};
,




(* ::Subsubsection:: *)
(*(List)Plot3D*)


Evaluate@Opt@PlotType == "3D",
  If[listplot,
    plottype = ListPlot3D,
    plottype = Plot3D];
  bartype = DensityPlot;
  colours = ColorFunction -> 
    (ColorData[Opt@ColorFunction][(#3-zrange[[1]])/(zrange[[2]]-zrange[[1]])]&);
  labels = {PlotLabel -> Opt@Title,
          AxesLabel -> {Opt@XLabel,Opt@YLabel,Opt@ZLabel}};
,




(* ::Subsubsection:: *)
(*ListPointPlot3D*)


Evaluate@Opt@PlotType == "Point3D",
  plottype = ListPointPlot3D;
  bartype = DensityPlot;
  colours = ColorFunction -> 
    (ColorData[Opt@ColorFunction][(#3-zrange[[1]])/(zrange[[2]]-zrange[[1]])]&);
  labels = {PlotLabel -> Opt@Title,
          AxesLabel -> {Opt@XLabel,Opt@YLabel,Opt@ZLabel}};
];


(* ::Subsection:: *)
(*The PlotOpt[] function*)


(* ::Text:: *)
(*For plot option processing (filter out options for the plot itself)*)


PlotOpt[x_] := OptionValue[plottype,
  FilterRules[{opts},Options[plottype]],x];


(* ::Subsection:: *)
(*Range of the function*)


(* ::Subsubsection:: *)
(*List input*)


(* ::Text:: *)
(*For List plots it's easy to get the extrema points:*)


If[listplot,




(* ::Text:: *)
(*If we have a set of {x,y,f} triplets then extract the max/min from the f dimension:*)


  If[Length[Dimensions[plotinput]] == 3 && Dimensions[plotinput][[3]]==3,
    max=Max[plotinput[[All,3]]];
    min=Min[plotinput[[All,3]]];
  ,




(* ::Text:: *)
(*Else it's something like {{f11,f12,\[Ellipsis]},{f21,f22,\[Ellipsis]},\[Ellipsis]} and we can just use Min/Max directly:*)


    min=Min[Select[Flatten@plotinput,NumericQ]];
    max=Max[Select[Flatten@plotinput,NumericQ]];
  ];
,




(* ::Subsubsection:: *)
(*Function input*)


(* ::Text:: *)
(*Function plots need a bit more work. First extract the function and ranges over which to plot: (the Rest@ syntax allows 3D function input, but we're not using that at the moment.)*)


  function = First@plotinput;
  inputrange = Rest@plotinput;


(* ::Text:: *)
(*Define a function from the input that records the maxima and minima of the function as it is evaluated.*)
(*This information is later used to generate the colorbar:*)


  MinMaxMon[in__?NumericQ] := 
    Module[{val=Evaluate@function@in},
      min = Min[min,val];
      max = Max[max,val];
      val];


(* ::Text:: *)
(*Construct dummy plot to set min and max:*)


  preplot = plottype[
    MinMaxMon[x,y],
    Evaluate[Sequence@@inputrange],
    Evaluate[FilterRules[{opts},Options[plottype]]]
  ];


];  



(* ::Text:: *)
(*check min & max values for validity:*)


If[!NumericQ[min] || !NumericQ[max], Message[ColorbarPlot::minmaxerr]; Return[$Failed]];


(* ::Text:: *)
(*Patterns to parse PlotRange option:*)


FindRange[x_] :=  Module[{}, zrange = {Full, Full};] /; x === Full || x === Automatic || x === All;

FindRange[x_?NumericQ] := Module[{}, zrange = {-x, x};];

FindRange[{x_, y_}] := Module[{}, 
   zrange = {x, y};] /;
   (NumericQ[x] || x === Full || x === Automatic || x === All) &&
   (NumericQ[y] || y === Full || y === Automatic || y === All);

FindRange[{xr_, yr_}] := Module[{}, xrange = xr; yrange = yr;];

FindRange[{xr_, yr_, zr_}] := Module[{}, xrange = xr; yrange = yr; FindRange[zr];] /; 
   !MatchQ[zr, {_, _, _}];

FindRange[x_] := Message[ColorbarPlot::rangeerr];


(* ::Text:: *)
(*Finally, set the PlotRange based on the data above:*)


FindRange[Evaluate@Opt@PlotRange];

If[zrange[[1]] === Full, zrange[[1]] = min];
If[zrange[[2]] === Full, zrange[[2]] = max];

If[zrange[[1]] == zrange[[2]], zrange[[2]] = zrange[[1]] + 1]; (* avoid division by zero in ColorFunction *)



(* ::Subsection:: *)
(*Specification of the colorbar tickmarks*)


If[bartype === ContourPlot,
  If[Head[Evaluate@PlotOpt@Contours] === List,
     barticks = PlotOpt@Contours,
     barticks = Opt@CTicks];
  contours = Contours -> PlotOpt@Contours;
 ,(*else*)
  barticks := Opt@CTicks;
  contours := {};
];


(* ::Subsection:: *)
(*Colorbar side and ticks locations*)


If[Evaluate@Opt@CTickSide === Right,
  frameticks = {None,barticks};
 ,(* else *)
  frameticks = {barticks,None};
];
If[Evaluate@Opt@CSide === Left,
  cbarside := Reverse;
 ,(* else *)
  cbarside := Identity;
];


(* ::Subsection:: *)
(*Colorbar padding*)


colorbarpadding = All;
If[ Evaluate@Opt@CPadding =!= Automatic,
  If[ Dimensions@Opt@CPadding == {2},
    colorbarpadding = {
     cbarside@{First@Opt@CPadding,5},
     {Last@Opt@CPadding,Last@Opt@CPadding}}; 
    ,
    Message[CPadding::wrongdimen];
  ];
];


(* ::Subsection:: *)
(*Filter rules*)


plotrules = FilterOutRules[
  FilterRules[{opts},Options@plottype],
  Options@ColorbarPlot];


(* ::Subsection:: *)
(*Construct the main plot*)


plot = plottype[
  Evaluate@If[listplot,
    Sequence@First@plotinput,
    Sequence@@inputrange~Prepend~function[x,y]],
  Evaluate@plotrules,
  ImageSize -> {Automatic,Opt@Height},
  ColorFunctionScaling -> False,
  PlotRange -> {xrange, yrange, zrange},
  Evaluate@Sequence@colours,
  Evaluate@Sequence@labels
];

If[ Opt@Overlay === "" ,Null, plot = Show[{plot,Opt@Overlay}]; ];


(* ::Subsection:: *)
(*Construct the colorbar*)


colorbar = bartype[
  y,{x,0,1},{y,zrange[[1]],zrange[[2]]},
  Evaluate@Sequence@Opt@ColorbarOpts,
  ImageSize -> {Automatic,Opt@Height},
  ImagePadding -> Evaluate@colorbarpadding,
  ColorFunctionScaling -> False,
  ColorFunction -> (ColorData[Opt@ColorFunction][(#1-zrange[[1]])/(zrange[[2]]-zrange[[1]])]&),
  Evaluate@Sequence@contours,
  PlotRange -> zrange,
  AspectRatio -> 10,
  FrameTicksStyle->Evaluate@Opt@CTicksStyle,
  PlotRangePadding -> 0,
  FrameLabel -> {{"",""},{"",Style[Opt@CLabel,Opt@CLabelStyle]}},
  (* the empty frame tick here is 
     to align the colorbar with the plot: *)
  FrameTicks -> {frameticks,{{{0,""}},None}}
];
    


(* ::Subsection:: *)
(*Complete the colorbarplot*)


Graphics[
  Inset[Row@cbarside@{plot,colorbar},{0,0},Center],
  ImageSize -> {Automatic, Opt@Height}]


(* ::Text:: *)
(*The end of the InternalColorbarPlot function:*)


]


(* ::Section:: *)
(*Error messages*)


CPadding::wrongdimen := 
  "Wrong input for CPadding. Use \" CPadding -> { horiz , vert } \"";

ColorbarPlot::arrayerr :=
  "Argument must be a valid array.";

ColorbarPlot::dimerr :=
  "Argument must be a rectangular array of at least 2x2.";

ColorbarPlot::minmaxerr :=
  "Could not determine minimum and maximum value of plot data.";

ColorbarPlot::rangeerr :=
  "Could not parse the PlotRange option.";
  


(* ::Section:: *)
(*End*)


End[];
EndPackage[];
