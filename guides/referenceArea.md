# BInSAR -- Selecting the Reference Area

## Introduction

There are many sources of error in InSAR data. Uncertainties in the orbital position of the satellite and radar delays in the ionosphere and the troposphere contribute to long-wavelength noise contributions in interferograms. These noise terms are typically of such high amplitude that any signal of long-wavelength surface motion is unrecoverable in any individual interferogram. 

Best practice when working with interferograms is to **reference** the data to a location in the scene that is known to be experiencing no deformation, or else to a GNSS station whose displacement is a known quantity. Traditionally, this means subtracting the value of the interferogram at the reference station from the entirety of the interferogram. More advanced techniques ([GInSAR](https://doi.org/10.1109/TGRS.2019.2934118)) reference the interferogram to a long-wavelength polynomial fit to an array of GNSS stations. 

This library takes inspiration from the GInSAR technique by detrending interferograms relative to a reference area of arbitrary shape or size. This technique is particularly useful when a physical signal is known to exist in a relatively compact region -- for example, an area of known subsidence. By selecting a reference region surrounding the signal area, and detrending the interferograms relative to that whole region, the number of pixels used to estimate the long-wavelength component of noise is maximized. This results in high levels of noise suppression without any loss of signal.

## Creating and Importing the Reference Area

The reference area can be chosen in many ways, corresponding to the needs of the user. Here are a few examples of possible methods:
* Manual selection of a polygon in Google Earth Pro
* Elevation contours
* Small circles surrounding a set of GNSS stations

Multiple avenues from within the BInSAR library are available to create and import the reference polygon:

1. To manually select a polygon of the reference area in Google Earth Pro, follow the `referenceFromGoogleEarth.m` workflow (PLANNED).

2. To import a polygon from a CSV, follow the `referenceFromCSV.m` workflow (PLANNED).

3. Custom import methods are encouraged as benefits the user. Use the following formatting requirements to be compatible with BInSAR:
    1. The region must be specified by two MATLAB vectors of the vertex positions in latitude (`referenceLatitude`) and longitude (`referenceLongitude`).
    2. Multiple polygons are supported: the vectors should have a NaN value separating them.
    2. Longitudes west of the Prime Meridian should be negative (e.g. 120&deg;W should be written as -120, not 240).

    As an example, here is a region comprising a triangle and a quadrilateral, written in MATLAB directly.
    ```
    referenceLongitude= [-120 -120 -121 nan -118 -119 -119 -118.5];
    referenceLatitude= [30 31 31 nan 32.5 32.5 33.5 33.5];
    ```

## Iterating the Reference Area

Because you do not necessarily know the surface motion of the study area in advance (after all, that is why this library exists), a poorly chosen reference area may contain significant surface motions. 

Not all is lost, however. Simply make your best guess the first time, then run the workflow. If you see problematic displacements in the reference area in the workflow output, modify the reference area to accommodate, then run the workflow again. 