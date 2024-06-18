# BInSAR - Bayesian SBAS Timeseries Estimation for InSAR



## Getting Started



### Prerequisites

### Installation

1. Make your favorite version of the following directory structure in your MATLAB work directory.

    ```
    MATLAB
    ├── Libraries
    └── Work
        └── ProjectName
    ```

1. Clone this repository into the `Libraries` directory. Do the same with the [`matlab-fast-geometry`](https://github.com/zhurewitz/matlab-fast-geometry) library. Your directory structure should now look something like:
      ```
    MATLAB
    ├── Libraries
    │   ├── insar-bayesian-sbas
    │   │   ├── workflow_template.m
    │   │   ├── +flow
    │   │   │   └── ...
    │   │   └── ...
    │   └── matlab-fast-geometry
    │       ├── inpolygonfast.m
    │       └── ...
    └── Work
        └── ProjectName
    ```

1. Open MATLAB and navigate to the `MATLAB` working directory. In the **Current Folder** tab, right click on the `Libraries` folder and add selected folders and subfolders as shown below.
        <img src="images/addToPath.png" width=500>