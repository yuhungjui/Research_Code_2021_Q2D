clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot ERA5 cloud condition vs. IRBT over land from 1998–2018.
% 
% Input:
%       Cloud:  monthly mean, 0.25-deg resolution.
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

% IRBT(1)/IRWVP(2):
IR_channel_id = 1

switch IR_channel_id
    case 1
        load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_mean_25km_mat/GRIDSAT_IRBT_TROPICS_mean_1998_2018_mnly.mat;
        data_IRBT = GRIDSAT_IRBT_MEAN.irbt_mean(region_id_IRBT_lon,region_id_IRBT_lat,:);
        data_IRBT_lon = GRIDSAT_IRBT_MEAN.lon(region_id_IRBT_lon);
        data_IRBT_lat = GRIDSAT_IRBT_MEAN.lat(region_id_IRBT_lat);
        clear GRIDSAT_IRBT_MEAN
    case 2
        load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IRWVP_25km_mat/monthly_mean_25km_mat/GRIDSAT_IRWVP_TROPICS_mean_1998_2019_mnly.mat;
        data_IRBT = GRIDSAT_IRWVP_MEAN.irwvp_mean(region_id_IRBT_lon,region_id_IRBT_lat,:);
        data_IRBT_lon = GRIDSAT_IRWVP_MEAN.lon(region_id_IRBT_lon);
        data_IRBT_lat = GRIDSAT_IRWVP_MEAN.lat(region_id_IRBT_lat);
        clear GRIDSAT_IRBT_MEAN
end

% ==============================================================================

%% Load ERA5 Data:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_CLOUD_1998_2020/monthly_CLOUD_1998_2020_40SN.mat;

ERA5_var_name = 'TotalCloudCover';

ERA5_data.tcc = ERA5_data.tcc.*100;

ERA5_variable = ERA5_data.tcc;

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
    
    data_ERA5i(:,:,date_i) = interp2(ERA5_data.lon,ERA5_data.lat,ERA5_variable(:,:,date_i)',LONi,LATi)';
    
    pb_1.print(date_i,length(date_dur));
    
end 

%% Averaging:

% data_IRBTi = nanmean(data_IRBTi,3);
data_ERA5im = nanmean(data_ERA5i,3);

%% Ignore certain areas:

% for ti = 1:size(data_IRBTi,3)
%     % Sahara Desert:
%     data_IRBTi(1:41,51:71,ti) = nan;
%     data_ERA5i(1:41,51:71,ti) = nan;
%     % Tibetan Plateau:
%     data_IRBTi(76:101,71:81,ti) = nan;
%     data_ERA5i(76:101,71:81,ti) = nan;
% end

% ==============================================================================

%% Calculation

% SST_ticks = [20:1:33]; % [20:0.5:32]; % [20:0.2:32]; [20:0.25:32];
% SST_range = [19.5:1:33.5]; % [19.75:0.5:32.25]; % [19.9:0.2:32.1]; [19.875:0.25:32.125];

switch ERA5_var_name
    case 'TotalCloudCover'
        Cloud_ticks = [0:5:100]; 
        Cloud_range = [-2.5:5:102.5]; 
end

for cloudi = 1:numel(Cloud_range)-1
    
    Cloud_range_id = find( data_ERA5i>=Cloud_range(cloudi) & data_ERA5i<Cloud_range(cloudi+1) );
    
    IRBT_range_mean(cloudi) = nanmean(data_IRBTi(Cloud_range_id));
    IRBT_range_std(cloudi) = nanstd(data_IRBTi(Cloud_range_id));
    IRBT_range_num(cloudi) = sum(~isnan(data_IRBTi(Cloud_range_id)));
    % SST_range_num(ssti) = numel(SST_range_id);

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

nanid = ~isnan(IRBT_range_mean);

lo = IRBT_range_mean(nanid) - IRBT_range_std(nanid);
hi = IRBT_range_mean(nanid) + IRBT_range_std(nanid);

xx = Cloud_ticks(nanid);

f11_2 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f11_2, 'facecolor', [0.8,0.8,0.8], 'edgecolor', 'none');

hold on;

f11 = line(Cloud_ticks,IRBT_range_mean);

f11.Color = [0.2,0.2,0.2];
f11.Marker = '.';
f11.MarkerSize = 16;
f11.LineWidth = 1.5;

hold on;

%% 1. Set axes: Axis 1:

ax11 = gca;

set(ax11,'Box','off','Color','none');
set(ax11,'PlotBoxAspectRatio',[1,1,1])
set(ax11,'Position',[0.125,0.125,0.75,0.75])
set(ax11,'TickDir','out')
set(ax11,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax11,'LineWidth',2)
switch ERA5_var_name
    case 'TotalCloudCover'
        set(ax11,'Xlim',[0,100])
        set(ax11,'XTick',[0:10:100])
end
% set(ax11,'XTickLabel',[])
set(ax11,'XMinorTick','off','XMinorGrid','off')
switch IR_channel_id
    case 1
        set(ax11,'Ylim',[264,296])
        set(ax11,'YTick',[250:5:300])
    case 2
        set(ax11,'Ylim',[229,251])
        set(ax11,'YTick',[230:2:250])
end
set(ax11,'YMinorTick','off','YMinorGrid','off')
% set(ax11,'YAxisLocation','right')
set(ax11,'YDir','reverse');

%% 1. Labels:
switch ERA5_var_name
    case 'TotalCloudCover' 
        xlabel('\bf{Cloud Cover (%)}')
end
switch IR_channel_id
    case 1
        ylabel('\bf{IRBT (K)}')
    case 2
        ylabel('\bf{IRWVP (K)}')
end

%% 2. Set axes: Axis 2:
ax12 = axes('Position',get(ax11,'Position'),'Box','off','Color','none','XTick',[]);

set(ax12,'PlotBoxAspectRatio',[1,1,1])
set(ax12,'TickLength',[0.0050,0.0250])
set(ax12,'TickDir','out')
set(ax12,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
set(ax12,'TickDir','out')
set(ax12,'LineWidth',2)
set(ax12,'Xlim',ax11.XLim);
set(ax12,'Ylim',[1,1e8]);
set(ax12,'YMinorTick','off')
set(ax12,'YScale','log')
set(ax12,'YAxisLocation','right')

% ylabel('\bf{1^\circx1^\circ Grid Number}')
ylabel('\bf{Grid Number}')

%% 2. Plot numbers:

f12 = line(Cloud_ticks,IRBT_range_num);

f12.Color = [0.4,0.4,0.4];
f12.LineStyle = '--';
f12.Marker = 'o';
f12.MarkerSize = 6;
f12.LineWidth = 0.5;

%% 3. Set axes: Axis 3:
ax13 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);

set(ax13,'PlotBoxAspectRatio',[1,1,1])
set(ax13,'TickDir','out')
set(ax13,'LineWidth',2)

% Link axes in case of zooming and set original axis as active:
% linkaxes([ax11,ax12])
% axes(ax11)

% Get the actual axes position:
% ax11_pos = plotboxpos(ax11);

%% 1. Legends:

% leg1 = legend([f11,f12],{'mean','stdev.'});
leg1 = legend([f11,f12],{'mean','number'});

% leg1.Position(1) = 0.60;
% leg1.Position(2) = 0.82;
set(leg1,'LineWidth',2)
set(leg1,'FontName','Helvetica','FontSize',16,'FontWeight','bold')
set(leg1,'Box','on')
set(leg1,'Color','none')
set(leg1,'Location','NorthWest')
switch ERA5_var_name
    case 'sfcMR'
        set(leg1,'Location','SouthEast')
    case 'sfcTHETAE'
        set(leg1,'Location','SouthWest')
end

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gf1,'Color',[1,1,1]);

figname = ['./',ERA5_var_name,'_IRBT_Climatology'];

% print(gf1,'-dpng','-r300',figname);

export_fig([figname,'.png'],'-r300')
% export_fig([figname,'.png'],'-r300','-transparent')

