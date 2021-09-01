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

%% Frequency types:

freq_type{1} = 'Diurnal';
freq_type{2} = 'Quasi-2-Day';
freq_type{3} = 'Total';

% ==============================================================================

%% Load variance significance:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_significance_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2018_mnly.mat;

% ==============================================================================

%% Load variance:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2018_mnly.mat;

% load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/seasonal_var_distribution_25km_mat/',datestr(season_dur(target_season_id,1),'yyyy'),'/GRIDSAT_IRBT_TROPICS_seasonal_var_',season_dur_name{target_season_id},'.mat']);

% ==============================================================================

%% Calculate the Variance according to its Significance:

Var_Map_dc = GRIDSAT_IRBT_VAR.dc;
VarSig_Map_dc = GRIDSAT_IRBT_SIGNIFICANCE.dc;
VarSig_Map_dc(VarSig_Map_dc==0) = NaN;
Var_Map_bySig_dc = Var_Map_dc.*VarSig_Map_dc;

Var_Map_q2d = GRIDSAT_IRBT_VAR.q2d;
VarSig_Map_q2d = GRIDSAT_IRBT_SIGNIFICANCE.q2d;
VarSig_Map_q2d(VarSig_Map_q2d==0) = NaN;
Var_Map_bySig_q2d = Var_Map_q2d.*VarSig_Map_q2d;

data_IRBT_lon = GRIDSAT_IRBT_VAR.lon(region_id_IRBT_lon);
data_IRBT_lat = GRIDSAT_IRBT_VAR.lat(region_id_IRBT_lat);
           
% ==============================================================================

%% Load ERA5 Data:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_CLOUD_1998_2020/monthly_CLOUD_1998_2020_40SN.mat;

ERA5_data.tcc = ERA5_data.tcc.*100;

%% Set variable names:

ERA5_var_name = 'TotalCloudCover';

%% Criteria to ignore the driest areas:

% lowMR_id = find(ERA5_datai.MR<4);

%% Set plotting variables:

ERA5_variable = ERA5_data.tcc;

% ==============================================================================

%% Load Ocean Area:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_OISST_v2/Ocean_Area.mat;

% Ocean_Area.Ocean_ID(:,1441) = Ocean_Area.Ocean_ID(:,1); 

% ==============================================================================

%% SHIFT LONGITUDES:

shift_longitude = 1

switch shift_longitude
    case 1
        
        data_IRBT_lon = [ data_IRBT_lon(721:end-1), data_IRBT_lon(1:720) + 360 ];
        Var_Map_bySig_dc = [ Var_Map_bySig_dc(721:end-1,:,:); Var_Map_bySig_dc(1:720,:,:)];
        Var_Map_bySig_q2d = [ Var_Map_bySig_q2d(721:end-1,:,:); Var_Map_bySig_q2d(1:720,:,:)];
        Var_Map_dc = [ Var_Map_dc(721:end-1,:,:); Var_Map_dc(1:720,:,:)];
        Var_Map_q2d = [ Var_Map_q2d(721:end-1,:,:); Var_Map_q2d(1:720,:,:)];
        
end

% ==============================================================================

%% Categorize Ocean & Land:

% oceanid = Ocean_Area.Ocean_ID;
% oceanid(oceanid==0) = nan;
% landid = Ocean_Area.Ocean_ID;
% landid(landid==1) = nan;
% landid(landid==0) = 1;
% 
% for ti = 1:numel(date_dur)
%     Var_Map_bySig_dc(:,:,ti) = Var_Map_bySig_dc(:,:,ti).*oceanid';
%     Var_Map_bySig_q2d(:,:,ti) = Var_Map_bySig_q2d(:,:,ti).*oceanid';
%     % Var_Map_bySig_dc(:,:,ti) = Var_Map_bySig_dc(:,:,ti).*landid';
%     % Var_Map_bySig_q2d(:,:,ti) = Var_Map_bySig_q2d(:,:,ti).*landid';
% end

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
    
    data_IRBTvari_q2d(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_q2d(:,:,date_i)',LONi,LATi)';
    data_IRBTvari_dc(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_dc(:,:,date_i)',LONi,LATi)';

    data_ERA5i(:,:,date_i) = interp2(ERA5_data.lon,ERA5_data.lat,ERA5_variable(:,:,date_i)',LONi,LATi)';
    
    pb_1.print(date_i,length(date_dur));
    
end 

%% Averaging:

% data_IRBTvari_q2d = nanmean(data_IRBTvari_q2d,3);
% data_IRBTvari_dc = nanmean(data_IRBTvari_dc,3);
data_ERA5im = nanmean(data_ERA5i,3);

% ==============================================================================

%% Calculation

switch ERA5_var_name
    case 'TotalCloudCover'
        Cloud_ticks = [0:5:100]; 
        Cloud_range = [-2.5:5:102.5]; 
end

for cloudi = 1:numel(Cloud_range)-1
    
    Cloud_range_id = find( data_ERA5i>=Cloud_range(cloudi) & data_ERA5i<Cloud_range(cloudi+1) );
    
    IRBTvar_q2d_range_mean(cloudi) = nanmean(data_IRBTvari_q2d(Cloud_range_id));
    IRBTvar_q2d_range_std(cloudi) = nanstd(data_IRBTvari_q2d(Cloud_range_id));
    IRBTvar_q2d_range_num(cloudi) = sum(~isnan(data_IRBTvari_q2d(Cloud_range_id)));
    
    IRBTvar_dc_range_mean(cloudi) = nanmean(data_IRBTvari_dc(Cloud_range_id));
    IRBTvar_dc_range_std(cloudi) = nanstd(data_IRBTvari_dc(Cloud_range_id));
    IRBTvar_dc_range_num(cloudi) = sum(~isnan(data_IRBTvari_dc(Cloud_range_id)));

    CLoud_range_num(cloudi) = numel(Cloud_range_id);

end

%% Criteria for data number:

data_num_cri = 500;

IRBTvar_q2d_range_mean(IRBTvar_q2d_range_num<data_num_cri) = NaN;
IRBTvar_q2d_range_std(IRBTvar_q2d_range_num<data_num_cri) = NaN;

IRBTvar_dc_range_mean(IRBTvar_dc_range_num<data_num_cri) = NaN;
IRBTvar_dc_range_std(IRBTvar_dc_range_num<data_num_cri) = NaN;

% ==============================================================================

%% 1. Plotting figure.

close all;

gf1 = gcf;

q2d_color = [1,0.33,0.33];
dc_color = [0.33,0.67,1];

%% Errorbar plot:

% f11 = errorbar(SST_ticks,IRBT_range_m,IRBT_range_std);
% 
% f11.Color = [0.7,0.7,0.7];
% f11.LineWidth = 1.5;

%% Errorbar plot w/ shading:

nanid = ~isnan(IRBTvar_q2d_range_mean);

lo = IRBTvar_q2d_range_mean(nanid) - IRBTvar_q2d_range_std(nanid);
hi = IRBTvar_q2d_range_mean(nanid) + IRBTvar_q2d_range_std(nanid);

xx = Cloud_ticks(nanid);

f11_2 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f11_2, 'facecolor', q2d_color, 'edgecolor', 'none', 'FaceAlpha', 0.25);

hold on;

nanid = ~isnan(IRBTvar_dc_range_mean);

lo = IRBTvar_dc_range_mean(nanid) - IRBTvar_dc_range_std(nanid);
hi = IRBTvar_dc_range_mean(nanid) + IRBTvar_dc_range_std(nanid);

xx = Cloud_ticks(nanid);

f12_2 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f12_2, 'facecolor', dc_color, 'edgecolor', 'none', 'FaceAlpha', 0.25);

hold on;

f11 = line(Cloud_ticks,IRBTvar_q2d_range_mean);

f11.Color = [0.635,0.078,0.184];
f11.Marker = '.';
f11.MarkerSize = 16;
f11.LineWidth = 1.5;

hold on;

f12 = line(Cloud_ticks,IRBTvar_dc_range_mean);

f12.Color = [0,0.4,1];
f12.Marker = '.';
f12.MarkerSize = 16;
f12.LineWidth = 1.5;


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
set(ax11,'Ylim',[-1,170])
set(ax11,'YTick',[0:20:500])
set(ax11,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','off');

%% 1. Labels:
switch ERA5_var_name
    case 'TotalCloudCover'
        xlabel('\bf{Cloud Cover (%)}')
end
ylabel('\bf{IRBT var. (K^2)}')

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
% set(ax12,'YTick',[1,]);
set(ax12,'YMinorTick','off')
set(ax12,'YScale','log')
set(ax12,'YAxisLocation','right')

ylabel('\bf{Grid Number}')

%% 2. Plot numbers:

f21 = line(Cloud_ticks,IRBTvar_q2d_range_num);

f21.Color = [0.635,0.078,0.184];
f21.LineStyle = '--';
f21.Marker = 'o';
f21.MarkerSize = 6;
f21.LineWidth = 0.5;

hold on;

f22 = line(Cloud_ticks,IRBTvar_dc_range_num);

f22.Color = [0,0.4,1];
f22.LineStyle = '--';
f22.Marker = 'o';
f22.MarkerSize = 6;
f22.LineWidth = 0.5;

%% 3. Set axes: Axis 3:
ax13 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);

set(ax13,'PlotBoxAspectRatio',[1,1,1])
set(ax13,'TickDir','out')
set(ax13,'LineWidth',2)

%% 1. Legends:

leg1 = legend([f12,f11,f22,f21],{'dc','q2d','#(dc)','#(q2d)'});
% leg1 = columnlegend(2, {'dc','q2d','#(dc)','#(q2d)'});

% leg1.Position(1) = 0.60;
% leg1.Position(2) = 0.82;
set(leg1,'LineWidth',2)
set(leg1,'FontName','Helvetica','FontSize',16,'FontWeight','bold')
set(leg1,'Box','on')
set(leg1,'Color','none')
set(leg1,'Location','NorthWest')

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gf1,'Color',[1,1,1]);

figname = ['./',ERA5_var_name,'_IRBTvar_Climatology'];

% print(gf1,'-dpng','-r300',figname);

export_fig([figname,'.png'],'-r300')
% export_fig([figname,'.png'],'-r300','-transparent')

