close all
clear all
clc

% Must run Lake_Area_Export with the gdal_2.0 folder - and mex folder open!!
% If plotting not working, check that no scripts have CLEAR OR CLC

global Parameters;

Parameters.demAgainFileName = 'Imja_AvalancheTrajectories_2500m2_Unobstructed';
    %This is the output file name!
Parameters.fileOutputPath = 'C:\Dave_Rounce\Matlab_Files_for_Export\Glacier_Hazard\Tiff_Files';

[Avalanche_Trajectory,Parameters.geospatialMetaData] = read_gdalfiles('C:\Dave_Rounce\Matlab_Files_for_Export\Glacier_Hazard\Tiff_Files\Imja_AvalancheProne_DEM.tif');
disp( Parameters.geospatialMetaData)

% Do all calcs and manipulations here
Imja_AvalancheTrajectory

% figure
% imagesc(Lake_Reference)
% title('my data')

%disp( Parameters.geospatialMetaData)
%disp(Parameters.geospatialMetaData.ProjectionRef)


%      :driver
Parameters.geospatialReferenceArray.driver = Parameters.geospatialMetaData.DriverShortName;
%      :name
Parameters.geospatialReferenceArray.name = ['C:\Dave_Rounce\Matlab_Files_for_Export\Glacier_Hazard\Tiff_Files\Imja_AvalancheTrajectories_2500m2_Unbstructed','.tif'];
%      :ULx
Parameters.geospatialReferenceArray.ULx = Parameters.geospatialMetaData.Corners.UL(1);
%      :Xinc
Parameters.geospatialReferenceArray.Xinc = 5;
%      :ULy
Parameters.geospatialReferenceArray.ULy = Parameters.geospatialMetaData.Corners.UL(2);
%      :Yinc
Parameters.geospatialReferenceArray.Yinc = 5;
%      :Reg
%Parameters.geospatialReferenceArray.Reg = '';
%      :Flip
Parameters.geospatialReferenceArray.Flip = 1;
%      :Geog
Parameters.geospatialReferenceArray.Geog = 1;
%      :projWKT
Parameters.geospatialReferenceArray.projWKT = Parameters.geospatialMetaData.ProjectionRef;
%      :meta
Parameters.geospatialReferenceArray.meta = Parameters.geospatialMetaData.Metadata{1};


% calling the write function
write_gdalfiles(Avalanche_Trajectory,Parameters.geospatialReferenceArray)


