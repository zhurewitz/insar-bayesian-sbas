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
1. Clone this library into a dedicated `Libraries` directory separate from your intended MATLAB project directory.
2. Add this library to your MATLAB path.

For more detailed installation instructions, see the [INSTALL.md](INSTALL.md) file.

### Data Download

<img src="images/vertex.png" width=1000>

Interferograms in NISAR format are archived and can be downloaded from the Alaska Satellite Facility's (ASF) [Vertex](https://search.asf.alaska.edu/#/?dataset=SENTINEL-1%20INTERFEROGRAM%20(BETA)) website. At the present, they are only available over a few limited regions for calibration and validation purposes. You will need a [NASA Earthdata](https://www.earthdata.nasa.gov/) account to download data products. 

BInSAR provides a set of visual workflows for data download and processing, designed to be accessible with only minimal programming experience. To get started:

1. Make a local directory for the code for this project and navigate to it in the MATLAB `Current Folder` tab.

2. In MATLAB's command window, type `startUp`. This function will copy the workflow template files and open the first step.

3. Follow along the workflows!

### Processing

Copy the `workflow_template.m` script into your project directory and rename as desired. Fill it out and run. 

You will need to provide:

* The full paths to your data directories.

* The full path to a suitable work/save directory for the intermediate processing steps and output. A directory on an external hard drive is recommended for some users. 

* The bounding limits of your study area. 

* The vertices of a polygon demarking the your [reference area](guides/referenceArea.md).

* Your OpenTopography API key.