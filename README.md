# GlacialLakeHazards
Matlab codes from PhD work on glacial lake outburst flood hazards in the Nepal Himalaya.

If using these codes please cite the following study:

# Rounce, D.R., Watson, C.S., and McKinney, D.C.: Identification of hazard and risk for glacial lakes in the Nepal Himalaya using satellite imagery from 2000–2015, Remote Sensing, 9(654):1-19, doi:10.3390/rs9070654, 2017.

Additional information:
N1-6 refer to sections of Nepal based on Landsat images (6 Landsat images span the width of Nepal) from East to West.
The DEMs and Landsat imagery used in the scripts is all publicly available.  The specific steps used to process the lakes are as follows:

1. NDWI for clear sky images from Fall/Winter 2000 and Fall/Winter 2015
2. Clip tool - clip images for faster processing of contours
3. Contour tool - step size of 0.025 to help automate lake delineations
4. "Select Features" - select the contour associated with each lake based on Band 8 and the NDWI image
  a. For lakes that have grown greatly, select contours for 2000 and 2015 that have approximately the same width (if appropriate)
  b. For lakes that are in shadows, use GoogleEarth or other images (e.g., WorldView) to manually delineate the lake
5. Feature to Polygon tool - exports the contour lines into a polygon
6. Merge (Data management) tool - merge all lake polygons into a single layer (do this for each Landsat region: N1-6 in this study)
7. Add polygons outside the bounds such that you have the same extent as the avalanche trajectories (clip these out later)
8. Polygon to Raster tool - convert polygons to raster for use with the hazard trajectories (use a small pixel size - 1 m in this study)
9. Project raster tool - align polygons and resample to spatial scale for agreement with avalanche trajectories (use projection point, pixel size, and nearest neighbor sampling)
10. Reclassify tool - reclassify polygons such that "NoData" and additional polygons from step 7 become "0" (requires to reclassifications)
11. Clip tool - clip lake raster such that it's the same extent (rows and columns) as the avalanche trajectories

(Now need to create Watersheds.  This step is not necessary, but it speeds up the hazard trajectory modeling because it enables the trajectories to only be done on prone areas that could potentially enter the lake as opposed to doing this for the entire Landsat scene.)
12. Reclassify tool - relcassify the lake raster from step 11 such that values of "0" are "NoData" as this is needed for the Watershed tool.  Call this "Watershed_raw"
13. Watershed tool - create a raster of watersheds for each lake such that avalanches and rockfalls in basins without lakes are not modeled. Use the "Watershed_raw" and flow direction (flow direction needs to be computed from a filled DEM to avoid errors)
14. Export Watershed, but select NoData as 0 during the export (this way you don't have to worry about NoData values in the Matlab scripts

(Lake work not complete)
15. Raster to other tool - export rasters for use with Matlab (make sure that NoData is set to 0)

Additional notes:
- Check the mass movement trajectories to ensure that the DEM and Landsat images are properly lined up at high elevations.  It's possible that they are not perfectly aligned, which can cause a prone area to fall down the wrong side of the ridge.  While this does not commonly occur, it's important to check.
- The prone area files in the Matlab scripts are binary (1 = prone area, 0 = not prone)

