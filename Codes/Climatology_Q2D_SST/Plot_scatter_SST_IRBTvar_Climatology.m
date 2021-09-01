clear; close; clc;

addpath(genpath('/Users/yuhungjui/Dropbox/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot scatter plots for SST vs. IRBT var. over torpical oceans from 1998–2018.
% 
% Domain: specified (45E–180E, 20S–20N).
% 
% Input:
%       SST:  monthly mean, 0.25-deg resolution.
%       IRBT: monthly mean, 0.25-deg resolution.
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2018,12,1)]';

% ==============================================================================

%% Set region:

% 45E–180E, 20S–20N:
region_id_IRBT_lon = 901:1441;
region_id_IRBT_lat = 81:241;
region_id_SST_lon = 180:721;
region_id_SST_lat = 81:242;

% ==============================================================================

%% Frequency types:

freq_type{1} = 'Diurnal';
freq_type{2} = 'Quasi-2-Day';
freq_type{3} = 'Total';

% ==============================================================================

%% Load IRBT variance:

pb_1 = CmdLineProgressBar('... Loading ... ');

for date_i = 1:length(date_dur)
    
    %% Load Variance Map Data:
    
    load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
    % load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_(pn15d)_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
    
    %% Get Q2D, DC variance:
    
    data_IRBTvar_q2d(:,:,date_i) = GRIDSAT_IRBT_VAR.q2d(region_id_IRBT_lon,region_id_IRBT_lat);
    data_IRBTvar_dc(:,:,date_i) = GRIDSAT_IRBT_VAR.dc(region_id_IRBT_lon,region_id_IRBT_lat);

    if ( date_i==numel(date_dur) )
        
        data_IRBTvar_lon = GRIDSAT_IRBT_VAR.lon(region_id_IRBT_lon);
        data_IRBTvar_lat = GRIDSAT_IRBT_VAR.lat(region_id_IRBT_lat);
        
    end
    
    clear GRIDSAT_IRBT_VAR
    
    pb_1.print(date_i,length(date_dur));
    
end
           
% ==============================================================================

%% Load SST:

pb_2 = CmdLineProgressBar('... Loading ... ');

di = 1;

for yr_i = 1998:2018
    
    %% Load SST Map Data:
    
    load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_OISST_v2/monthly_hires_mat/NOAA_OISST_TROPICS_',num2str(yr_i),'_mnly.mat']);
    
    %% Get SST over targeted area:
    
    if ( yr_i == 1998 )
    
        data_SST = NOAA_OISST_TROPICS_mnly.sst_mnly(region_id_SST_lon,region_id_SST_lat,:); % cover 45E–180E, 20S–20N
    
    else
        
        tmp_data_SST = NOAA_OISST_TROPICS_mnly.sst_mnly(region_id_SST_lon,region_id_SST_lat,:); % cover 45E–180E, 20S–20N
        data_SST = cat(3,data_SST,tmp_data_SST);

    end
    
    if ( yr_i == 2018 )
        
        data_SST_lon = NOAA_OISST_TROPICS_mnly.lon(region_id_SST_lon); % cover 45E–180E
        data_SST_lat = NOAA_OISST_TROPICS_mnly.lat(region_id_SST_lat); % cover 20S–20N
        
    end
    
    di = di + 1;
    
    clear GRIDSAT_IRBT
    
    pb_2.print(yr_i,2018);
    
end

% ==============================================================================

%% Interpolation:

% Interpolate the map data of IRBT and SST to the given resolution.

res = 2;

gloni = [45:res:180];
glati = [-20:res:20];

[LONi,LATi] = meshgrid(gloni,glati);

pb_1 = CmdLineProgressBar('... Interpolating ... ');

for date_i = 1:numel(date_dur)
    
    %% Interpolation:
    
    data_IRBTvari_q2d(:,:,date_i) = interp2(data_IRBTvar_lon,data_IRBTvar_lat,data_IRBTvar_q2d(:,:,date_i)',LONi,LATi)';
    data_IRBTvari_dc(:,:,date_i) = interp2(data_IRBTvar_lon,data_IRBTvar_lat,data_IRBTvar_dc(:,:,date_i)',LONi,LATi)';

    data_SSTi(:,:,date_i) = interp2(data_SST_lon,data_SST_lat,data_SST(:,:,date_i)',LONi,LATi)';
    
    pb_1.print(date_i,length(date_dur));
    
end 

%% Averaging:

data_IRBTvari_q2d = nanmean(data_IRBTvari_q2d,3);
data_IRBTvari_dc = nanmean(data_IRBTvari_dc,3);
data_SSTi = nanmean(data_SSTi,3);

% ==============================================================================

%% 1. Plotting figure.

close all;

gf1 = gcf;

q2d_color = [0.33,0.67,1];
dc_color = [1,0.33,0.33];

% Scatter:

f11 = scatter(data_SSTi(:),data_IRBTvari_q2d(:),12);

f11.MarkerFaceColor = q2d_color;
f11.MarkerFaceAlpha = 0.5;
f11.MarkerEdgeColor = q2d_color;
f11.MarkerEdgeAlpha = 0.8;

hold on;

f12 = scatter(data_SSTi(:),data_IRBTvari_dc(:),12);

f12.MarkerFaceColor = dc_color;
f12.MarkerFaceAlpha = 0.5;
f12.MarkerEdgeColor = dc_color;
f12.MarkerEdgeAlpha = 0.8;


%% 1. Set axes: Axis 1:

ax11 = gca;

set(ax11,'Box','off','Color','none');
set(ax11,'PlotBoxAspectRatio',[1,1,1])
set(ax11,'Position',[0.125,0.125,0.75,0.75])
set(ax11,'TickDir','out')
set(ax11,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax11,'LineWidth',2)
set(ax11,'Xlim',[23.5,30.5])
set(ax11,'XTick',[20:1:31])
% set(ax11,'XTickLabel',[])
set(ax11,'XMinorTick','off','XMinorGrid','off')
set(ax11,'Ylim',[-1,120])
set(ax11,'YTick',[0:20:500])
set(ax11,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','off');

%% 1. Labels:
xlabel('\bf{SST (^\circC)}')
ylabel('\bf{IRBT var. (K^2)}')

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

leg1 = legend([f12,f11],{'dc','q2d'});
% leg1 = legend([f11],{'q2d.'});

% leg1.Position(1) = 0.60;
% leg1.Position(2) = 0.82;
set(leg1,'LineWidth',2)
set(leg1,'FontName','Helvetica','FontSize',18,'FontWeight','bold')
set(leg1,'Box','on')
set(leg1,'Color','none')
set(leg1,'Location','NorthWest')

% ==============================================================================

disp([num2str(toc),' sec.'])
a
% ==============================================================================

%% Save Figure:
set(gf1,'Color',[1,1,1]);

figname = ['./Scatter_SST_IRBTvar_Climatology'];

% print(gf1,'-dpng','-r300',figname);

export_fig([figname,'.png'],'-r300')
% export_fig([figname,'.png'],'-r300','-transparent')

