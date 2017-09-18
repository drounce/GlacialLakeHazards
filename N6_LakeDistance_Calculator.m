% LAKE-TO-GLACIER DISTANCE CALCULATOR

Lake = imread('N6_2015_GlacialLakes_minPt1km2_V3_raster.tif');
    nrows = size(Lake,1);
    ncols = size(Lake,2);
    n_Lakes = max(max(Lake));
Glacier = imread('N6_Glaciers_V3_raster.tif');

    pixel_size = 30; % m
    
    Lake_Dist_Table = zeros(n_Lakes,1);
for n = 1:n_Lakes
    n
    Lake_Dist_min = 10000;
    Lake_solo = zeros(nrows,ncols);
    Lake_solo(Lake==n) = n;
    
    
    Lake_Dist = bwdist(Lake_solo)*pixel_size;
    % "bwdist" computes the minimum euclidian pixel distance between all 
    % the pixels and any nonzero value.
    
    for r = 1:nrows
        for c = 1:ncols
            if Lake_solo(r,c) == n & Glacier(r,c) == 1
                Lake_Dist_min = 0;
            elseif Glacier(r,c) == 1 & Lake_Dist(r,c) < Lake_Dist_min
                Lake_Dist_min = Lake_Dist(r,c);
            end
        end
    end
    
    Lake_Dist_Table(n,1) = Lake_Dist_min;
    
end