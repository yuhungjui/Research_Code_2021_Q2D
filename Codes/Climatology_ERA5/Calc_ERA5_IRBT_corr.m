clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Quantitative spatial correlation analysis for ERA5 variables 
% and IRBT-related variables.
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2019,12,1)]';

% Get_Seasons_1998_2019;

seasonal_switch = 0;
% seasonal_range = [6,7,8];
seasonal_range = [12,1,2];
seasonal_id = find(ismember(date_dur.Month,seasonal_range)==1);

%% Basins domain limits:

basin_domain = [[50,100,-10,10]; ...    % IO
                [100,130,-10,10]; ...   % MC
                [130,180,-10,10]; ...   % WPAC
                [10,25,-8,8]; ...       % Congo
                [295,310,-35,-20]; ...  % South America
                [260,285,30,40]; ...    % CONUS
                [288,308,-10,5]; ...    % Amazon
                ];
            
basin_selected = 7;

% ==============================================================================

%% Load ERA5 data:

% load('/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_sfc_1998_2020/monthly_land_SFC_VARIABLES_1998_2020_interp025_40SN.mat');

% load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_CLOUD_1998_2020/monthly_CLOUD_1998_2020_40SN.mat;
% ERA5_data.tcc = ERA5_data.tcc.*100;

load /Users/yuhungjui/Data/2021_Q2D/DATA_ERA5/monthly_Conv_Index_1998_2020_40SN.mat;

%% Set variable names:

ERA5_var_name = 'cape';

% ERA5_sfc_var_name = 'sfcT';
% ERA5_sfc_var_name = 'sfcTHETAE';
% ERA5_sfc_var_name = 'sfcRH';
% ERA5_sfc_var_name = 'sfcMR';

% ERA5_var_name = 'TotalCloudCover';

%% Set plotting variables:

eval([ 'ERA5_variable = ERA5_data.',ERA5_var_name,';' ]);

% ==============================================================================

%% Get mean:

switch seasonal_switch 
    case 0
        ERA5_variable = nanmean(ERA5_variable(:,:,1:numel(date_dur)),3);
    case 1
        ERA5_variable = nanmean(ERA5_variable(:,:,seasonal_id),3);
end

ERA5_variable = fliplr(ERA5_variable);

%% Get Lon/Lat:

ERA5_LON = ERA5_data.lon;
ERA5_LAT = flipud(ERA5_data.lat);

clear ERA5_data*

% ==============================================================================

%% Load variance significance:

load /Users/yuhungjui/Data/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2019_mnly.mat;

% ==============================================================================

%% Load variance:

load /Users/yuhungjui/Data/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

% ==============================================================================

%% Frequency types:

freq_type{1} = 'dc';
freq_type{2} = 'q2d';
freq_type{3} = 'total';

freq_id = 3

% ==============================================================================

%% Calculate the Variance according to its Significance:

eval([ 'Var_Map = GRIDSAT_IRBT_VAR.',freq_type{freq_id},';' ]);

if ( freq_id == 3 )
    Var_Map_bySig = Var_Map;
else
    eval([ 'VarSig_Map = GRIDSAT_IRBT_SIGNIFICANCE.',freq_type{freq_id},';' ]);
    Var_Map_bySig = Var_Map.*VarSig_Map;
    % Var_Map_bySig = Var_Map;
end

% ==============================================================================

%% Get mean:

% eval([ 'Var_Map = sqrt(GRIDSAT_IRBT_VAR.',freq_type{freq_id},');' ]);
% eval([ 'Var_Map = GRIDSAT_IRBT_VAR.',freq_type{freq_id},';' ]);
% eval([ 'Var_Map(GRIDSAT_IRBT_SIGNIFICANCE.',freq_type{freq_id},'==0) = NaN;' ]);

switch seasonal_switch
    case 0
        Var_Map_mean = nanmean(Var_Map_bySig(:,:,:),3);
    otherwise
        Var_Map_mean = nanmean(Var_Map_bySig(:,:,seasonal_id),3);
end
% Var_Map_mean = Var_Map;

clear *_Map

%% Get Lon/Lat:

IRBT_LON = GRIDSAT_IRBT_VAR.lon;
IRBT_LAT = GRIDSAT_IRBT_VAR.lat;

clear GRIDSAT_IRBT_VAR
clear GRIDSAT_IRBT_SIGNIFICANCE

% ==============================================================================

%% SHIFT LONGITUDES:

shift_longitude = 1

switch shift_longitude
    case 1
        
        IRBT_LON = [ IRBT_LON(721:end-1), IRBT_LON(1:720) + 360 ];
        
        Var_Map_mean = [ Var_Map_mean(721:end-1,:,:); Var_Map_mean(1:720,:,:)];
        
end

% ==============================================================================

%% Interpolation:

res = 0.25;

% gloni = [45:res:180];
gloni = [0:res:360];
glati = [-40:res:40];

[LONi,LATi] = meshgrid(gloni,glati);
    
Var_Map_mean_i = interp2(IRBT_LON, IRBT_LAT, Var_Map_mean', LONi, LATi)';
ERA5_variable_i = interp2(ERA5_LON, ERA5_LAT, ERA5_variable', LONi, LATi)';

data_LONi = LONi';
data_LATi = LATi';

% ==============================================================================

%% Select basin:

for basini = 6 % basin_selected
                
    basin_id_lon = find( gloni >= basin_domain(basini,1) & gloni <= basin_domain(basini,2));
    basin_id_lat = find( glati >= basin_domain(basini,3) & glati <= basin_domain(basini,4));
    
    data_ERA5_basin = ERA5_variable_i(basin_id_lon, basin_id_lat);
    data_Var_Map_mean_basin = Var_Map_mean(basin_id_lon, basin_id_lat);

end

% ==============================================================================

%% Calculate the 2-D correlation coefficient:

RR = corr2(Var_Map_mean, ERA5_variable);

RR2 = corr2(data_Var_Map_mean_basin, data_ERA5_basin);

disp(RR)
disp(RR2)



