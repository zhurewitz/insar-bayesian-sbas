# BInSAR - Bayesian Displacement Timeseries Estimation for InSAR

## Introduction

Bayesian Displacement Timeseries Estimation for InSAR (**BInSAR**) is a library written in MATLAB to process NISAR-formatted interferometric data products. **BInSAR** is specifically designed to estimate temporally smooth surface displacement signals, such as those resulting from groundwater movement. 

**BInSAR** contains powerful features for generation and analysis of displacement timeseries in InSAR, including:

* A Bayesian mathematical framework, including uncertainty quantification of the SBAS inversion

* Data-driven tropospheric noise rejection 

* The ability to combine multiple look geometries into a 3D timeseries of displacement

* The ability to compare multiple look geometries against each other or against GNSS displacement timeseries

* Compatibility with the data product format for the upcoming NISAR mission



## Getting Started

### Requirements

You will need the following:
* [MATLAB](https://www.mathworks.com/products/matlab.html) and a MATLAB license
* A [NASA Earthdata](https://www.earthdata.nasa.gov/) account
* An [OpenTopography](https://opentopography.org/) account
* A [GitHub](https://github.com/) account
* Sufficient hard drive storage space for the data products

### Installation

The fast installation instructions are as follows: 
1. Clone this library and the [`matlab-fast-geometry`](https://github.com/zhurewitz/matlab-fast-geometry) library into a dedicated MATLAB-specific `Libraries` directory separate from your intended MATLAB work directory.
2. Add all folders and subfolders of `Libraries` to your MATLAB path.

For more detailed installation instructions, see the [INSTALL.md](INSTALL.md) file.

### Data Download

<img src="images/vertex.png" width=1000>

Interferograms in NISAR format are archived and can be downloaded from the Alaska Satellite Facility's (ASF) [Vertex](https://search.asf.alaska.edu/#/?dataset=SENTINEL-1%20INTERFEROGRAM%20(BETA)) website. At the present, they are only available over a few limited regions for calibration and validation purposes. You will need a [NASA Earthdata](https://www.earthdata.nasa.gov/) account to download data products. 



1. Select a bounding box for your study area, consisting of a south and north latitude and a west and east longitude. 

2. Select interferogram tracks. The code is not guaranteed to work if there is only a tiny sliver of overlap between the study region and the interferogram track, so it is important to manually determine suitable tracks. If desired, expand the bounding box to accomodate tracks which barely intersect. 

    1. Copy the [areaOfInterest_template.m](templates/areaOfInterest_template.m) script from the `template` directory to your project directory and rename as desired. In MATLAB, fill it out and run. The displayed text ("POLYGON...") will be copied to your clipboard.

    3. On the ASF Vertex website, in the dataset menu, select "ARIA S1 GUNW". Click the Filters icon and paste the text into the Area of Interest box. 

        * Do NOT select anything for the "File Type" filter, as there is a bug which prevents reading of data after 2022 (as of June 2024).

    4. Select update. Note down all the interferogram paths/tracks which intersect the bounding box with significant overlap. 

3. Copy the `dataDownload_template.m` script to your project directory and rename as desired. In MATLAB, fill it out and run. 

    You will need to provide:

    * The full path to your data directory. A set of interferogram products can easily take up 100s of Gb of memory, so a directory in an external hard drive is recommended for some users. 

    * The latitude and longitude limits of your study area. 

    * The start and end date of your desired output timeseries. 

    * The tracks you selected in the previous step.

### Processing

Copy the `workflow_template.m` script into your project directory and rename as desired. Fill it out and run. 

You will need to provide:

* The full paths to your data directories.

* The full path to a suitable work/save directory for the intermediate processing steps and output. A directory on an external hard drive is recommended for some users. 

* The bounding limits of your study area. 

* The vertices of a polygon demarking the your [reference area](guides/referenceArea.md).

* The vertices of a polygon demarking the coastline. 

* Your OpenTopography API key.