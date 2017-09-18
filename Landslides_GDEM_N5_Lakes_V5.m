%% Avalanche Trajectory script:
% Assesses the trajectory of avalanche prone areas using similar methods to
% Huggel et al. (2004) with a specified threshold (typically 17 degrees)
    
tic

%% Import DEM, Prone Areas, and Flow Accumulation
    Lake_Table = xlsread('N5_Lakes_AvalancheResults_Pt1km2_V4.xls');
        n_Lakes = size(Lake_Table,1);
    DEM = imread('N5_ASTER_Elev.tif');
        DEM = double(DEM);
        nrows = size(DEM,1);
        ncols = size(DEM,2);
    FlowDir = imread('N5_ASTER_FlowDir.tif');
        FlowDir = double(FlowDir);
            % Values of flow direction
                %   1 - Right
                %   2 - Down-Right 
                %   4 - Down
                %   8 - Down-Left
                %  16 - Left
                %  32 - Up-Left
                %  64 - Up
                % 128 - Up-Right
    ProneArea = imread('N5_nonGlacier_LandslideProne.tif');
        ProneArea = double(ProneArea);
        ProneArea_Raw = ProneArea;
    Watershed = imread('N5_ASTER_Watershed_V4_raster.tif');
        Watershed = double(Watershed);
    Lake = imread('N5_2015_GlacialLakes_minPt1km2_V4_raster.tif');
        Lake = double(Lake);
    FileName_Prefix = 'N5_V4';
    pixel_size = 30;
    
    DEM(DEM<0) = -9.99;
    FlowDir(FlowDir>128) = -9.99;
    ProneArea(ProneArea~=1) = 0;
    ProneArea(Watershed==0) = 0;
    
%% Set parameters
    Slope_Threshold_min = 23; % degrees
    Landslide_Depth = 4; % m (Collins and Gibson 2015, Dahal etal 2008)
    Landslide_MinHeight_aboveLake = 50;
    Direct_Threshold = 90; % degrees (+/- 45 degrees from primary axis of lake)
    Percent_Threshold = 100;
    Landslide_Volume_Threshold = 0.1*10^6;
        
% Enter tif file data for writing tifs
Tif_Output_FileName = 'N5_GDEM_RockfallTrajectories_4m_V4';
Tif_Output_FilePath = 'C:\Dave_Rounce\MATLAB\Nepal_Hazards\Tiff_Files';
Tif_Input_FilePath = Tif_Output_FilePath;
Tif_Input_FileName = 'N5_ASTER_Elev.tif';
    
 %% Compute focal statistics at varying lengths to determine the size of rockfall at each pixel.

 % Compute focal statistics
    ProneArea_PixPercentage = zeros(nrows,ncols) + 100;
    Focal_Size = zeros(nrows,ncols);
    Focal_Size_Sum = zeros(nrows,ncols);
    Focal_Size_Sum_Max = zeros(nrows,ncols);
    ProneArea(1:14,:) = 0;
    ProneArea(:,1:14) = 0;
    ProneArea(nrows-14:nrows,:) = 0;
    ProneArea(:,ncols-14:ncols) = 0;
    
for r = 1:nrows
     for c = 1:ncols
         if ProneArea(r,c) > 0
            % Here is the percent threshold
            while ProneArea_PixPercentage(r,c) >= Percent_Threshold
                Focal_Size(r,c) = Focal_Size(r,c) + 1;
                    % Focal size refers to the number of pixels around the
                    % center that is included as shown below by the max.
                Focal_Size_Sum(r,c) = 0;
                Focal_Size_Sum_Max(r,c) = (Focal_Size(r,c)+1)^2;
                    % 1 - 2x2 - 4
                    % 2 - 3x3 - 9
                    % 3 - 4x4 - 16
                    % 4 - 5x5 - 25, etc.
                % Comupute # of avalanche prone pixels in the focal area
                for ii = 0:1:Focal_Size(r,c)
                    for jj = 0:1:Focal_Size(r,c)
                        if ProneArea(r+ii,c+jj) > 0
                            Focal_Size_Sum(r,c) = Focal_Size_Sum(r,c) + 1;
                        end
                    end
                end
                
                % Compute prone area pixel percentage and apply threshold
                ProneArea_PixPercentage(r,c) = Focal_Size_Sum(r,c)/Focal_Size_Sum_Max(r,c)*100;
                    % If you meet the threshold, then update the prone area
                    if ProneArea_PixPercentage(r,c) >= Percent_Threshold
                        ProneArea(r,c) = Focal_Size_Sum(r,c);
                    end
                % end while loop if get to 13 because its the volume
                % equivalent of a 17 degree trajectory
                    if Focal_Size(r,c) == 13
                        ProneArea_PixPercentage(r,c) = 0;
                    end
            end
         end
     end
 end

 % Remove pixels that are less than 50 m above the lake
for i = 1:n_Lakes
    for r = 1:nrows
        for c = 1:ncols
            Lake_Number = Lake_Table(i,2);
            if Watershed(r,c) == Lake_Number & ProneArea(r,c) > 0 & DEM(r,c) < (Lake_Table(i,5) + Landslide_MinHeight_aboveLake)
                ProneArea(r,c) = 0;
            end
        end
    end
end

% Remove pixels that are below size threshold
Landslide_Volume = ProneArea*pixel_size^2*Landslide_Depth;
ProneArea(Landslide_Volume < Landslide_Volume_Threshold) = 0;
Landslide_Volume(Landslide_Volume < Landslide_Volume_Threshold) = 0;
 
%% Compute landslide path using average slope threshold
    Slope_path = zeros(nrows,ncols);
    Landslide_Trajectory = zeros(nrows,ncols);
    Landslide_Trajectory_Length = zeros(nrows,ncols);
    Landslide_Trajectory_plot = zeros(nrows,ncols);
    Slope_path_deg = zeros(nrows,ncols);
    Landslide_Hit_LakeNumber = zeros(nrows,ncols);
    Landslide_Hit_Aspect = zeros(nrows,ncols);
    Landslide_Hit_row = zeros(nrows,ncols);
    Landslide_Hit_col = zeros(nrows,ncols);
    Landslide_Hit_Slope = zeros(nrows,ncols);
    Landslide_Hit_Volume = zeros(nrows,ncols);
    
    Slope_Threshold_deg = zeros(nrows,ncols) + Slope_Threshold_min;
        
    for r = 1:nrows
        for c = 1:ncols

            if ProneArea(r,c) > 0
                Landslide_Trajectory(r,c) = 1;
                    % The starting point of the landslide has a value of 1
                r_start = r;
                c_start = c;

                % Find direction of track
                    if FlowDir(r,c) == 1
                        r_dir = 0;
                        c_dir = 1;
                        pixel_distance = pixel_size;
                    elseif FlowDir(r,c) == 2
                        r_dir = 1;
                        c_dir = 1;
                        pixel_distance = (pixel_size^2+pixel_size^2)^0.5;
                    elseif FlowDir(r,c) == 4
                        r_dir = 1;
                        c_dir = 0;
                        pixel_distance = pixel_size;
                    elseif FlowDir(r,c) == 8
                        r_dir = 1;
                        c_dir = -1;
                        pixel_distance = (pixel_size^2+pixel_size^2)^0.5;
                    elseif FlowDir(r,c) == 16
                        r_dir = 0;
                        c_dir = -1;
                        pixel_distance = pixel_size;
                    elseif FlowDir(r,c) == 32
                        r_dir = -1;
                        c_dir = -1;
                        pixel_distance = (pixel_size^2+pixel_size^2)^0.5;
                    elseif FlowDir(r,c) == 64
                        r_dir = -1;
                        c_dir = 0;
                        pixel_distance = pixel_size;
                    elseif FlowDir(r,c) == 128
                        r_dir = -1;
                        c_dir = 1;
                        pixel_distance = (pixel_size^2+pixel_size^2)^0.5;
                    end

                % Compute slope between original pixel and pixel downstream
                    r_path = r + r_dir;
                    c_path = c + c_dir;
                    Landslide_Trajectory_Length(r_start,c_start) = Landslide_Trajectory_Length(r_start,c_start) + pixel_distance;

                    Slope_path(r_start,c_start) = atan((DEM(r_start,c_start) - DEM(r_path,c_path))/Landslide_Trajectory_Length(r_start,c_start));
                    Slope_path_deg(r_start,c_start) = Slope_path(r_start,c_start)*180/pi();


                while Slope_path_deg(r_start,c_start) > Slope_Threshold_deg(r,c) & r_path > 1 & r_path < nrows & c_path > 1 & c_path < ncols
                    Landslide_Trajectory(r_path,c_path) = Landslide_Trajectory(r_path,c_path) + 1;

                    if FlowDir(r_path,c_path) == 1
                        r_dir = 0;
                        c_dir = 1;
                        pixel_distance = pixel_size;
                    elseif FlowDir(r_path,c_path) == 2
                        r_dir = 1;
                        c_dir = 1;
                        pixel_distance = (pixel_size^2+pixel_size^2)^0.5;
                    elseif FlowDir(r_path,c_path) == 4
                        r_dir = 1;
                        c_dir = 0;
                        pixel_distance = pixel_size;
                    elseif FlowDir(r_path,c_path) == 8
                        r_dir = 1;
                        c_dir = -1;
                        pixel_distance = (pixel_size^2+pixel_size^2)^0.5;
                    elseif FlowDir(r_path,c_path) == 16
                        r_dir = 0;
                        c_dir = -1;
                        pixel_distance = pixel_size;
                    elseif FlowDir(r_path,c_path) == 32
                        r_dir = -1;
                        c_dir = -1;
                        pixel_distance = (pixel_size^2+pixel_size^2)^0.5;
                    elseif FlowDir(r_path,c_path) == 64
                        r_dir = -1;
                        c_dir = 0;
                        pixel_distance = pixel_size;
                    elseif FlowDir(r_path,c_path) == 128
                        r_dir = -1;
                        c_dir = 1;
                        pixel_distance = (pixel_size^2+pixel_size^2)^0.5;
                    end

                % Move the trajectory downhill according to the direction:
                    r_path = r_path + r_dir;
                    c_path = c_path + c_dir;
                    Landslide_Trajectory_Length(r_start,c_start) = Landslide_Trajectory_Length(r_start,c_start) + pixel_distance;
                    
                % Compute slope between original pixel and trajectory
                    Slope_path(r_start,c_start) = atan((DEM(r_start,c_start) - DEM(r_path,c_path))/Landslide_Trajectory_Length(r_start,c_start));
                    Slope_path_deg(r_start,c_start) = Slope_path(r_start,c_start)*180/pi();

                    if Lake(r_path,c_path) > 0 & Slope_path_deg(r_start,c_start) > Slope_Threshold_deg(r,c) & Landslide_Hit_LakeNumber(r_start,c_start) == 0
                        % Record the lake number that it hits:
                            Landslide_Hit_LakeNumber(r_start,c_start) = Lake(r_path,c_path);
                        % Compute the slope & Aspect at which the avalanche first enters the lake
                            Landslide_Hit_Slope(r_start,c_start) = Slope_path_deg(r_start,c_start);
                            Landslide_Hit_row(r_start,c_start) = r_path;
                            Landslide_Hit_col(r_start,c_start) = c_path;
                            Landslide_Hit_Aspect(r_start,c_start) = mod(-1*atan((r_path-r_start)/(c_path-c_start))+90,360)*180/pi();
                                % Convert aspect from unit angle (0 deg being east; counterclockwise) to cardinal direction (0 deg being north; clockwise)
                                % Hence use mod(-theta+90,360)*180/pi() = Aspect in degrees!
                            Landslide_Hit_Volume(r_start,c_start) = Landslide_Volume(r_start,c_start);
                    end
                end
            end
        end
    end
    
    % Record landslide trajectories to plot
    Landslide_Trajectory_plot(Landslide_Trajectory>0) = 1;
    
    %% Calculate how many landslides hit the lake, hit it directly (within 45 degrees of primary axis of the lake)
        for i = 1:n_Lakes
            for r = 1:nrows
                for c = 1:ncols

%                     if Landslide_Hit_LakeNumber(r,c) == Lake_Table(i,2) & DEM(r,c) > (Lake_Table(i,5) + Landslide_MinHeight_aboveLake);
                    if Landslide_Hit_LakeNumber(r,c) == Lake_Table(i,2) & DEM(r,c) > (Lake_Table(i,5));
                        % Count the total landslide pixels that hit each lake
                            Lake_Table(i,19) = Lake_Table(i,19) + 1;
                            % Record maximum volume of all hits
                                if Landslide_Hit_Volume(r,c) > Lake_Table(i,21)
                                    Lake_Table(i,21) = Landslide_Hit_Volume(r,c);
                                end
                            
                        % Count direct hits based on the aspect of the lake and the initial landslide area
                            if (abs(Lake_Table(i,6) - Landslide_Hit_Aspect(r,c)) < Direct_Threshold/2) | (mod(Lake_Table(i,6) + Landslide_Hit_Aspect(r,c), 360) < Direct_Threshold/2)
                                % mod statement needed to deal with aspects surrounding north
                               Lake_Table(i,20) = Lake_Table(i,20) + 1; 
%                                 Lake_Table(i,11) = Lake_Table(i,11) + 1;
                              % Record maximum volume hit of direct hit
                                if Landslide_Hit_Volume(r,c) > Lake_Table(i,22)
                                    Lake_Table(i,22) = Landslide_Hit_Volume(r,c);
                                end
                            end
                    end
                end
            end
        end

% % Export tif
%     global Parameters;
% 
%     Parameters.demAgainFileName = Tif_Output_FileName;
%         %This is the output file name!
%     Parameters.fileOutputPath = Tif_Output_FilePath;
% 
%     [DEM,Parameters.geospatialMetaData] = read_gdalfiles([Tif_Input_FilePath,'\',Tif_Input_FileName]);
%     disp( Parameters.geospatialMetaData)
% 
%     %      :driver
%     Parameters.geospatialReferenceArray.driver = Parameters.geospatialMetaData.DriverShortName;
%     %      :name
%     Parameters.geospatialReferenceArray.name = [Tif_Output_FilePath,'\',Tif_Output_FileName,'.tif'];
%     %      :ULx
%     Parameters.geospatialReferenceArray.ULx = Parameters.geospatialMetaData.Corners.UL(1);
%     % %      :Xinc
%     Parameters.geospatialReferenceArray.Xinc = pixel_size;
%     %      :ULy
%     Parameters.geospatialReferenceArray.ULy = Parameters.geospatialMetaData.Corners.UL(2);
%     %      :Yinc
%     Parameters.geospatialReferenceArray.Yinc = pixel_size;
%     %      :Reg
%     %Parameters.geospatialReferenceArray.Reg = '';
%     %      :Flip
%     Parameters.geospatialReferenceArray.Flip = 1;
%     %      :Geog
%     Parameters.geospatialReferenceArray.Geog = 1;
%     %      :projWKT
%     Parameters.geospatialReferenceArray.projWKT = Parameters.geospatialMetaData.ProjectionRef;
%     %      :meta
%     Parameters.geospatialReferenceArray.meta = Parameters.geospatialMetaData.Metadata{1};
% 
% 
%     % calling the write function
%     write_gdalfiles(Landslide_Trajectory_plot,Parameters.geospatialReferenceArray)
% 
% % Write the landslide hit spots to a ASCII file - good for seeing what
% % areas need to be looked at in further detail.
%     Output_FileName_LandslideHit_LakeNumber = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_LandslideHit_LakeNumber','.csv'];
%     csvwrite(Output_FileName_LandslideHit_LakeNumber,Landslide_Hit_LakeNumber)
%     Output_FileName_LandslideHit_Slope = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_LandslideHit_Slope','.csv'];
%     csvwrite(Output_FileName_LandslideHit_Slope,Landslide_Hit_Slope)
%     Output_FileName_LandslideHit_Aspect = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_LandslideHit_Aspect','.csv'];
%     csvwrite(Output_FileName_LandslideHit_Aspect,Landslide_Hit_Aspect)
%     Output_FileName_LandslideTrajectory = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_LandslideTrajectory','.csv'];
%     csvwrite(Output_FileName_LandslideTrajectory, Landslide_Trajectory_plot)
%     
%     Output_FileName_LakeTable = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'LakeTable_Landslide','.csv'];
%     csvwrite(Output_FileName_LakeTable,Lake_Table)

toc