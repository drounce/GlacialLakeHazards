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
    ProneArea = imread('N5_GlaciersProne.tif');
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
    
% Enter tif file data for writing tifs
Tif_Output_FileName = 'N5_GDEM_AvalancheTrajectories_10_30_50m_V4';
Tif_Output_FilePath = 'C:\Dave_Rounce\MATLAB\Nepal_Hazards\Tiff_Files';
Tif_Input_FilePath = Tif_Output_FilePath;
Tif_Input_FileName = 'N5_ASTER_Elev.tif';
    
%% Set parameters
    Slope_Threshold_Min = 20; % degrees
    Direct_Threshold = 90; % degrees (+/- 45 degrees from primary axis of lake)
    Avalanche_Depth_Matrix = [10,30,50]; % meters
    Percent_Threshold = 100;
    Avalanche_Volume_Threshold = 0.1*10^6; %(Richardson and Reynolds, 2000; Worni et al., 2014; Somos-Valenzuela et al., 2016)
    % Run for 3 avalanche depths: 10m, 30m, 50m (Huggel et al., 2004 & 2005) 
        Avalanche_Trajectory_10m = zeros(nrows,ncols);
        Avalanche_Trajectory_30m = zeros(nrows,ncols);
        Avalanche_Trajectory_50m = zeros(nrows,ncols);
        Avalanche_Trajectory_plot = zeros(nrows,ncols);
    
 %% Compute focal statistics at varying lengths to determine the size of avalanche at each pixel.
 % The size of avalanche (# pixels) will dictate the runout length (Huggel et al., 2004) 
 %   -  max length is 13 as 13x13 avalanche exceeds 17 deg threshold
 %   -  assumes cautious/conservative ice depth of 50 m
 
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
             
%% Compute avalanche path using average slope threshold
for n_Depth = 1:size(Avalanche_Depth_Matrix,2)
    Avalanche_Depth = Avalanche_Depth_Matrix(1,n_Depth);
    disp(Avalanche_Depth)
    
        Slope_path = zeros(nrows,ncols);
        Avalanche_Trajectory = zeros(nrows,ncols);
        Slope_path_deg = zeros(nrows,ncols);
        Avalanche_Hit_LakeNumber = zeros(nrows,ncols);
        Avalanche_Hit_Aspect = zeros(nrows,ncols);
        Avalanche_Hit_row = zeros(nrows,ncols);
        Avalanche_Hit_col = zeros(nrows,ncols);
        Avalanche_Hit_Slope = zeros(nrows,ncols);
        Avalanche_Hit_Volume = zeros(nrows,ncols);
        Avalanche_Trajectory_Length = zeros(nrows,ncols);
        
    % Compute Slope Threshold as a function of avalanche size
        Avalanche_Volume = Avalanche_Depth.*(ProneArea*pixel_size^2);         
        Slope_Threshold_rad = atan((1.111-0.118*log10(Avalanche_Volume)));
            Slope_Threshold_rad(ProneArea==0) = 0;
        Slope_Threshold_deg = Slope_Threshold_rad*180/pi();
        % Trajectory cannot extend beyond the slope threshold,
        % which in most cases is 17 degrees.
        Slope_Threshold_deg(Slope_Threshold_deg<Slope_Threshold_Min) = Slope_Threshold_Min;
            Slope_Threshold_deg(ProneArea==0) = 0;
    
    for r = 1:nrows
        for c = 1:ncols
            
            % Model trajectory and apply avalanche volume threshold
            if ProneArea(r,c) > 0 & Avalanche_Volume(r,c) > Avalanche_Volume_Threshold       
                r_start = r;
                c_start = c;
                Avalanche_Trajectory_Length(r_start,c_start) = 0;
                
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
                    Avalanche_Trajectory_Length(r_start,c_start) = Avalanche_Trajectory_Length(r_start,c_start) + pixel_distance;

                    Slope_path(r_start,c_start) = atan((DEM(r_start,c_start) - DEM(r_path,c_path))/Avalanche_Trajectory_Length(r_start,c_start));
                    Slope_path_deg(r_start,c_start) = Slope_path(r_start,c_start)*180/pi();

                while Slope_path_deg(r_start,c_start) > Slope_Threshold_deg(r,c) & r_path > 1 & r_path < nrows & c_path > 1 & c_path < ncols
                    Avalanche_Trajectory(r_path,c_path) = Avalanche_Trajectory(r_path,c_path) + 1;

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
                    Avalanche_Trajectory_Length(r_start,c_start) = Avalanche_Trajectory_Length(r_start,c_start) + pixel_distance;
                    
                % Compute slope between original pixel and trajectory
                    Slope_path(r_start,c_start) = atan((DEM(r_start,c_start) - DEM(r_path,c_path))/Avalanche_Trajectory_Length(r_start,c_start));
                    Slope_path_deg(r_start,c_start) = Slope_path(r_start,c_start)*180/pi();

                    if Lake(r_path,c_path) > 0 & Slope_path_deg(r_start,c_start) > 17 & Avalanche_Hit_LakeNumber(r_start,c_start) == 0
                        % Record the lake number that it hits:
                            Avalanche_Hit_LakeNumber(r_start,c_start) = Lake(r_path,c_path);
                        % Record the total volume from that pixel that hits: 
                            Avalanche_Hit_Volume(r_start,c_start) = Avalanche_Volume(r_start,c_start);
                                % Note this includes surrounding pixels -
                                % vulnerable avalanche area should be reported and
                                % maximum avalanche size should also be reported
                        % Compute the slope & Aspect at which the avalanche first enters the lake
                            Avalanche_Hit_Slope(r_start,c_start) = Slope_path_deg(r_start,c_start);
                            Avalanche_Hit_row(r_start,c_start) = r_path;
                            Avalanche_Hit_col(r_start,c_start) = c_path;
                            Avalanche_Hit_Aspect(r_start,c_start) = mod(-1*atan((r_path-r_start)/(c_path-c_start))+90,360)*180/pi();
                                % Convert aspect from unit angle (0 deg being east; counterclockwise) to cardinal direction (0 deg being north; clockwise)
                                % Hence use mod(-theta+90,360)*180/pi() = Aspect in degrees!
                    end
                end
            end
        end
    end
    
    % Record avalanche trajectories for each depth
    Avalanche_Trajectory_plot(Avalanche_Trajectory>0) = Avalanche_Depth;

    if Avalanche_Depth == 10
        Avalanche_Trajectory_10m = Avalanche_Trajectory_plot;
        Avalanche_Hit_Volume_Export_10m = Avalanche_Hit_Volume;
        Avalanche_Hit_LakeNumber_Export_10m = Avalanche_Hit_LakeNumber;
        Avalanche_Hit_Slope_Export_10m = Avalanche_Hit_Slope;
        Avalanche_Hit_Aspect_Export_10m = Avalanche_Hit_Aspect;
    elseif Avalanche_Depth == 30
        Avalanche_Trajectory_30m = Avalanche_Trajectory_plot;
        Avalanche_Hit_Volume_Export_30m = Avalanche_Hit_Volume;
        Avalanche_Hit_LakeNumber_Export_30m = Avalanche_Hit_LakeNumber;
        Avalanche_Hit_Slope_Export_30m = Avalanche_Hit_Slope;
        Avalanche_Hit_Aspect_Export_30m = Avalanche_Hit_Aspect;
    elseif Avalanche_Depth == 50
        Avalanche_Trajectory_50m = Avalanche_Trajectory_plot;
        Avalanche_Hit_Volume_Export_50m = Avalanche_Hit_Volume;
        Avalanche_Hit_LakeNumber_Export_50m = Avalanche_Hit_LakeNumber;
        Avalanche_Hit_Slope_Export_50m = Avalanche_Hit_Slope;
        Avalanche_Hit_Aspect_Export_50m = Avalanche_Hit_Aspect;
    end
    
    %% Calculate how many avalanches hit the lake, hit it directly (within 45 degrees of primary axis of the lake), and the max volume
        for i = 1:n_Lakes
            for r = 1:nrows
                for c = 1:ncols

                    if Avalanche_Hit_LakeNumber(r,c) == Lake_Table(i,2);
                        % Count the total avalanche pixels that hit each lake
                            Lake_Table(i,(10 + 3*(n_Depth-1))) = Lake_Table(i,(10 + 3*(n_Depth-1))) + 1;
%                             Lake_Table(i,10) = Lake_Table(i,10) + 1;
                        % Count direct hits based on the aspect of the lake and the initial avalanche area
                            if (abs(Lake_Table(i,6) - Avalanche_Hit_Aspect(r,c)) < Direct_Threshold/2) | (mod(Lake_Table(i,6) + Avalanche_Hit_Aspect(r,c), 360) < Direct_Threshold/2)
                                % mod statement needed to deal with aspects surrounding north
                               Lake_Table(i,(11 + 3*(n_Depth-1))) = Lake_Table(i,(11 + 3*(n_Depth-1))) + 1; 
%                                 Lake_Table(i,11) = Lake_Table(i,11) + 1;
                            end
                        % Compute max avalanche volume that enters each lake
                            if Avalanche_Hit_Volume(r,c) > Lake_Table(i,(12 + 3*(n_Depth-1)))
%                             if Avalanche_Hit_Volume(r,c) > Lake_Table(i,(12))
                                Lake_Table(i,(12 + 3*(n_Depth-1))) = Avalanche_Hit_Volume(r,c);
%                                 Lake_Table(i,12) = Avalanche_Hit_Volume(r,c);
                            end
                    end
                end
            end
        end
end

%% Plot the avalanche trajectories in one .tif file
Avalanche_Trajectory_Final = zeros(nrows,ncols);
    for r = 1:nrows
        for c = 1:ncols

            if Avalanche_Trajectory_10m(r,c) == 10
                Avalanche_Trajectory_Final(r,c) = 10;
            elseif Avalanche_Trajectory_30m(r,c) == 30
                Avalanche_Trajectory_Final(r,c) = 30;
            elseif Avalanche_Trajectory_50m(r,c) == 50
                Avalanche_Trajectory_Final(r,c) = 50;
            else
                Avalanche_Trajectory_Final(r,c) = 0;
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
%     write_gdalfiles(Avalanche_Trajectory_Final,Parameters.geospatialReferenceArray)
% 
% % Write the avalanche hit spots to a ASCII file - good for seeing what
% % areas need to be looked at in further detail.
%     Output_FileName_AvalancheHit_Volume_10m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Volume_10m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Volume_10m,Avalanche_Hit_Volume_Export_10m)
%     Output_FileName_AvalancheHit_LakeNumber_10m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_LakeNumber_10m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_LakeNumber_10m,Avalanche_Hit_LakeNumber_Export_10m)
%     Output_FileName_AvalancheHit_Slope_10m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Slope_10m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Slope_10m,Avalanche_Hit_Slope_Export_10m)
%     Output_FileName_AvalancheHit_Aspect_10m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Aspect_10m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Aspect_10m,Avalanche_Hit_Aspect_Export_10m)
%     Output_FileName_AvalancheTrajectory_10m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheTrajectory_10m','.csv'];
%     csvwrite(Output_FileName_AvalancheTrajectory_10m, Avalanche_Trajectory_10m)
%     
%     Output_FileName_AvalancheHit_Volume_30m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Volume_30m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Volume_30m,Avalanche_Hit_Volume_Export_30m)
%     Output_FileName_AvalancheHit_LakeNumber_30m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_LakeNumber_30m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_LakeNumber_30m,Avalanche_Hit_LakeNumber_Export_30m)
%     Output_FileName_AvalancheHit_Slope_30m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Slope_30m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Slope_30m,Avalanche_Hit_Slope_Export_30m)
%     Output_FileName_AvalancheHit_Aspect_30m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Aspect_30m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Aspect_30m,Avalanche_Hit_Aspect_Export_30m)
%     Output_FileName_AvalancheTrajectory_30m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheTrajectory_30m','.csv'];
%     csvwrite(Output_FileName_AvalancheTrajectory_30m, Avalanche_Trajectory_30m)
%     
%     Output_FileName_AvalancheHit_Volume_50m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Volume_50m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Volume_50m,Avalanche_Hit_Volume_Export_50m)
%     Output_FileName_AvalancheHit_LakeNumber_50m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_LakeNumber_50m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_LakeNumber_50m,Avalanche_Hit_LakeNumber_Export_50m)
%     Output_FileName_AvalancheHit_Slope_50m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Slope_50m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Slope_50m,Avalanche_Hit_Slope_Export_50m)
%     Output_FileName_AvalancheHit_Aspect_50m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheHit_Aspect_50m','.csv'];
%     csvwrite(Output_FileName_AvalancheHit_Aspect_50m,Avalanche_Hit_Aspect_Export_50m)
%     Output_FileName_AvalancheTrajectory_50m = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'_GDEM_AvalancheTrajectory_50m','.csv'];
%     csvwrite(Output_FileName_AvalancheTrajectory_50m, Avalanche_Trajectory_50m)
%     
%     Output_FileName_LakeTable = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\CSV_Results\',FileName_Prefix,'LakeTable','.csv'];
%     csvwrite(Output_FileName_LakeTable,Lake_Table)

toc