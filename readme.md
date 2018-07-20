# ER Network Analysis
Laurie Young and Marcus Fantham
Accepted for publication in Nature Cell Biology, 2018

### System requirements
MATLAB
(Tested on version 2017b, Windows 10)

### Installation guide
Download this repository and run 'ER_network_analysis' in MATLAB

### Demo
A skeletonised ER network, skeleton-demo.tif, is included in this repository.

Run the ER_network_analysis script, and select the skeleton-demo.tif in the file chooser.

The script will produce a folder called "analysisOutput", containing histograms of tubule length, the histogram data as a .mat file, and a .tif image with nodes and endpoints highlighted.

On a laptop with an Intel i5-7200U processor, analysis takes ~3 seconds per frame, so ~2.5 minutes for the 50-frame demo image.

### Your data
Input data should be a binary image stack, stored as a TIFF, of a skeletonised ER network. This can be produced from a microscope image in ImageJ/FIJI by combining thresholding and the "Skeletonize" command, found under Process > Binary > Skeletonize.

Run the ER_network_analysis script, and select your skeletonised data. Output will be in the subfolder "analysisOutput".

### License
This software is licensed under a Creative Commons Attribution 4.0 International License, which permits use, sharing, adaptation, distribution and reproduction in any medium or format, as long as you give appropriate credit to the original author(s) and the source, provide a link to the Creative Commons license, and indicate if changes were made. To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/
