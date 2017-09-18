%% Hazard assessment for glacial lakes in Nepal

% V2: PFV of 0 equals 0

Building_cutoff = 20;

Lake_data = csvread('Nepal_Lakes_Data_minPt1km2_V2.csv');
    n_Lakes = size(Lake_data,1);
    
% Lake Data:
    % Col 1 = Nepal ID (consistent with ArcGIS)
    % Col 2 = Longitude (decimal degree)
    % Col 3 = Latitude (decimal degree)
    % Col 4 = Altitude (ASTER Lake 2000 delineation)
    % Col 5 = Aspect (degrees from N)
    % Col 6 = Area 2000 (km2)
    % Col 7 = Area 2015 (km2)
    % Col 8 = Perimeter 2015 (km)
    % Col 9 = Change in area, 2015-2000, (km2)
    % Col 10 = Area error (km2) - perimeter * pixel_size/2
    % Col 11 = Significant growth (1 = yes, 0 = no)
    % Col 12 = Significant drainage (1 = yes, 0 = no)
% Lake Hazards:
    % Col 13 = Lakes upstream (1 = yes, 2 = yes but small, 0 = no)
    % Col 14 = Ice-cored moraine based on ponds (1 = yes, 0 = no)
    % Col 15 = Avg Angle of SLA (degrees)
    % Col 16 = 10m Total avalanches that hit lake
    % Col 17 = 10m Total avalanches that hit lake directly
    % Col 18 = 10m Max avalanche size that hit lake
    % Col 19 = 30m Total avalanches that hit lake
    % Col 20 = 30m Total avalanches that hit lake directly
    % Col 21 = 30m Max avalanche size that hit lake
    % Col 22 = 50m Total avalanches that hit lake
    % Col 23 = 50m Total avalanches that hit lake directly
    % Col 24 = 50m Max avalanche size that hit lake
    % Col 25 = Total landslides that hit
    % Col 26 = Total landslides that hit directly
% Lake Hazard ratings
    % Col 27 = Avalanche hazard ranking
    % Col 28 = Landslide hazard ranking
    % Col 29 = Upstream GLOF hazard ranking
    % Col 30 = Dynamic hazard ranking
    % Col 31 = Self-destructive hazard ranking
    % Col 32 = Total hazard ranking
    % Col 33 = Tier ranking
% Lake Downstream Impact Data:
    % Col 34 = Buildings
    % Col 35 = Bridges
    % Col 36 = Agriculture (pixels)
    % Col 37 = Agriculture (km2)
    % Col 38 = Hydropower
% Lake Downstream Impact rating:
    % Col 39 = Downstream Impact rating
% Lake Risk rating:
    % Col 40 = hazards + impact value
    % Col 41 = Risk rating
    
    % Ranking definitions:
        % 0 = Low
        % 1 = Moderate
        % 2 = High
        % 3 = Very High
        
%% Perform adjustments to data

for r = 1:n_Lakes
    %Remove small lakes from analysis
    if Lake_data(r,13) == 2
        Lake_data(r,13) = 0;
    end
end

Hazard_count_3 = 0;
Hazard_count_2 = 0;
Hazard_count_1 = 0;
Hazard_count_0 = 0;
Downstream_Impact_count_3 = 0;
Downstream_Impact_count_2 = 0;
Downstream_Impact_count_1 = 0;
Downstream_Impact_count_0 = 0;
Risk_count_3 = 0;
Risk_count_2 = 0;
Risk_count_1 = 0;
Risk_count_0 = 0;
Lakes_ranked = zeros(n_Lakes,32);
count_lakes = 0;
%% Compute hazards, downstream impacts, and risks
for r = 1:n_Lakes
    % Self-destructive hazards
        % Is the moraine unstable (avg angle SLA > 10 degrees)
            if Lake_data(r,15) > 10
                Lake_data(r,31) = 1;
                % is the moraine ice-cored?
                    if Lake_data(r,14) == 1
                        Lake_data(r,31) = 2;
                    end
            end
    % Dynamic hazards
        % Does avalanche enter the lake?
            if Lake_data(r,22) > 0
                Lake_data(r,27) = 2;
                % Is the moraine high hazard for self-destructive failure?
                    if Lake_data(r,31) > 0
                        Lake_data(r,27) = 3;
                    end
            end
        % Does landslide enter the lake?
            if Lake_data(r,25) > 0
                Lake_data(r,28) = 1;
            end
        % Does upstream GLOF enter the lake?
            if Lake_data(r,13) > 0
                Lake_data(r,29) = 1;
            end
        % Total dynamic hazard
            Lake_data(r,30) = max(Lake_data(r,27:29));
    % Total hazard
        % Is the lake susceptible to high dynamic and mod/high self-destructive failure?
            Lake_data(r,32) = max(Lake_data(r,30:31));

    % Downstream Impacts
        % Is there a significant amount of buildings in the flood path?
            if Lake_data(r,34) > Building_cutoff
                Lake_data(r,39) = 2;
                % Are any hydropower systems near the flood path?
                    if Lake_data(r,38) > 0
                        Lake_data(r,39) = 3;
                    end
        % Are any other buildings, bridges, or agricultural land effected?
            elseif Lake_data(r,34) > 0 | Lake_data(r,35) > 0 | Lake_data(r,37) > 0
                Lake_data(r,39) = 1;
            else
                Lake_data(r,39) = 0;
            end
        
    % Risk
        % Compute risk value (hazard + downstream impact)
            Lake_data(r,40) = Lake_data(r,32) + Lake_data(r,39);
        % Risk rating
            if Lake_data(r,40) >= 5
                Lake_data(r,41) = 3;
            elseif Lake_data(r,40) >= 4
                Lake_data(r,41) = 2;
            elseif Lake_data(r,40) >= 2
                Lake_data(r,41) = 1;
            else
                Lake_data(r,41) = 0;
            end
end

%% Summary tables of risks and hazards
% Compute summary statistics only for lakes that are greater than 0.1 km2
for r = 1:n_Lakes
    if Lake_data(r,7) >= 0.1
        % Count hazard levels
            if Lake_data(r,32) == 3
                Hazard_count_3 = Hazard_count_3 + 1; 
            elseif Lake_data(r,32) == 2
                Hazard_count_2 = Hazard_count_2 + 1; 
            elseif Lake_data(r,32) == 1
                Hazard_count_1 = Hazard_count_1 + 1; 
            else
                Hazard_count_0 = Hazard_count_0 + 1; 
            end
        
        % Count downstream impact levels
            if Lake_data(r,39) == 3
                Downstream_Impact_count_3 = Downstream_Impact_count_3 + 1; 
            elseif Lake_data(r,39) == 2
                Downstream_Impact_count_2 = Downstream_Impact_count_2 + 1; 
            elseif Lake_data(r,39) == 1
                Downstream_Impact_count_1 = Downstream_Impact_count_1 + 1; 
            else
                Downstream_Impact_count_0 = Downstream_Impact_count_0 + 1; 
            end
            
        % Count risk levels
            if Lake_data(r,41) == 3
                Risk_count_3 = Risk_count_3 + 1; 
            elseif Lake_data(r,41) == 2
                Risk_count_2 = Risk_count_2 + 1; 
            elseif Lake_data(r,41) == 1
                Risk_count_1 = Risk_count_1 + 1; 
            else
                Risk_count_0 = Risk_count_0 + 1; 
            end
    end
end

Summary_Risk = zeros(4,3);
    Summary_Risk(1,1) = Hazard_count_3;
    Summary_Risk(2,1) = Hazard_count_2;
    Summary_Risk(3,1) = Hazard_count_1;
    Summary_Risk(4,1) = Hazard_count_0;
    Summary_Risk(1,2) = Downstream_Impact_count_3;
    Summary_Risk(2,2) = Downstream_Impact_count_2;
    Summary_Risk(3,2) = Downstream_Impact_count_1;
    Summary_Risk(4,2) = Downstream_Impact_count_0;
    Summary_Risk(1,3) = Risk_count_3;
    Summary_Risk(2,3) = Risk_count_2;
    Summary_Risk(3,3) = Risk_count_1;
    Summary_Risk(4,3) = Risk_count_0;

% Count hazard related variables
Summary_Hazards = zeros(4,6);
for r = 1:n_Lakes
    if Lake_data(r,7) >= 0.1
        % Avalanche hazard
            if Lake_data(r,27) == 3
                Summary_Hazards(1,1) = Summary_Hazards(1,1) + 1;
            elseif Lake_data(r,27) == 2
                Summary_Hazards(2,1) = Summary_Hazards(2,1) + 1;
            end
        % Landslide hazard
            if Lake_data(r,28) == 1
                Summary_Hazards(3,2) = Summary_Hazards(3,2) + 1;
            end
        % Upstream GLOF hazard
            if Lake_data(r,29) == 1
                Summary_Hazards(3,3) = Summary_Hazards(3,3) + 1;
            end
        % Dynamic hazard
            if Lake_data(r,30) == 3
                Summary_Hazards(1,4) = Summary_Hazards(1,4) + 1;
            elseif Lake_data(r,30) == 2
                Summary_Hazards(2,4) = Summary_Hazards(2,4) + 1;
            elseif Lake_data(r,30) == 1
                Summary_Hazards(3,4) = Summary_Hazards(3,4) + 1;
            elseif Lake_data(r,30) == 0
                Summary_Hazards(4,4) = Summary_Hazards(4,4) + 1;
            end
        % Self-destructive hazard
            if Lake_data(r,31) == 3
                Summary_Hazards(1,5) = Summary_Hazards(1,5) + 1;
            elseif Lake_data(r,31) == 2
                Summary_Hazards(2,5) = Summary_Hazards(2,5) + 1;
            elseif Lake_data(r,31) == 1
                Summary_Hazards(3,5) = Summary_Hazards(3,5) + 1;
            elseif Lake_data(r,31) == 0
                Summary_Hazards(4,5) = Summary_Hazards(4,5) + 1;
            end
        % Self-destructive hazard
            if Lake_data(r,32) == 3
                Summary_Hazards(1,6) = Summary_Hazards(1,6) + 1;
            elseif Lake_data(r,32) == 2
                Summary_Hazards(2,6) = Summary_Hazards(2,6) + 1;
            elseif Lake_data(r,32) == 1
                Summary_Hazards(3,6) = Summary_Hazards(3,6) + 1;
            elseif Lake_data(r,32) == 0
                Summary_Hazards(4,6) = Summary_Hazards(4,6) + 1;
            end
    end
end

% %% Rank lakes according to the following:
%     % 1.  Lakes that have avalanche + SLA + ice-core (H3)
%     % 2.  Lakes that have avalanche + SLA (H2)
%     % 3.  Lakes that have avalanche + ice-core (H2)
%     % 4.  Lakes that have avalanche + landslide/GLOF (H2)
%     % 5.  Lakes that have avalanche + landslide (H2)
%     % 6.  Lakes that have avalanche + GLOF (H2)
%     % 7.  Lakes that have avalanche (H2)
%     % 8.  Lakes that have SLA + ice-core (H2)
%     % 9.  Lakes that have SLA (H1)
%     % 10. Lakes that have landslide + GLOF (H1)
%     % 11. Lakes that have landslide (H1)
%     % 12. Lakes that have GLOF (H1)
%     % 13. Lakes with nothing
% 
% for r = 1:n_Lakes
%     % Tier 1 = avalanche + SLA + ice-core
%         if Lake_data(r,32) == 3
%             Lake_data(r,33) = 1;
%     % Tier 2 = avalanche + SLA
%         elseif Lake_data(r,30) == 2 & Lake_data(r,31) == 1
%             Lake_data(r,33) = 2;
%     % Tier 3 = avalanche + ice-core
%         elseif Lake_data(r,30) == 2 & Lake_data(r,14) == 1
%             Lake_data(r,33) = 3;
%     % Tier 4 = avalanche + landslide + GLOF
%         elseif Lake_data(r,30) == 2 & Lake_data(r,28) == 1 & Lake_data(r,29) == 1
%             Lake_data(r,33) = 4;
%     % Tier 5 = avalanche + landslide
%         elseif Lake_data(r,30) == 2 & Lake_data(r,28) == 1
%             Lake_data(r,33) = 5;
%     % Tier 6 = avalanche + GLOF
%         elseif Lake_data(r,30) == 2 & Lake_data(r,29) == 1
%             Lake_data(r,33) = 6;
%     % Tier 7 = avalanche
%         elseif Lake_data(r,30) == 2
%             Lake_data(r,33) = 7;
%     % Tier 8 = SLA + ice-core
%         elseif Lake_data(r,31) == 2
%             Lake_data(r,33) = 8;
%     % Tier 9 = Lakes that have SLA
%         elseif Lake_data(r,31) == 1
%             Lake_data(r,33) = 9;
%     % Tier 10 = Lakes that have landslide + GLOF
%         elseif Lake_data(r,28) == 1 & Lake_data(r,29) == 1
%             Lake_data(r,33) = 10;
%     % Tier 11 = Lakes that have landslide
%         elseif Lake_data(r,28) == 1
%             Lake_data(r,33) = 11;
%     % Tier 12 = Lakes that have GLOF
%         elseif Lake_data(r,29) == 1
%             Lake_data(r,33) = 12;
%     % Tier 13 = Lakes with nothing
%         elseif Lake_data(r,32) == 0
%             Lake_data(r,33) = 13;
%         end
% end
%         
    
    
    
    
    
    
    