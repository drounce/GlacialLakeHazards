% Compute Average Angle of Steep Lookdown Area (Fujita et al., 2013)

% 2000 Lake extents are used to compute average lake elevation as this
% agrees with when the ASTER data were acquired

tic

% Import data DEM & Lakes
pixel_size = 30; %m
DEM = imread('N4_ASTER_Elev_V3.tif');
    DEM = double(DEM);
    nrows = size(DEM,1);
    ncols = size(DEM,2);
Lake_2000 = imread('N4_2000_GlacialLakes_minPt1km2_V3_raster.tif');
    Lake_2000 = double(Lake_2000);
Lake_2015 = imread('N4_2015_GlacialLakes_minPt1km2_V3_raster.tif');
    Lake_2015 = double(Lake_2015);
    n_Lakes = max(max(Lake_2015));
    Lake_Table = zeros(n_Lakes,8);
        % Col 1 = Lake number
        % Col 2 = Lake pixels
        % Col 3 = Running sum of elevation (for avg)
        % Col 4 = Lake elevation
        % Col 5 = SLA
        % Col 6 = SLA_max_elev
        % Col 7 = SLA_max_dist
        % Col 8 = SLA_max_Hp - potential lowering height
        
% Set minimum and maximum distances
    % Min used to avoid steepness between pixels that don't represent the moraine
    Dist_Cutoff = 1000;
    Dist_Cutoff_pixels = round(1000/pixel_size);
    Min_Distance = 100;
        
% Compute Average Elevation of each lake
for r = 1:nrows
    for c = 1:ncols
        for Lake_Number = 1:n_Lakes
            Lake_Table(Lake_Number,1) = Lake_Number;
            if Lake_2000(r,c) == Lake_Number
                Lake_Table(Lake_Number,2) = Lake_Table(Lake_Number,2) + 1;
                Lake_Table(Lake_Number,3) = Lake_Table(Lake_Number,3) + DEM(r,c);
            end
        end
    end
end
    % Lake elevation = Sum of elevations of lake pixels / # lake pixels
    Lake_Table(:,4) = Lake_Table(:,3)./Lake_Table(:,2);
                
        
% Assess the Average angle of SLA for each pixel within the distance cutoff
% for each lake
SLA_AvgAngle = zeros(nrows,ncols);
for Lake_Number = 1:n_Lakes
% for Lake_Number = 7
    % Need fresh set of zeros to use the "bwdist" tool
    Lake_solo = zeros(nrows,ncols);
    Lake_elevation = Lake_Table(Lake_Number,4);
    % Look at each lake individually ("solo")
    for r = 1:nrows
        for c = 1:ncols
            if Lake_2015(r,c) == Lake_Table(Lake_Number,1)
                Lake_solo(r,c) = Lake_Number;
            end
        end
    end
    
    Lake_Dist = bwdist(Lake_solo)*pixel_size;
    % "bwdist" computes the minimum euclidian pixel distance between all 
    % the pixels and any nonzero value.
    for r = 1:nrows
        for c = 1:ncols
            if Lake_Dist(r,c) < Min_Distance | Lake_Dist(r,c) > Dist_Cutoff
                Lake_Dist(r,c) = 0;
            end
        end
    end
    
    % Compute max average angle for SLA for each lake
    SLA_AvgAngle_max = 0;
    for r = 1:nrows
        for c = 1:ncols
            if Lake_Dist(r,c) > 0 & DEM(r,c) < Lake_elevation
                SLA_AvgAngle(r,c) = atan((Lake_elevation-DEM(r,c))/Lake_Dist(r,c))*180/pi();
                if SLA_AvgAngle(r,c) > SLA_AvgAngle_max
                    SLA_AvgAngle_max = SLA_AvgAngle(r,c);
                    SLA_AvgAngle_max_row = r;
                    SLA_AvgAngle_max_col = c;
                    SLA_AvgAngle_max_elev = DEM(r,c);
                    SLA_AvgAngle_max_dist = Lake_Dist(r,c);
                end
            end
        end
    end
    Lake_Table(Lake_Number,5) = SLA_AvgAngle_max;
    Lake_Table(Lake_Number,6) = SLA_AvgAngle_max_elev;
    Lake_Table(Lake_Number,7) = SLA_AvgAngle_max_dist;
    
    % Compute potential lowering height (Hp), which is the elevation the
    % lake needs to be lowered such that the avg angle equals 10 degrees
    if SLA_AvgAngle_max > 10
        SLA_AvgAngle_max_Hp = (Lake_elevation - SLA_AvgAngle_max_elev) - tan(10*pi()/180)*SLA_AvgAngle_max_dist;
            % Lake_elevation - SLA_AvgAngle_max_elev is the height of the moraine 
            % tan(10)*SLA_Dist_max is the height that equals 10 degrees
            % the difference of these two is the potnetial lowering height
    else
        SLA_AvgAngle_max_Hp = 0;
    end
    
        Lake_Table(Lake_Number,8) = SLA_AvgAngle_max_Hp;
        
end
                
 
% Elev_NewTop = tan(10*pi()/180)*SLA_Dist_max;
% 
% Lake_Lower_basedon_Angle = SLA_Elev_diff_max - Elev_NewTop;
% Depth_mean = 55*(Lake_Area/10^6)^0.25;
% 
% Lake_Lower = min(Lake_Lower_basedon_Angle,Depth_mean);
% 
% if SLA_deg_max >= 10
%     GLOF_Volume = Lake_Lower*Lake_Area/10^6; % million cubic meters
% else
%     GLOF_Volume = 0;
% end

toc
        