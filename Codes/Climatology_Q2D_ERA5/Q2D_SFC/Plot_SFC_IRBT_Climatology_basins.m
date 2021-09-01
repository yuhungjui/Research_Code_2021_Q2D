clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot ERA5 vs. IRBT over land from 1998–2018.
% 
% Domain: Congo, Amazon, CONUS.
% 
% Input:
%       Index:  monthly mean, 0.25-deg resolution.
%       IRBT:   monthly mean, 0.25-deg resolution.
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2018,12,1)]';

% ==============================================================================

%% Set region:

region_id_IRBT_lon = 1:1441; % 901:1441;
region_id_IRBT_lat = 1:321; % 81:241;

% region_id_SST_lon = 1:1440; % 1:721; % 180:721;
% region_id_SST_lat = 1:322; % 81:242;

% ==============================================================================

%% Load IRBT:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_mean_25km_mat/GRIDSAT_IRBT_TROPICS_mean_1998_2018_mnly.mat;

%% Get IRBT over targeted area:

data_IRBT = GRIDSAT_IRBT_MEAN.irbt_mean(region_id_IRBT_lon,region_id_IRBT_lat,:);

data_IRBT_lon = GRIDSAT_IRBT_MEAN.lon(region_id_IRBT_lon);
data_IRBT_lat = GRIDSAT_IRBT_MEAN.lat(region_id_IRBT_lat);

clear GRIDSAT_IRBT_MEAN

% ==============================================================================

%% Load ERA5:

load('/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_sfc_1998_2020/monthly_land_SFC_VARIABLES_1998_2020_interp025_40SN.mat');

ERA5_datai_t2m = ERA5_datai.t2m-273.15;

%% Set variable names:

% ERA5_sfc_var_name = 'sfcT';
% ERA5_sfc_var_name = 'sfcTHETAE';
% ERA5_sfc_var_name = 'sfcRH';
ERA5_sfc_var_name = 'sfcMR';

%% Criteria to ignore the driest areas:

lowMR_id = find(ERA5_datai.MR<4);

%% Set plotting variables:

ERA5_sfc_variable = ERA5_datai.MR;

% ERA5_sfc_variable(lowMR_id) = nan;

% ==============================================================================

%% SHIFT LONGITUDES:

shift_longitude = 1

switch shift_longitude
    case 1
        
        data_IRBT_lon = [ data_IRBT_lon(721:end-1), data_IRBT_lon(1:720) + 360 ];
        data_IRBT = [ data_IRBT(721:end-1,:,:); data_IRBT(1:720,:,:)];
        
end

% ==============================================================================

%% Interpolation:

res = 1;

% gloni = [45:res:180];
gloni = [0:res:360];
glati = [-40:res:40];

[LONi,LATi] = meshgrid(gloni,glati);

pb_1 = CmdLineProgressBar('... Interpolating ... ');

for date_i = 1:numel(date_dur)
    
    %% Interpolation:
    
    data_IRBTi(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,data_IRBT(:,:,date_i)',LONi,LATi)';
    
    data_ERA5i(:,:,date_i) = interp2(ERA5_datai.lon,ERA5_datai.lat,ERA5_sfc_variable(:,:,date_i)',LONi,LATi)';
    
    pb_1.print(date_i,length(date_dur));
    
end 

%% Averaging:

% data_IRBTi = nanmean(data_IRBTi,3);
% data_SSTi = nanmean(data_SSTi,3);

% ==============================================================================

%% Calculation

switch ERA5_sfc_var_name
    case 'sfcT' 
        SFC_ticks = [20:0.5:33]; % [20:0.2:32]; [20:0.25:32];
        SFC_range = [19.75:0.5:33.25]; % [19.9:0.2:32.1]; [19.875:0.25:32.125];
    case 'sfcTHETAE'
        SFC_ticks = [275:5:375]; 
        SFC_range = [272.5:5:377.5];
    case 'sfcRH'
        SFC_ticks = [5:5:100]; 
        SFC_range = [2.5:5:102.5];
    case 'sfcMR'
        SFC_ticks = [0:2:22]; 
        SFC_range = [-1:2:23];
end

data_LONi = repmat(LONi',[1,1,numel(date_dur)]);
data_LATi = repmat(LATi',[1,1,numel(date_dur)]);

% Basins domain limits:

basin_domain = [[50,100,-10,10]; ...    % IO
                [100,130,-10,10]; ...   % MC
                [130,180,-10,10]; ...   % WPAC
                [10,25,-8,8]; ...       % Congo
                [295,310,-35,-20]; ...  % South America
                [260,285,30,40]; ...    % CONUS
                ];

for basini = 4:6
    
    basin_id = find( data_LONi >= basin_domain(basini,1) & data_LONi <= basin_domain(basini,2) ...
                   & data_LATi >= basin_domain(basini,3) & data_LATi <= basin_domain(basini,4));
    
    data_SFCi_basin = data_ERA5i(basin_id);
    data_IRBTi_basin = data_IRBTi(basin_id);
               
    for ssti = 1:numel(SFC_range)-1
        
        SFC_range_id = find( data_SFCi_basin>=SFC_range(ssti) & data_SFCi_basin<SFC_range(ssti+1) );
        
        IRBT_range_mean(ssti,basini) = nanmean(data_IRBTi_basin(SFC_range_id));
        IRBT_range_std(ssti,basini) = nanstd(data_IRBTi_basin(SFC_range_id));
        IRBT_range_num(ssti,basini) = sum(~isnan(data_IRBTi(SFC_range_id)));
        
    end
    
end

%% Criteria for data number:

data_num_cri = 500;

IRBT_range_mean(IRBT_range_num<data_num_cri) = NaN;
IRBT_range_std(IRBT_range_num<data_num_cri) = NaN;

% ==============================================================================

%% 1. Plotting figure.

close all;

gf1 = gcf;

%% Errorbar plot:

% f11 = errorbar(SST_ticks,IRBT_range_m,IRBT_range_std);
% 
% f11.Color = [0.7,0.7,0.7];
% f11.LineWidth = 1.5;

%% Errorbar plot w/ shading:

% nanid = ~isnan(IRBT_range_m);
% 
% lo = IRBT_range_m(nanid) - IRBT_range_std(nanid);
% hi = IRBT_range_m(nanid) + IRBT_range_std(nanid);
% 
% xx = SST_ticks(nanid);
% 
% f12 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);
% 
% set(f12, 'facecolor', [0.8,0.8,0.8], 'edgecolor', 'none');
% 
% hold on;

for fi = [4:6] % specified domain

    f11{fi} = line(SFC_ticks,IRBT_range_mean(:,fi));
    % f11{fi} = errorbar(SST_ticks,IRBT_range_m(:,fi),IRBT_range_std(:,fi));
    
    f11{fi}.Color = [0.2,0.2,0.2];
    f11{fi}.Marker = '.';
    f11{fi}.MarkerSize = 16;
    f11{fi}.LineWidth = 1.5;

    hold on
    
end

% f11{1}.Marker = 'o';
% f11{2}.Marker = '*';
% f11{3}.Marker = 'd';

f11{4}.LineStyle = '-';
f11{5}.LineStyle = ':';
f11{6}.LineStyle = '--';


%% 1. Set axes: Axis 1:

ax11 = gca;

set(ax11,'Box','off','Color','none');
set(ax11,'PlotBoxAspectRatio',[1,1,1])
set(ax11,'Position',[0.125,0.125,0.75,0.75])
set(ax11,'TickDir','out')
set(ax11,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax11,'LineWidth',2)
switch ERA5_sfc_var_name
    case 'sfcT' 
        set(ax11,'Xlim',[20,32])
        set(ax11,'XTick',[20:1:33])
    case 'sfcTHETAE'
        set(ax11,'Xlim',[280,370])
        set(ax11,'XTick',[250:10:400])
    case 'sfcTHETAE'
        set(ax11,'Xlim',[0,100])
        set(ax11,'XTick',[0:10:100])
    case 'sfcMR'
        set(ax11,'Xlim',[0,25])
        set(ax11,'XTick',[0:2:30])
end
% set(ax11,'XTickLabel',[])
set(ax11,'XMinorTick','off','XMinorGrid','off')
set(ax11,'Ylim',[249,296])
set(ax11,'YTick',[250:5:300])
set(ax11,'YMinorTick','off','YMinorGrid','off')
% set(ax11,'YAxisLocation','right')
set(ax11,'YDir','reverse');

%% 1. Labels:
switch ERA5_sfc_var_name
    case 'sfcT' 
        xlabel('\bf{sfc.(2m) T (^\circC)}')
    case 'sfcTHETAE'
        xlabel('\bf{sfc. \theta_e (K)}')
    case 'sfcRH'
        xlabel('\bf{sfc. RH (%)}')
    case 'sfcMR'
        xlabel('\bf{sfc. Mixing Ratio (g/kg)}')
end
ylabel('\bf{IRBT (K)}')

%% 1. Set axes: Axis 2:
ax12 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);

set(ax12,'PlotBoxAspectRatio',[1,1,1])
set(ax12,'TickLength',[0.0050,0.0250])
set(ax12,'TickDir','out')
set(ax12,'LineWidth',2)
set(ax12,'Xlim',ax11.XLim);
set(ax12,'Ylim',ax11.YLim);
set(ax12,'YMinorTick','off')
% set(ax12,'YDir','Reverse')

% Link axes in case of zooming and set original axis as active:
linkaxes([ax11,ax12])
axes(ax11)

% Get the actual axes position:
% ax11_pos = plotboxpos(ax11);

%% 1. Legends:

% leg1 = legend([f11{1},f11{3}],{'IO','WPAC'});
leg1 = legend([f11{4},f11{5},f11{6}],{'Congo','S.America','CONUS'});

% leg1.Position(1) = 0.60;
% leg1.Position(2) = 0.82;
set(leg1,'LineWidth',2)
set(leg1,'FontName','Helvetica','FontSize',16,'FontWeight','bold')
set(leg1,'Box','on')
set(leg1,'Color','none')
set(leg1,'Location','NorthWest')
switch ERA5_sfc_var_name
    case 'sfcTHETAE'
        set(leg1,'Location','SouthWest')
end

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gf1,'Color',[1,1,1]);

figname = ['./',ERA5_sfc_var_name,'_IRBT_Climatology_Basins'];

% print(gf1,'-dpng','-r300',figname);

export_fig([figname,'.png'],'-r300')
% export_fig([figname,'.png'],'-r300','-transparent')

