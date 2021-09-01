clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot ERA5 Convective Index vs. IRBT over land from 1998–2018.
% 
% Input:
%       Index:  monthly mean, 0.25-deg resolution.
%       IRBT:   monthly mean, 0.25-deg resolution.
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2019,12,1)]';

cloud_frac_switch = 0

if ( cloud_frac_switch == 1 )
    date_dur = [datetime(1998,1,1):calmonths(1):datetime(2016,12,1)]';
end

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

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2019_mnly.mat;

% ==============================================================================

%% Load variance:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

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

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_ERA5/monthly_Conv_Index_1998_2020_40SN.mat;

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

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_OISST_v2/Ocean_Area.mat;

% ==============================================================================

%% Load ISCCP Data:

if ( cloud_frac_switch == 1 )
    load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_ISCCP_Basic/ISCCP_Basic_HGM_CloudAmount_1998_2017_mnly.mat;
    ISCCP_var_name = 'CloudFraction';
    ISCCP_variable = ISCCP_B_HGM_data.cldamt;
    % ISCCP_variable = ISCCP_B_HGM_data.cldamt_ir;
end

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
    Var_Map_bySig_dc_ocean(:,:,ti) = Var_Map_bySig_dc(:,:,ti).*oceanid';
    Var_Map_bySig_q2d_ocean(:,:,ti) = Var_Map_bySig_q2d(:,:,ti).*oceanid';
    Var_Map_bySig_dc_land(:,:,ti) = Var_Map_bySig_dc(:,:,ti).*landid';
    Var_Map_bySig_q2d_land(:,:,ti) = Var_Map_bySig_q2d(:,:,ti).*landid';
end

Var_Map_bySig_q2d = Var_Map_bySig_q2d_ocean;
Var_Map_bySig_dc = Var_Map_bySig_dc_ocean;

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

    data_IRBTvari_q2d_ocean(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_q2d_ocean(:,:,date_i)',LONi,LATi)';
    data_IRBTvari_dc_ocean(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_dc_ocean(:,:,date_i)',LONi,LATi)';

    data_IRBTvari_q2d_land(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_q2d_land(:,:,date_i)',LONi,LATi)';
    data_IRBTvari_dc_land(:,:,date_i) = interp2(data_IRBT_lon,data_IRBT_lat,Var_Map_bySig_dc_land(:,:,date_i)',LONi,LATi)';
    
    data_ERA5i(:,:,date_i) = interp2(ERA5_data.lon,ERA5_data.lat,ERA5_CX_variable(:,:,date_i)',LONi,LATi)';
    
    if ( cloud_frac_switch == 1 )
        data_ISCCPi(:,:,date_i) = interp2(ISCCP_B_HGM_data.lon,ISCCP_B_HGM_data.lat,ISCCP_variable(:,:,date_i)',LONi,LATi)';
    end
    
    pb_1.print(date_i,length(date_dur));
    
end 

%% Averaging:

% data_IRBTvari_q2d = nanmean(data_IRBTvari_q2d,3);
% data_IRBTvari_dc = nanmean(data_IRBTvari_dc,3);
% data_SSTi = nanmean(data_SSTi,3);

%% Filtering with ISCCP cloud fraction:

if ( cloud_frac_switch == 1 )
    data_IRBTvari_q2d( data_ISCCPi < 40 ) = nan;
    data_IRBTvari_q2d_ocean( data_ISCCPi < 40 ) = nan;
    data_IRBTvari_q2d_land( data_ISCCPi < 40 ) = nan;
    data_IRBTvari_dc( data_ISCCPi < 40 ) = nan;
    data_IRBTvari_dc_ocean( data_ISCCPi < 40 ) = nan;
    data_IRBTvari_dc_land( data_ISCCPi < 40 ) = nan;
end

% ==============================================================================

%% Calculation

switch ERA5_CX_var_name
    case 'cape' 
        SFC_ticks = [0:200:3000];
        SFC_range = [-100:200:3100];
    case 'cin'
        SFC_ticks = [275:5:375]; 
        SFC_range = [272.5:5:377.5];
    case 'kx'
        SFC_ticks = [5:5:100]; 
        SFC_range = [2.5:5:102.5];
    case 'blh'
        SFC_ticks = [0:2:22];
        SFC_range = [-1:2:23];
end

for ssti = 1:numel(SFC_range)-1
    
    SFC_range_id = find( data_ERA5i>=SFC_range(ssti) & data_ERA5i<SFC_range(ssti+1) );
    
    IRBTvar_q2d_range_mean(ssti) = nanmean(data_IRBTvari_q2d(SFC_range_id));
    IRBTvar_q2d_range_mean_ocean(ssti) = nanmean(data_IRBTvari_q2d_ocean(SFC_range_id));
    IRBTvar_q2d_range_mean_land(ssti) = nanmean(data_IRBTvari_q2d_land(SFC_range_id));
    IRBTvar_q2d_range_std(ssti) = nanstd(data_IRBTvari_q2d(SFC_range_id));
    IRBTvar_q2d_range_num(ssti) = sum(~isnan(data_IRBTvari_q2d(SFC_range_id)));
    IRBTvar_q2d_range_num_ocean(ssti) = sum(~isnan(data_IRBTvari_q2d_ocean(SFC_range_id)));
    IRBTvar_q2d_range_num_land(ssti) = sum(~isnan(data_IRBTvari_q2d_land(SFC_range_id)));
    
    IRBTvar_dc_range_mean(ssti) = nanmean(data_IRBTvari_dc(SFC_range_id));
    IRBTvar_dc_range_mean_ocean(ssti) = nanmean(data_IRBTvari_dc_ocean(SFC_range_id));
    IRBTvar_dc_range_mean_land(ssti) = nanmean(data_IRBTvari_dc_land(SFC_range_id));
    IRBTvar_dc_range_std(ssti) = nanstd(data_IRBTvari_dc(SFC_range_id));
    IRBTvar_dc_range_num(ssti) = sum(~isnan(data_IRBTvari_dc(SFC_range_id)));
    IRBTvar_dc_range_num_ocean(ssti) = sum(~isnan(data_IRBTvari_dc_ocean(SFC_range_id)));
    IRBTvar_dc_range_num_land(ssti) = sum(~isnan(data_IRBTvari_dc_land(SFC_range_id)));

    SFC_range_num(ssti) = numel(SFC_range_id);

end

%% Criteria for data number:

data_num_cri = 500;

IRBTvar_q2d_range_mean(IRBTvar_q2d_range_num<data_num_cri) = NaN;
IRBTvar_q2d_range_mean_ocean(IRBTvar_q2d_range_num_ocean<data_num_cri) = NaN;
IRBTvar_q2d_range_mean_land(IRBTvar_q2d_range_num_land<data_num_cri) = NaN;
IRBTvar_q2d_range_std(IRBTvar_q2d_range_num<data_num_cri) = NaN;

IRBTvar_dc_range_mean(IRBTvar_dc_range_num<data_num_cri) = NaN;
IRBTvar_dc_range_mean_ocean(IRBTvar_dc_range_num_ocean<data_num_cri) = NaN;
IRBTvar_dc_range_mean_land(IRBTvar_dc_range_num_land<data_num_cri) = NaN;
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

xx = SFC_ticks(nanid);

f11_2 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f11_2, 'facecolor', q2d_color, 'edgecolor', 'none', 'FaceAlpha', 0.25);

hold on;

nanid = ~isnan(IRBTvar_dc_range_mean);

lo = IRBTvar_dc_range_mean(nanid) - IRBTvar_dc_range_std(nanid);
hi = IRBTvar_dc_range_mean(nanid) + IRBTvar_dc_range_std(nanid);

xx = SFC_ticks(nanid);

f12_2 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f12_2, 'facecolor', dc_color, 'edgecolor', 'none', 'FaceAlpha', 0.25);

hold on;

f11 = line(SFC_ticks,IRBTvar_q2d_range_mean);

f11.Color = [0.635,0.078,0.184];
f11.Marker = '.';
f11.MarkerSize = 16;
f11.LineWidth = 1.5;

hold on;

f12 = line(SFC_ticks,IRBTvar_dc_range_mean);

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
switch ERA5_CX_var_name
    case 'cape' 
        set(ax11,'Xlim',[0,3200])
        set(ax11,'XTick',[0:400:3200])
    case 'cin'
        set(ax11,'Xlim',[280,370])
        set(ax11,'XTick',[250:10:400])
    case 'kx'
        set(ax11,'Xlim',[0,100])
        set(ax11,'XTick',[0:10:100])
    case 'blh'
        set(ax11,'Xlim',[0,25])
        set(ax11,'XTick',[0:2:30])
end
% set(ax11,'XTickLabel',[])
set(ax11,'XMinorTick','off','XMinorGrid','off')
set(ax11,'Ylim',[-1,170])
set(ax11,'YTick',[0:20:500])
set(ax11,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','off');

%% 1. Labels:
switch ERA5_CX_var_name
    case 'cape' 
        xlabel('\bf{CAPE (J\cdotkg^{-1})}')
    case 'cin'
        xlabel('\bf{sfc. \theta_e (K)}')
    case 'kx'
        xlabel('\bf{sfc. RH (%)}')
    case 'blh'
        xlabel('\bf{sfc. Mixing Ratio (g/kg)}')
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
set(ax12,'Ylim',[1,1e7]);
% set(ax12,'YTick',[1,]);
set(ax12,'YMinorTick','off')
set(ax12,'YScale','log')
set(ax12,'YAxisLocation','right')

ylabel('\bf{Grid Number}')

%% 2. Plot numbers:

f21 = line(SFC_ticks,IRBTvar_q2d_range_num);

f21.Color = [0.635,0.078,0.184];
f21.LineStyle = '--'
f21.Marker = 'o';
f21.MarkerSize = 6;
f21.LineWidth = 0.5;

hold on;

f22 = line(SFC_ticks,IRBTvar_dc_range_num);

f22.Color = [0,0.4,1];
f22.LineStyle = '--'
f22.Marker = 'o';
f22.MarkerSize = 6;
f22.LineWidth = 0.5;

%% 3. Set axes: Axis 3:
ax13 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);

set(ax13,'PlotBoxAspectRatio',[1,1,1])
set(ax13,'TickDir','out')
set(ax13,'LineWidth',2)

%% 1. Legends:

leg1 = legend([f11,f12,f21,f22],{'Q2D var.','DC var.','Q2D num.','DC num.'});
% leg1 = columnlegend(2, {'dc','q2d','#(dc)','#(q2d)'});

% leg1.Position(1) = 0.60;
% leg1.Position(2) = 0.82;
set(leg1,'LineWidth',2)
set(leg1,'FontName','Helvetica','FontSize',16,'FontWeight','bold')
set(leg1,'Box','on')
set(leg1,'Color','none')
set(leg1,'Location','NorthWest')
switch ERA5_CX_var_name
    case 'cape'
        set(leg1,'Location','NorthEast')
end

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gf1,'Color',[1,1,1]);

figname = ['./',ERA5_CX_var_name,'_IRBTvar_Climatology_ocean'];

% print(gf1,'-dpng','-r300',figname);

export_fig([figname,'.png'],'-r300')
% export_fig([figname,'.png'],'-r300','-transparent')

