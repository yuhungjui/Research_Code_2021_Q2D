    clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot ERA vs. IRBT over land from 1998–2018.
% 
% Domain: Congo, Amazon, South America, CONUS
% 
% Input:
%       Index:  monthly mean, 0.25-deg resolution.
%       IRBT:   monthly mean, 0.25-deg resolution.
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2019,12,1)]';

seasonal_switch = 1;
seasonal_range = [3,4,5];
% seasonal_range = [6,7,8];
% seasonal_range = [4,5,6,7,8,9];
% seasonal_range = [9,10,11];
% seasonal_range = [12,1,2];
seasonal_id = find(ismember(date_dur.Month,seasonal_range)==1);

% ==============================================================================

%% Set region:

region_id_IRBT_lon = 1:1441; % 901:1441;
region_id_IRBT_lat = 1:321; % 81:241;

% region_id_SST_lon = 1:1440; % 1:721; % 180:721;
% region_id_SST_lat = 1:322; % 81:242;

%% Basins domain limits:

basin_domain = [[50,100,-10,10]; ...    % IO
                [100,130,-10,10]; ...   % MC
                [130,180,-10,10]; ...   % WPAC
                [10,25,-8,8]; ...       % Congo
                [295,310,-35,-20]; ...  % South America
                [260,285,30,40]; ...    % CONUS
                [288,308,-10,5]; ...    % Amazon
                ];
            
basin_selected = [5,6];

% ==============================================================================

%% Frequency types:

freq_type{1} = 'Diurnal';
freq_type{2} = 'Quasi-2-Day';
freq_type{3} = 'Total';

% ==============================================================================

%% Load variance significance:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_significance_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2019_mnly.mat;

% ==============================================================================

%% Load variance:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

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

%% Load ERA5:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_Conv_Index_1998_2020/monthly_Conv_Index_1998_2020_40SN.mat;

%% Set variable names:

ERA5_CX_var_name = 'cape';
% ERA5_CX_var_name = 'cin';
% ERA5_CX_var_name = 'kx';
% ERA5_CX_var_name = 'blh';

%% Criteria to ignore the driest areas:

% lowMR_id = find(ERA5_datai.MR<4);

%% Set plotting variables:

eval([ 'ERA5_CX_variable = ERA5_data.',ERA5_CX_var_name,';' ]);

% ==============================================================================

%% Load Ocean Area:

load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_OISST_v2/Ocean_Area.mat;

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

oceanid = Ocean_Area.Ocean_ID;
oceanid(oceanid==0) = nan;
landid = Ocean_Area.Ocean_ID;
landid(landid==1) = nan;
landid(landid==0) = 1;

for ti = 1:numel(date_dur)
    Var_Map_bySig_dc_land(:,:,ti) = Var_Map_bySig_dc(:,:,ti).*landid';
    Var_Map_bySig_q2d_land(:,:,ti) = Var_Map_bySig_q2d(:,:,ti).*landid';
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
    
    data_IRBTvari_q2d(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_q2d(:,:,date_i)',LONi,LATi)';
    data_IRBTvari_dc(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_dc(:,:,date_i)',LONi,LATi)';
    
    data_IRBTvari_q2d_land(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_q2d_land(:,:,date_i)',LONi,LATi)';
    data_IRBTvari_dc_land(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_dc_land(:,:,date_i)',LONi,LATi)';

    data_ERA5i(:,:,date_i) = interp2(ERA5_data.lon,ERA5_data.lat,ERA5_CX_variable(:,:,date_i)',LONi,LATi)';
    
    pb_1.print(date_i,length(date_dur));
    
end

% ==============================================================================

%% Calculation

switch ERA5_CX_var_name
    case 'cape' 
        SFC_ticks = [0:200:3000];
        SFC_range = [-100:200:3100];
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

%% For seasons:
if seasonal_switch == 1
    data_IRBTvari_q2d = data_IRBTvari_q2d(:,:,seasonal_id);
    data_IRBTvari_dc = data_IRBTvari_dc(:,:,seasonal_id);
    data_IRBTvari_q2d_land = data_IRBTvari_q2d_land(:,:,seasonal_id);
    data_IRBTvari_dc_land = data_IRBTvari_dc_land(:,:,seasonal_id);
    data_ERA5i = data_ERA5i(:,:,seasonal_id);
    data_LONi = data_LONi(:,:,seasonal_id);
    data_LATi = data_LATi(:,:,seasonal_id);
end

for basini = basin_selected
                
    basin_id = find( data_LONi >= basin_domain(basini,1) & data_LONi <= basin_domain(basini,2) ...
                   & data_LATi >= basin_domain(basini,3) & data_LATi <= basin_domain(basini,4));
    
    data_ERA5i_basin = data_ERA5i(basin_id);
    % data_IRBTvari_q2d_basin = data_IRBTvari_q2d(basin_id);
    % data_IRBTvari_dc_basin = data_IRBTvari_dc(basin_id);
    data_IRBTvari_q2d_basin = data_IRBTvari_q2d_land(basin_id);
    data_IRBTvari_dc_basin = data_IRBTvari_dc_land(basin_id);
    
    for ssti = 1:numel(SFC_range)-1
        
        SFC_range_id = find( data_ERA5i_basin>=SFC_range(ssti) & data_ERA5i_basin<SFC_range(ssti+1) );
        
        IRBTvar_q2d_range_mean(ssti,basini) = nanmean(data_IRBTvari_q2d_basin(SFC_range_id));
        IRBTvar_q2d_range_std(ssti,basini) = nanstd(data_IRBTvari_q2d_basin(SFC_range_id));
        IRBTvar_q2d_range_num(ssti,basini) = sum(~isnan(data_IRBTvari_q2d(SFC_range_id)));
        
        IRBTvar_dc_range_mean(ssti,basini) = nanmean(data_IRBTvari_dc_basin(SFC_range_id));
        IRBTvar_dc_range_std(ssti,basini) = nanstd(data_IRBTvari_dc_basin(SFC_range_id));
        IRBTvar_dc_range_num(ssti,basini) = sum(~isnan(data_IRBTvari_dc(SFC_range_id)));
        
        IRBTvar_range_num(ssti,basini) = numel(SFC_range_id);
        
    end

end

%% Criteria for data number:

data_num_cri = 500;
if ( ismember(basin_selected,[5,6]) == 1 )
    data_num_cri = 200;
end

IRBTvar_q2d_range_mean(IRBTvar_range_num<data_num_cri) = NaN;
IRBTvar_q2d_range_std(IRBTvar_range_num<data_num_cri) = NaN;

IRBTvar_dc_range_mean(IRBTvar_range_num<data_num_cri) = NaN;
IRBTvar_dc_range_std(IRBTvar_range_num<data_num_cri) = NaN;

% ==============================================================================

%% Set plotting only one region:

% IRBTvar_q2d_range_mean(:,5) = nan(size(IRBTvar_q2d_range_mean(:,5)));
% IRBTvar_dc_range_mean(:,5) = nan(size(IRBTvar_dc_range_mean(:,5)));
IRBTvar_q2d_range_mean(:,6) = nan(size(IRBTvar_q2d_range_mean(:,6)));
IRBTvar_dc_range_mean(:,6) = nan(size(IRBTvar_dc_range_mean(:,6)));

% ==============================================================================

%% 1. Plotting figure.

close all;

gf1 = gcf;

q2d_color = [0.635,0.078,0.184]; % [1,0.33,0.33];
dc_color = [0,0.4,1]; % [0.33,0.67,1];

%% Errorbar plot:

% f11 = errorbar(SST_ticks,IRBT_range_m,IRBT_range_std);
% 
% f11.Color = [0.7,0.7,0.7];
% f11.LineWidth = 1.5;

%% Errorbar plot w/ shading:

% nanid = ~isnan(IRBTvar_q2d_range_m);
% 
% lo = IRBTvar_q2d_range_m(nanid) - IRBTvar_q2d_range_std(nanid);
% hi = IRBTvar_q2d_range_m(nanid) + IRBTvar_q2d_range_std(nanid);
% 
% xx = SST_ticks(nanid);
% 
% f12 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);
% 
% set(f12, 'facecolor', q2d_color, 'edgecolor', 'none', 'FaceAlpha', 0.3);
% 
% hold on;
% 
% nanid = ~isnan(IRBTvar_dc_range_m);
% 
% lo = IRBTvar_dc_range_m(nanid) - IRBTvar_dc_range_std(nanid);
% hi = IRBTvar_dc_range_m(nanid) + IRBTvar_dc_range_std(nanid);
% 
% xx = SST_ticks(nanid);
% 
% f22 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);
% 
% set(f22, 'facecolor', dc_color, 'edgecolor', 'none', 'FaceAlpha', 0.3);
% 
% hold on;

for fi = basin_selected % specified domain

    f11{fi} = line(SFC_ticks,IRBTvar_q2d_range_mean(:,fi));
    
    f11{fi}.Color = q2d_color;
    f11{fi}.Marker = '.';
    f11{fi}.MarkerSize = 16;
    f11{fi}.LineWidth = 1.5;

    hold on
    
end

f11{4}.LineStyle = '-';
f11{5}.LineStyle = '-';
f11{6}.LineStyle = '--';
f11{7}.LineStyle = '--';

for fi = basin_selected % specified domain

    f21{fi} = line(SFC_ticks,IRBTvar_dc_range_mean(:,fi));
    
    f21{fi}.Color = dc_color;
    f21{fi}.Marker = '.';
    f21{fi}.MarkerSize = 16;
    f21{fi}.LineWidth = 1.5;

    hold on
    
end

f21{4}.LineStyle = '-';
f21{5}.LineStyle = '-';
f21{6}.LineStyle = '--';
f21{7}.LineStyle = '--';


%% 1. Set axes: Axis 1:

ax11 = gca;

set(ax11,'Box','off','Color','none');
set(ax11,'PlotBoxAspectRatio',[1,1,1])
set(ax11,'Position',[0.125,0.125,0.75,0.75])
set(ax11,'TickDir','out')
set(ax11,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax11,'LineWidth',2)
switch ERA5_CX_var_name
    case 'cape' 
        set(ax11,'Xlim',[0,2400])
        set(ax11,'XTick',[0:400:3200])
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
set(ax11,'XTickLabel',[])
set(ax11,'XMinorTick','off','XMinorGrid','off')
set(ax11,'Ylim',[-1,185])
set(ax11,'YTick',[0:20:500])
set(ax11,'YMinorTick','on','YMinorGrid','off')
set(ax11,'YAxisLocation','right')
% set(ax1,'YGrid','off');

%% 1. Labels:
switch ERA5_CX_var_name
    case 'cape' 
        % xlabel('\bf{CAPE (J\cdotkg^{-1})}')
    case 'sfcTHETAE'
        xlabel('\bf{sfc. \theta_e (K)}')
    case 'sfcRH'
        xlabel('\bf{sfc. RH (%)}')
    case 'sfcMR'
        xlabel('\bf{sfc. Mixing Ratio (g/kg)}')
end
ylabel('\bf{IRBT var. (K^2)}')

%% 1. Set axes: Axis 2:
% ax12 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);
% 
% set(ax12,'PlotBoxAspectRatio',[1,1,1])
% set(ax12,'TickLength',[0.0050,0.0250])
% set(ax12,'TickDir','out')
% set(ax12,'LineWidth',2)
% set(ax12,'Xlim',ax11.XLim);
% set(ax12,'Ylim',ax11.YLim);
% set(ax12,'YMinorTick','off')
% % set(ax12,'YDir','Reverse')
% 
% % Link axes in case of zooming and set original axis as active:
% linkaxes([ax11,ax12])
% axes(ax11)
% 
% % Get the actual axes position:
% % ax11_pos = plotboxpos(ax11);
% 
% %% 1. Legends:
% 
% % leg1 = legend([f11{1},f11{2},f11{3},f21{1},f21{2},f21{3}], ...
% %               {'q2d (IO)','q2d (MC)','q2d (WPAC)','dc (IO)','dc (MC)','dc (WPAC)'} ...
% %               );
% leg1 = legend([f11{4},f11{5},f11{6},f21{4},f21{5},f21{6}], ...
%               {'q2d(Congo)','q2d(S.America)','q2d(CONUS)','dc(Congo)','dc(S.America)','dc(CONUS)'} ...
%               );
% 
% % leg1.Position(1) = 0.60;
% % leg1.Position(2) = 0.82;
% set(leg1,'LineWidth',2)
% set(leg1,'FontName','Helvetica','FontSize',16,'FontWeight','bold')
% set(leg1,'Box','on')
% set(leg1,'Color','none')
% set(leg1,'Location','NorthWest')
% switch ERA5_CX_var_name
%     case 'cape'
%         set(leg1,'Location','NorthEast')
% end

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gf1,'Color',[1,1,1]);

figname = ['./',ERA5_CX_var_name,'_IRBTvar_Climatology_Basins_Land'];

% print(gf1,'-dpng','-r300',figname);

% export_fig([figname,'.png'],'-r300')
export_fig([figname,'.png'],'-r300','-transparent')

