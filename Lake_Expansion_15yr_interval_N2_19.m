% GLACIAL LAKE EXPANSION MODEL IN OVERDEEPENED AREAS
% BASED ON SATELLITE DERIVED EXPANSION RATES
tic

%% Input lake specific information
Lake_Level = 5300; % Input lake level based on average from ASTER GDEM
Expansion_Rate = 0.149863903443; % km2 / 15 yr
    Expansion_Rate_Pixels = round(Expansion_Rate/(30*30*1/1000^2));
Lake_Number = 19; % Number for subset area (N1, N2, etc.), not all lakes
Lake_Year_Start = 2015; % Input starting lake year
Lake_Year_Interval = 15; % Input interval (yrs) of lake expansion rate
Lake_Year_count = Lake_Year_Start;

% Import tif files
Lake_2015 = imread('N2_2015_GlacialLakes_minPt1km2.tif');
    Lake_2015 = double(Lake_2015);
Watershed = imread('N2_Lakes_ASTER_Watershed.tif');
    Watershed = double(Watershed);
Ice = imread('N2_IceThickness_Glabtop2.tif');
    Ice = double(Ice);
DEM = imread('N2_Lakes_ASTER_Elev_overdeepened.tif');
    DEM = double(DEM);
    nrows = size(DEM,1);
    ncols = size(DEM,2);

% Enter tif file data for writing tifs
Tif_Output_FileName = 'N2_LakeYear_2015_2045_N2_19';
Tif_Output_FilePath = 'C:\Dave_Rounce\MATLAB\Nepal_Hazards\Tiff_Files';
Tif_Input_FilePath = Tif_Output_FilePath;
Tif_Input_FileName = 'N2_Lakes_ASTER_Elev_overdeepened.tif';
Tif_pixel_size = 30;


%% Compute the lake distance to the overdeepened areas
% Change Lake and Watershed to binary format (0 = no, 1 = yes)
    Lake_2015(Lake_2015~=Lake_Number) = 0;
    Lake_2015(Lake_2015>0) = 1;
    Watershed(Watershed~=Lake_Number) = 0;
    Watershed(Watershed>0) = 1;

% Create lake year matrix with starting date
    Lake_Year = zeros(nrows,ncols);
    Lake_Year(Lake_2015==1) = Lake_Year_Start;
    
% Remove pixels for DEM and Ice that are outside watershed or lake pixels
    % Remove ice pixels outside of watershed
        Ice(Watershed==0) = 0;
    % Remove ice pixels in the lake
        Ice(Lake_2015>0) = 0;
    % Remove DEM pixels where ice is not present, since the lake can't
    % expand there anyways
        DEM(Ice==0) = 0;
    % Replace DEM pixels with the lake level
        DEM(Lake_2015>0) = Lake_Level;
    
% Identify pixels where the lake can expand (ice and overdeepened)
    Lake_Expansion_Potential = zeros(nrows,ncols);
    Lake_Expansion_Potential(DEM<Lake_Level) = 1;
        % Remove zero values, i.e., pixels that are below the lake level,
        % but don't have ice.
            Lake_Expansion_Potential(DEM==0) = 0;
            Lake_Expansion_Potential_Pixels = sum(sum(Lake_Expansion_Potential));
    
% Compute Lake distance for all the pixels that can expand
    Lake_Dist = bwdist(Lake_2015);
    % Remove distances where lake can't expand
        Lake_Dist(Lake_Expansion_Potential==0) = 0;
    % Change lake distances that are 0 to large number to not interfere
    % with minimum distance codes
        Lake_Dist(Lake_Dist==0) = 999999;
        

%% Lake expansion I
% Refresh the number of expansion rate pixels
    Expansion_Rate_Pixels_count = Expansion_Rate_Pixels;
% Compute what the new lake year is
    Lake_Year_count = Lake_Year_count + Lake_Year_Interval;
% Continue expanding as long as there are still expansion pixels left, 
% i.e., beneath the expansion rate for the given time period, and while 
% there are still overdeepened areas left to expand to 
while Expansion_Rate_Pixels_count > 0 & Lake_Expansion_Potential_Pixels > 0
    % Find position of closest pixels and expand to it
    [I_row,I_col] = ind2sub(size(Lake_Dist),find(Lake_Dist==min(Lake_Dist(:))));
        % Count number of pixels
            I_count = size(I_row,1);
        % Select random pixel to go first
            I_rand = round(rand*(I_count-1)+1);
                % Note: have to subtract one and add one such that you
                % don't get I_rand = 0, which is an invalid row
        % Change this pixel to current lake year
            Lake_Year(I_row(I_rand),I_col(I_rand)) = Lake_Year_count;
            Lake_Dist(I_row(I_rand),I_col(I_rand)) = 999999;
    
    % Update expansion rate pixels left     
        Lake_Expansion_Potential_Pixels = Lake_Expansion_Potential_Pixels - 1;
        Expansion_Rate_Pixels_count = Expansion_Rate_Pixels_count - 1;
end

%% Lake expansion II
% Refresh the number of expansion rate pixels
    Expansion_Rate_Pixels_count = Expansion_Rate_Pixels;
% Compute what the new lake year is
    Lake_Year_count = Lake_Year_count + Lake_Year_Interval;
% Continue expanding as long as there are still expansion pixels left, 
% i.e., beneath the expansion rate for the given time period, and while 
% there are still overdeepened areas left to expand to 
while Expansion_Rate_Pixels_count > 0 & Lake_Expansion_Potential_Pixels > 0
    % Find position of closest pixels and expand to it
    [I_row,I_col] = ind2sub(size(Lake_Dist),find(Lake_Dist==min(Lake_Dist(:))));
        % Count number of pixels
            I_count = size(I_row,1);
        % Select random pixel to go first
            I_rand = round(rand*(I_count-1)+1);
                % Note: have to subtract one and add one such that you
                % don't get I_rand = 0, which is an invalid row
        % Change this pixel to current lake year
            Lake_Year(I_row(I_rand),I_col(I_rand)) = Lake_Year_count;
            Lake_Dist(I_row(I_rand),I_col(I_rand)) = 999999;
    
    % Update expansion rate pixels left     
        Lake_Expansion_Potential_Pixels = Lake_Expansion_Potential_Pixels - 1;
        Expansion_Rate_Pixels_count = Expansion_Rate_Pixels_count - 1;
end

toc

%% Export tif
global Parameters;

Parameters.demAgainFileName = Tif_Output_FileName;
    %This is the output file name!
Parameters.fileOutputPath = Tif_Output_FilePath;

[DEM,Parameters.geospatialMetaData] = read_gdalfiles([Tif_Input_FilePath,'\',Tif_Input_FileName]);
disp( Parameters.geospatialMetaData)

%      :driver
Parameters.geospatialReferenceArray.driver = Parameters.geospatialMetaData.DriverShortName;
%      :name
Parameters.geospatialReferenceArray.name = [Tif_Output_FilePath,'\',Tif_Output_FileName,'.tif'];
%      :ULx
Parameters.geospatialReferenceArray.ULx = Parameters.geospatialMetaData.Corners.UL(1);
% %      :Xinc
Parameters.geospatialReferenceArray.Xinc = Tif_pixel_size;
%      :ULy
Parameters.geospatialReferenceArray.ULy = Parameters.geospatialMetaData.Corners.UL(2);
%      :Yinc
Parameters.geospatialReferenceArray.Yinc = Tif_pixel_size;
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
write_gdalfiles(Lake_Year,Parameters.geospatialReferenceArray)