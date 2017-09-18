% Must run Lake_Area_Export with the gdal_2.0 folder - and mex folder open!!
% If plotting not working, check that no scripts have CLEAR OR CLC

global Parameters;

Parameters.demAgainFileName = 'N4_GDEM_AvalancheTrajectory_10m';
    %This is the output file name!
Parameters.fileOutputPath = 'C:\Dave_Rounce\MATLAB\Nepal_Hazards\Tiff_Files';

[Avalanche_Trajectory_Final,Parameters.geospatialMetaData] = read_gdalfiles('C:\Dave_Rounce\MATLAB\Nepal_Hazards\Tiff_Files\N4_ASTER_Elev.tif');
disp( Parameters.geospatialMetaData)

% Do all calcs and manipulations here
%     Output_File_Name = 'N2_Barun_GDEM_AvalancheHit_LakeNumber_10m';
%     Output_File_Name_Complete = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\Txt_Results\',Output_File_Name,'.csv'];
%     Output_File = csvread(Output_File_Name_Complete);
    
Avalanche_Trajectory_10m = csvread('N4_GDEM_AvalancheTrajectory_10m.csv');
%     Avalanche_Trajectory_10m = csvread('N3_GDEM_AvalancheTrajectory_10m.csv');
%     Avalanche_Trajectory_30m = csvread('N3_GDEM_AvalancheTrajectory_30m.csv');
%     Avalanche_Trajectory_50m = csvread('N3_GDEM_AvalancheTrajectory_50m.csv');
%         nrows = size(Avalanche_Trajectory_10m,1);
%         ncols = size(Avalanche_Trajectory_10m,2);
%         Avalanche_Trajectory_Final = zeros(nrows,ncols);
%     for r = 1:nrows
%         for c = 1:ncols
%             if Avalanche_Trajectory_10m(r,c) == 10
%                 Avalanche_Trajectory_Final(r,c) = 10;
%             elseif Avalanche_Trajectory_30m(r,c) == 30
%                 Avalanche_Trajectory_Final(r,c) = 30;
%             elseif Avalanche_Trajectory_50m(r,c) == 50
%                 Avalanche_Trajectory_Final(r,c) = 50;
%             else
%                 Avalanche_Trajectory_Final(r,c) = 0;
%             end
%         end
%     end 
            
    

%      :driver
Parameters.geospatialReferenceArray.driver = Parameters.geospatialMetaData.DriverShortName;
%      :name
Parameters.geospatialReferenceArray.name = ['C:\Dave_Rounce\MATLAB\Nepal_Hazards\Tiff_Files\','N4_GDEM_AvalancheTrajectory_10m','.tif'];
%      :ULx
Parameters.geospatialReferenceArray.ULx = Parameters.geospatialMetaData.Corners.UL(1);
% %      :Xinc
Parameters.geospatialReferenceArray.Xinc = 30;
%      :ULy
Parameters.geospatialReferenceArray.ULy = Parameters.geospatialMetaData.Corners.UL(2);
%      :Yinc
Parameters.geospatialReferenceArray.Yinc = 30;
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
write_gdalfiles(Avalanche_Trajectory_10m,Parameters.geospatialReferenceArray)


