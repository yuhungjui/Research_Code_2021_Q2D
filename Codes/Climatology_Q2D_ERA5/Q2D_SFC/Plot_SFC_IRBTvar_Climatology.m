clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot ERA5 sfc. condition vs. IRBT over land from 1998–2018.
% 
% Input:
%       SFC:  monthly mean, 0.25-deg resolution.
%       IRBT: monthly mean, 0.25-deg resolution.
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

%% Load IRBT variance:

% pb_1 = CmdLineProgressBar('... Loading ... ');
% 
% for date_i = 1:length(date_dur)
%     
%     %% Load Variance Map Data:
%     
%     load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
%     % load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_(pn15d)_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
%     
%     %% Get Q2D, DC variance:
%     
%     data_IRBTvar_q2d(:,:,date_i) = GRIDSAT_IRBT_VAR.q2d(region_id_IRBT_lon,region_id_IRBT_lat);
%     data_IRBTvar_dc(:,:,date_i) = GRIDSAT_IRBT_VAR.dc(region_id_IRBT_lon,region_id_IRBT_lat);
% 
%     if ( date_i==numel(date_dur) )
%         
%         data_IRBTvar_lon = GRIDSAT_IRBT_VAR.lon(region_id_IRBT_lon);
%         data_IRBTvar_lat = GRIDSAT_IRBT_VAR.lat(region_id_IRBT_lat);
%         
%     end
%     
%     clear GRIDSAT_IRBT_VAR
%     
%     pb_1.print(date_i,length(date_dur));
%     
% end
           
% ==============================================================================

%% Load ERA5 Data:

% load('/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_sfc_1998_2020/monthly_land_ptu2m_1998_2020_interp025_40SN.mat');
% 
% pb_1 = CmdLineProgressBar('... Loading ... ');
% for ii = 1:1441
%     for jj = 1:321
%         for kk = 1:274
%             ERA5_datai_RH(ii,jj,kk) = convert_humidity_TTd_RHI_yhj(ERA5_datai.t2m(ii,jj,kk),ERA5_datai.d2m(ii,jj,kk));
%             ERA5_datai_THETAE(ii,jj,kk) = equivalent_potential_temp_Bolton(ERA5_datai.sfcP(ii,jj,kk)./100,ERA5_datai.t2m(ii,jj,kk),ERA5_datai_RH(ii,jj,kk));
%         end
%     end
%     pb_1.print(ii,1441);
% end

load('/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_sfc_1998_2020/monthly_land_SFC_VARIABLES_1998_2020_interp025_40SN.mat');

% ERA5_datai_MR = convert_humidity(ERA5_datai.sfcP,ERA5_datai.t2m,ERA5_datai.d2m,'dew point','mixing ratio').*1e3;

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
        Var_Map_bySig_dc = [ Var_Map_bySig_dc(721:end-1,:,:); Var_Map_bySig_dc(1:720,:,:)];
        Var_Map_bySig_q2d = [ Var_Map_bySig_q2d(721:end-1,:,:); Var_Map_bySig_q2d(1:720,:,:)];
        Var_Map_dc = [ Var_Map_dc(721:end-1,:,:); Var_Map_dc(1:720,:,:)];
        Var_Map_q2d = [ Var_Map_q2d(721:end-1,:,:); Var_Map_q2d(1:720,:,:)];
        
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

    data_ERA5i(:,:,date_i) = interp2(ERA5_datai.lon,ERA5_datai.lat,ERA5_sfc_variable(:,:,date_i)',LONi,LATi)';
    
    pb_1.print(date_i,length(date_dur));
    
end 

%% Averaging:

% data_IRBTvari_q2d = nanmean(data_IRBTvari_q2d,3);
% data_IRBTvari_dc = nanmean(data_IRBTvari_dc,3);
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

for ssti = 1:numel(SFC_range)-1
    
    SFC_range_id = find( data_ERA5i>=SFC_range(ssti) & data_ERA5i<SFC_range(ssti+1) );
    
    IRBTvar_q2d_range_mean(ssti) = nanmean(data_IRBTvari_q2d(SFC_range_id));
    IRBTvar_q2d_range_std(ssti) = nanstd(data_IRBTvari_q2d(SFC_range_id));
    IRBTvar_q2d_range_num(ssti) = sum(~isnan(data_IRBTvari_q2d(SFC_range_id)));
    
    IRBTvar_dc_range_mean(ssti) = nanmean(data_IRBTvari_dc(SFC_range_id));
    IRBTvar_dc_range_std(ssti) = nanstd(data_IRBTvari_dc(SFC_range_id));
    IRBTvar_dc_range_num(ssti) = sum(~isnan(data_IRBTvari_dc(SFC_range_id)));

    SFC_range_num(ssti) = numel(SFC_range_id);

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
set(ax11,'Ylim',[-1,170])
set(ax11,'YTick',[0:20:500])
set(ax11,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','off');

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

figname = ['./',ERA5_sfc_var_name,'_IRBTvar_Climatology'];

% print(gf1,'-dpng','-r300',figname);

export_fig([figname,'.png'],'-r300')
% export_fig([figname,'.png'],'-r300','-transparent')

