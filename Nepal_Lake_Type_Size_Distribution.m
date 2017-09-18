%% Count lakes according to type and size

data = xlsread('Nepal_Lake_type.xls');
    n_Lakes = size(data,1);
    % Col 1 = Lake ID
    % Col 2 = Lake Type
    % Col 3 = Lake Area 2015
    % Col 4 = Lake Area 2000
    % Col 5 = Lake Elevation
    % Col 6 = Lake Hazard
    
Type1_01 = 0;
Type1_02 = 0;
Type1_03 = 0;
Type1_04 = 0;
Type1_05 = 0;
Type1_06 = 0;
Type1_07 = 0;
Type1_08 = 0;
Type2_01 = 0;
Type2_02 = 0;
Type2_03 = 0;
Type2_04 = 0;
Type2_05 = 0;
Type2_06 = 0;
Type2_07 = 0;
Type2_08 = 0;
Type3_01 = 0;
Type3_02 = 0;
Type3_03 = 0;
Type3_04 = 0;
Type3_05 = 0;
Type3_06 = 0;
Type3_07 = 0;
Type3_08 = 0;
Type4_01 = 0;
Type4_02 = 0;
Type4_03 = 0;
Type4_04 = 0;
Type4_05 = 0;
Type4_06 = 0;
Type4_07 = 0;
Type4_08 = 0;

Type1_01_Area = 0;
Type1_02_Area = 0;
Type1_03_Area = 0;
Type1_04_Area = 0;
Type1_05_Area = 0;
Type1_06_Area = 0;
Type1_07_Area = 0;
Type1_08_Area = 0;
Type2_01_Area = 0;
Type2_02_Area = 0;
Type2_03_Area = 0;
Type2_04_Area = 0;
Type2_05_Area = 0;
Type2_06_Area = 0;
Type2_07_Area = 0;
Type2_08_Area = 0;
Type3_01_Area = 0;
Type3_02_Area = 0;
Type3_03_Area = 0;
Type3_04_Area = 0;
Type3_05_Area = 0;
Type3_06_Area = 0;
Type3_07_Area = 0;
Type3_08_Area = 0;
Type4_01_Area = 0;
Type4_02_Area = 0;
Type4_03_Area = 0;
Type4_04_Area = 0;
Type4_05_Area = 0;
Type4_06_Area = 0;
Type4_07_Area = 0;
Type4_08_Area = 0;

size1 = 0.1;
size2 = 0.25;
size3 = 0.5;
size4 = 0.75;
size5 = 1;
size6 = 1.5;
size7 = 2;
size8 = 10;

Lake_2000_Type1 = 0;
Lake_2015_Type1 = 0;
Lake_2000_Type2 = 0;
Lake_2015_Type2 = 0;
Lake_2000_Type3 = 0;
Lake_2015_Type3 = 0;
Lake_2000_Type4 = 0;
Lake_2015_Type4 = 0;
    
for r = 1:n_Lakes
    if data(r,2) == 1
        Lake_2000_Type1 = Lake_2000_Type1 + data(r,4);
        Lake_2015_Type1 = Lake_2015_Type1 + data(r,3);
        if data(r,3) < size1
            Type1_01 = Type1_01+1;
            Type1_01_Area = Type1_01_Area + data(r,3);
        elseif data(r,3) < size2
            Type1_02 = Type1_02+1;
            Type1_02_Area = Type1_02_Area + data(r,3);
        elseif data(r,3) < size3
            Type1_03 = Type1_03+1;
            Type1_03_Area = Type1_03_Area + data(r,3);
        elseif data(r,3) < size4
            Type1_04 = Type1_04+1;
            Type1_04_Area = Type1_04_Area + data(r,3);
        elseif data(r,3) < size5
            Type1_05 = Type1_05+1;
            Type1_05_Area = Type1_05_Area + data(r,3);
        elseif data(r,3) < size6
            Type1_06 = Type1_06+1;
            Type1_06_Area = Type1_06_Area + data(r,3);
        elseif data(r,3) < size7
            Type1_07 = Type1_07+1;
            Type1_07_Area = Type1_07_Area + data(r,3);
        elseif data(r,3) < size8
            Type1_08 = Type1_08+1;
            Type1_08_Area = Type1_08_Area + data(r,3);
        end
    elseif data(r,2) == 2
        Lake_2000_Type2 = Lake_2000_Type2 + data(r,4);
        Lake_2015_Type2 = Lake_2015_Type2 + data(r,3);
        if data(r,3) < size1
            Type2_01 = Type2_01+1;
            Type2_01_Area = Type2_01_Area + data(r,3);
        elseif data(r,3) < size2
            Type2_02 = Type2_02+1;
            Type2_02_Area = Type2_02_Area + data(r,3);
        elseif data(r,3) < size3
            Type2_03 = Type2_03+1;
            Type2_03_Area = Type2_03_Area + data(r,3);
        elseif data(r,3) < size4
            Type2_04 = Type2_04+1;
            Type2_04_Area = Type2_04_Area + data(r,3);
        elseif data(r,3) < size5
            Type2_05 = Type2_05+1;
            Type2_05_Area = Type2_05_Area + data(r,3);
        elseif data(r,3) < size6
            Type2_06 = Type2_06+1;
            Type2_06_Area = Type2_06_Area + data(r,3);
        elseif data(r,3) < size7
            Type2_07 = Type2_07+1;
            Type2_07_Area = Type2_07_Area + data(r,3);
        elseif data(r,3) < size8
            Type2_08 = Type2_08+1;
            Type2_08_Area = Type2_08_Area + data(r,3);
        end
    elseif data(r,2) == 3
        Lake_2000_Type3 = Lake_2000_Type3 + data(r,4);
        Lake_2015_Type3 = Lake_2015_Type3 + data(r,3);
        if data(r,3) < size1
            Type3_01 = Type3_01+1;
            Type3_01_Area = Type3_01_Area + data(r,3);
        elseif data(r,3) < size2
            Type3_02 = Type3_02+1;
            Type3_02_Area = Type3_02_Area + data(r,3);
        elseif data(r,3) < size3
            Type3_03 = Type3_03+1;
            Type3_03_Area = Type3_03_Area + data(r,3);
        elseif data(r,3) < size4
            Type3_04 = Type3_04+1;
            Type3_04_Area = Type3_04_Area + data(r,3);
        elseif data(r,3) < size5
            Type3_05 = Type3_05+1;
            Type3_05_Area = Type3_05_Area + data(r,3);
        elseif data(r,3) < size6
            Type3_06 = Type3_06+1;
            Type3_06_Area = Type3_06_Area + data(r,3);
        elseif data(r,3) < size7
            Type3_07 = Type3_07+1;
            Type3_07_Area = Type3_07_Area + data(r,3);
        elseif data(r,3) < size8
            Type3_08 = Type3_08+1;
            Type3_08_Area = Type3_08_Area + data(r,3);
        end
    elseif data(r,2) == 4
        Lake_2000_Type4 = Lake_2000_Type4 + data(r,4);
        Lake_2015_Type4 = Lake_2015_Type4 + data(r,3);
        if data(r,3) < size1
            Type4_01 = Type4_01+1;
            Type4_01_Area = Type4_01_Area + data(r,3);
        elseif data(r,3) < size2
            Type4_02 = Type4_02+1;
            Type4_02_Area = Type4_02_Area + data(r,3);
        elseif data(r,3) < size3
            Type4_03 = Type4_03+1;
            Type4_03_Area = Type4_03_Area + data(r,3);
        elseif data(r,3) < size4
            Type4_04 = Type4_04+1;
            Type4_04_Area = Type4_04_Area + data(r,3);
        elseif data(r,3) < size5
            Type4_05 = Type4_05+1;
            Type4_05_Area = Type4_05_Area + data(r,3);
        elseif data(r,3) < size6
            Type4_06 = Type4_06+1;
            Type4_06_Area = Type4_06_Area + data(r,3);
        elseif data(r,3) < size7
            Type4_07 = Type4_07+1;
            Type4_07_Area = Type4_07_Area + data(r,3);
        elseif data(r,3) < size8
            Type4_08 = Type4_08+1;
            Type4_08_Area = Type4_08_Area + data(r,3);
        end
    end
end

data_count = [Type1_01,Type2_01,Type3_01,Type4_01;
              Type1_02,Type2_02,Type3_02,Type4_02;
              Type1_03,Type2_03,Type3_03,Type4_03;
              Type1_04,Type2_04,Type3_04,Type4_04;
              Type1_05,Type2_05,Type3_05,Type4_05;
              Type1_06,Type2_06,Type3_06,Type4_06;
              Type1_07,Type2_07,Type3_07,Type4_07;
              Type1_08,Type2_08,Type3_08,Type4_08];
  
data_area = [Type1_01_Area,Type2_01_Area,Type3_01_Area,Type4_01_Area;
              Type1_02_Area,Type2_02_Area,Type3_02_Area,Type4_02_Area;
              Type1_03_Area,Type2_03_Area,Type3_03_Area,Type4_03_Area;
              Type1_04_Area,Type2_04_Area,Type3_04_Area,Type4_04_Area;
              Type1_05_Area,Type2_05_Area,Type3_05_Area,Type4_05_Area;
              Type1_06_Area,Type2_06_Area,Type3_06_Area,Type4_06_Area;
              Type1_07_Area,Type2_07_Area,Type3_07_Area,Type4_07_Area;
              Type1_08_Area,Type2_08_Area,Type3_08_Area,Type4_08_Area];
          
data_size = [Lake_2000_Type1, Lake_2000_Type2, Lake_2000_Type3, Lake_2000_Type4;
             Lake_2015_Type1, Lake_2015_Type2, Lake_2015_Type3, Lake_2015_Type4];
         
Type1_01_Elev_Count = 0;
Type1_02_Elev_Count = 0;
Type1_03_Elev_Count = 0;
Type1_04_Elev_Count = 0;
Type1_05_Elev_Count = 0;
Type2_01_Elev_Count = 0;
Type2_02_Elev_Count = 0;
Type2_03_Elev_Count = 0;
Type2_04_Elev_Count = 0;
Type2_05_Elev_Count = 0;
Type3_01_Elev_Count = 0;
Type3_02_Elev_Count = 0;
Type3_03_Elev_Count = 0;
Type3_04_Elev_Count = 0;
Type3_05_Elev_Count = 0;
Type4_01_Elev_Count = 0;
Type4_02_Elev_Count = 0;
Type4_03_Elev_Count = 0;
Type4_04_Elev_Count = 0;
Type4_05_Elev_Count = 0;
for r = 1:n_Lakes
    if data(r,2) == 1
        if data(r,5) < 4000
            Type1_01_Elev_Count = Type1_01_Elev_Count + 1;
        elseif data(r,5) < 4500
            Type1_02_Elev_Count = Type1_02_Elev_Count + 1;
        elseif data(r,5) < 5000
            Type1_03_Elev_Count = Type1_03_Elev_Count + 1;
        elseif data(r,5) < 5500
            Type1_04_Elev_Count = Type1_04_Elev_Count + 1;
        elseif data(r,5) < 6000
            Type1_05_Elev_Count = Type1_05_Elev_Count + 1;
        end
    elseif data(r,2) == 2
        if data(r,5) < 4000
            Type2_01_Elev_Count = Type2_01_Elev_Count + 1;
        elseif data(r,5) < 4500
            Type2_02_Elev_Count = Type2_02_Elev_Count + 1;
        elseif data(r,5) < 5000
            Type2_03_Elev_Count = Type2_03_Elev_Count + 1;
        elseif data(r,5) < 5500
            Type2_04_Elev_Count = Type2_04_Elev_Count + 1;
        elseif data(r,5) < 6000
            Type2_05_Elev_Count = Type2_05_Elev_Count + 1;
        end
    elseif data(r,2) == 3
        if data(r,5) < 4000
            Type3_01_Elev_Count = Type3_01_Elev_Count + 1;
        elseif data(r,5) < 4500
            Type3_02_Elev_Count = Type3_02_Elev_Count + 1;
        elseif data(r,5) < 5000
            Type3_03_Elev_Count = Type3_03_Elev_Count + 1;
        elseif data(r,5) < 5500
            Type3_04_Elev_Count = Type3_04_Elev_Count + 1;
        elseif data(r,5) < 6000
            Type3_05_Elev_Count = Type3_05_Elev_Count + 1;
        end
    elseif data(r,2) == 4
        if data(r,5) < 4000
            Type4_01_Elev_Count = Type4_01_Elev_Count + 1;
        elseif data(r,5) < 4500
            Type4_02_Elev_Count = Type4_02_Elev_Count + 1;
        elseif data(r,5) < 5000
            Type4_03_Elev_Count = Type4_03_Elev_Count + 1;
        elseif data(r,5) < 5500
            Type4_04_Elev_Count = Type4_04_Elev_Count + 1;
        elseif data(r,5) < 6000
            Type4_05_Elev_Count = Type4_05_Elev_Count + 1;
        end
    end
end

data_table_elev = [Type1_01_Elev_Count,Type2_01_Elev_Count,Type3_01_Elev_Count,Type4_01_Elev_Count;
                   Type1_02_Elev_Count,Type2_02_Elev_Count,Type3_02_Elev_Count,Type4_02_Elev_Count;
                   Type1_03_Elev_Count,Type2_03_Elev_Count,Type3_03_Elev_Count,Type4_03_Elev_Count;
                   Type1_04_Elev_Count,Type2_04_Elev_Count,Type3_04_Elev_Count,Type4_04_Elev_Count;
                   Type1_05_Elev_Count,Type2_05_Elev_Count,Type3_05_Elev_Count,Type4_05_Elev_Count];
    
Haz_0_01_Elev_Count = 0;
Haz_0_02_Elev_Count = 0;
Haz_0_03_Elev_Count = 0;
Haz_0_04_Elev_Count = 0;
Haz_0_05_Elev_Count = 0;
Haz_1_01_Elev_Count = 0;
Haz_1_02_Elev_Count = 0;
Haz_1_03_Elev_Count = 0;
Haz_1_04_Elev_Count = 0;
Haz_1_05_Elev_Count = 0;
Haz_2_01_Elev_Count = 0;
Haz_2_02_Elev_Count = 0;
Haz_2_03_Elev_Count = 0;
Haz_2_04_Elev_Count = 0;
Haz_2_05_Elev_Count = 0;
Haz_3_01_Elev_Count = 0;
Haz_3_02_Elev_Count = 0;
Haz_3_03_Elev_Count = 0;
Haz_3_04_Elev_Count = 0;
Haz_3_05_Elev_Count = 0;
for r = 1:n_Lakes
    if data(r,6) == 0
        if data(r,5) < 4000
            Haz_0_01_Elev_Count = Haz_0_01_Elev_Count + 1;
        elseif data(r,5) < 4500
            Haz_0_02_Elev_Count = Haz_0_02_Elev_Count + 1;
        elseif data(r,5) < 5000
            Haz_0_03_Elev_Count = Haz_0_03_Elev_Count + 1;
        elseif data(r,5) < 5500
            Haz_0_04_Elev_Count = Haz_0_04_Elev_Count + 1;
        elseif data(r,5) < 6000
            Haz_0_05_Elev_Count = Haz_0_05_Elev_Count + 1;
        end
    elseif data(r,6) == 1
        if data(r,5) < 4000
            Haz_1_01_Elev_Count = Haz_1_01_Elev_Count + 1;
        elseif data(r,5) < 4500
            Haz_1_02_Elev_Count = Haz_1_02_Elev_Count + 1;
        elseif data(r,5) < 5000
            Haz_1_03_Elev_Count = Haz_1_03_Elev_Count + 1;
        elseif data(r,5) < 5500
            Haz_1_04_Elev_Count = Haz_1_04_Elev_Count + 1;
        elseif data(r,5) < 6000
            Haz_1_05_Elev_Count = Haz_1_05_Elev_Count + 1;
        end
    elseif data(r,6) == 2
        if data(r,5) < 4000
            Haz_2_01_Elev_Count = Haz_2_01_Elev_Count + 1;
        elseif data(r,5) < 4500
            Haz_2_02_Elev_Count = Haz_2_02_Elev_Count + 1;
        elseif data(r,5) < 5000
            Haz_2_03_Elev_Count = Haz_2_03_Elev_Count + 1;
        elseif data(r,5) < 5500
            Haz_2_04_Elev_Count = Haz_2_04_Elev_Count + 1;
        elseif data(r,5) < 6000
            Haz_2_05_Elev_Count = Haz_2_05_Elev_Count + 1;
        end
    elseif data(r,6) == 3
        if data(r,5) < 4000
            Haz_3_01_Elev_Count = Haz_3_01_Elev_Count + 1;
        elseif data(r,5) < 4500
            Haz_3_02_Elev_Count = Haz_3_02_Elev_Count + 1;
        elseif data(r,5) < 5000
            Haz_3_03_Elev_Count = Haz_3_03_Elev_Count + 1;
        elseif data(r,5) < 5500
            Haz_3_04_Elev_Count = Haz_3_04_Elev_Count + 1;
        elseif data(r,5) < 6000
            Haz_3_05_Elev_Count = Haz_3_05_Elev_Count + 1;
        end
    end
end

data_table_elev_haz = [Haz_0_01_Elev_Count,Haz_1_01_Elev_Count,Haz_2_01_Elev_Count,Haz_3_01_Elev_Count;
                   Haz_0_02_Elev_Count,Haz_1_02_Elev_Count,Haz_2_02_Elev_Count,Haz_3_02_Elev_Count;
                   Haz_0_03_Elev_Count,Haz_1_03_Elev_Count,Haz_2_03_Elev_Count,Haz_3_03_Elev_Count;
                   Haz_0_04_Elev_Count,Haz_1_04_Elev_Count,Haz_2_04_Elev_Count,Haz_3_04_Elev_Count;
                   Haz_0_05_Elev_Count,Haz_1_05_Elev_Count,Haz_2_05_Elev_Count,Haz_3_05_Elev_Count];
            
Haz_0_01_type_Count = 0;
Haz_0_02_type_Count = 0;
Haz_0_03_type_Count = 0;
Haz_0_04_type_Count = 0;
Haz_1_01_type_Count = 0;
Haz_1_02_type_Count = 0;
Haz_1_03_type_Count = 0;
Haz_1_04_type_Count = 0;
Haz_2_01_type_Count = 0;
Haz_2_02_type_Count = 0;
Haz_2_03_type_Count = 0;
Haz_2_04_type_Count = 0;
Haz_3_01_type_Count = 0;
Haz_3_02_type_Count = 0;
Haz_3_03_type_Count = 0;
Haz_3_04_type_Count = 0;
for r = 1:n_Lakes
    if data(r,6) == 0
        if data(r,2) == 1
            Haz_0_01_type_Count = Haz_0_01_type_Count + 1;
        elseif data(r,2) == 2
            Haz_0_02_type_Count = Haz_0_02_type_Count + 1;
        elseif data(r,2) == 3
            Haz_0_03_type_Count = Haz_0_03_type_Count + 1;
        elseif data(r,2) == 4
            Haz_0_04_type_Count = Haz_0_04_type_Count + 1;
        end
    elseif data(r,6) == 1
        if data(r,2) == 1
            Haz_1_01_type_Count = Haz_1_01_type_Count + 1;
        elseif data(r,2) == 2
            Haz_1_02_type_Count = Haz_1_02_type_Count + 1;
        elseif data(r,2) == 3
            Haz_1_03_type_Count = Haz_1_03_type_Count + 1;
        elseif data(r,2) == 4
            Haz_1_04_type_Count = Haz_1_04_type_Count + 1;
        end
    elseif data(r,6) == 2
        if data(r,2) == 1
            Haz_2_01_type_Count = Haz_2_01_type_Count + 1;
        elseif data(r,2) == 2
            Haz_2_02_type_Count = Haz_2_02_type_Count + 1;
        elseif data(r,2) == 3
            Haz_2_03_type_Count = Haz_2_03_type_Count + 1;
        elseif data(r,2) == 4
            Haz_2_04_type_Count = Haz_2_04_type_Count + 1;
        end
    elseif data(r,6) == 3
        if data(r,2) == 1
            Haz_3_01_type_Count = Haz_3_01_type_Count + 1;
        elseif data(r,2) == 2
            Haz_3_02_type_Count = Haz_3_02_type_Count + 1;
        elseif data(r,2) == 3
            Haz_3_03_type_Count = Haz_3_03_type_Count + 1;
        elseif data(r,2) == 4
            Haz_3_04_type_Count = Haz_3_04_type_Count + 1;
        end
    end
end

data_table_type_haz = [Haz_0_01_type_Count,Haz_1_01_type_Count,Haz_2_01_type_Count,Haz_3_01_type_Count;
                   Haz_0_02_type_Count,Haz_1_02_type_Count,Haz_2_02_type_Count,Haz_3_02_type_Count;
                   Haz_0_03_type_Count,Haz_1_03_type_Count,Haz_2_03_type_Count,Haz_3_03_type_Count;
                   Haz_0_04_type_Count,Haz_1_04_type_Count,Haz_2_04_type_Count,Haz_3_04_type_Count];
            
            
            