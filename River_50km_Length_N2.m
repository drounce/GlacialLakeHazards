% CUT THE LENGTH OF A RIVER TO 50 KM
    
tic

%% Import Lake points, DEM, FlowLength, and Flow Direction
    Lake = imread('N2_GlacialLakesV3_Points_raster.tif');
        Lake = double(Lake);
        nrows = size(Lake,1);
        ncols = size(Lake,2);
    DEM = imread('Rivers_N2_ASTER_Elev.tif');
        DEM = double(DEM);
    FlowDir = imread('Rivers_N2_ASTER_FlowDir.tif');
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
    
    DEM(DEM<0) = -9.99;
    FlowDir(FlowDir>128) = -9.99;
    
%% Set parameters
    Distance_Threshold = 50*1000; %km
    pixel_size = 30;
    
% Enter tif file data for writing tifs
Tif_Output_FileName_prefix = 'River_50km_Lake_';
Tif_Output_FilePath = 'C:\Dave_Rounce\MATLAB\Nepal_Hazards\Tiff_Files';
Tif_Input_FilePath = Tif_Output_FilePath;
Tif_Input_FileName = 'Rivers_N2_ASTER_Elev.tif';
    
%% Compute river path based on filled DEM
Lake_Start = min(Lake(Lake>0));
Lake_End = max(max(Lake));
for n_lake = Lake_Start:1:Lake_End
    [Lake_start_row,Lake_start_col] = ind2sub(size(Lake),find(Lake==n_lake));
    Lake_Length = 0;
    n_iteration = 0;
    River = zeros(nrows,ncols);
    if n_lake < 10
        Tif_Output_FileName = [Tif_Output_FileName_prefix,'00',num2str(n_lake)];
    elseif n_lake < 100
        Tif_Output_FileName = [Tif_Output_FileName_prefix,'0',num2str(n_lake)];
    else
        Tif_Output_FileName = [Tif_Output_FileName_prefix,num2str(n_lake)];
    end
    
    while Lake_Length < Distance_Threshold
        n_iteration = n_iteration + 1;
        
        if n_iteration == 1
            r = Lake_start_row;
            c = Lake_start_col;
        else
            r = r + r_dir;
            c = c + c_dir;
            River(r,c) = n_lake;
        end
        
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

        % Compute length between original pixel and pixel downstream
            Lake_Length = Lake_Length + pixel_distance;
              
    end
    
    % Export tif
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
        Parameters.geospatialReferenceArray.Xinc = pixel_size;
        %      :ULy
        Parameters.geospatialReferenceArray.ULy = Parameters.geospatialMetaData.Corners.UL(2);
        %      :Yinc
        Parameters.geospatialReferenceArray.Yinc = pixel_size;
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
        write_gdalfiles(River,Parameters.geospatialReferenceArray)
end

toc
