clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot SST vs. IRBT var. over torpical oceans from 1998–2018.
% 
% Domain: IO, WPAC, etc.
% 
% Input:
%       SST:  monthly mean, 0.25-deg resolution.
%       IRBT: monthly mean, 0.25-deg resolution.
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2019,12,1)]';

% ==============================================================================

%% Set region:

region_id_IRBT_lon = 1:1441; % 901:1441;
region_id_IRBT_lat = 1:321; % 81:241;
region_id_SST_lon = 1:1440; % 1:721; % 180:721;
region_id_SST_lat = 1:322; % 81:242;

% ==============================================================================

%% Frequency types:

freq_type{1} = 'Diurnal';
freq_type{2} = 'Quasi-2-Day';
freq_type{3} = 'Total';

% ==============================================================================

%% Load variance significance:

load /Users/yuhungjui/Data/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2019_mnly.mat;

% ==============================================================================

%% Load variance:

load /Users/yuhungjui/Data/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

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

%% Load SST:

pb_2 = CmdLineProgressBar('... Loading ... ');

di = 1;

for yr_i = 1998:2019
    
    %% Load SST Map Data:
    
    load(['/Volumes/Seaweed_10T/Data/DATA_NOAA_OISST_v2/monthly_hires_mat/NOAA_OISST_TROPICS_',num2str(yr_i),'_mnly.mat']);
    
    %% Get SST over targeted area:
    
    if ( yr_i == 1998 )
    
        data_SST = NOAA_OISST_TROPICS_mnly.sst_mnly(region_id_SST_lon,region_id_SST_lat,:); % cover specified domain
    
    else
        
        tmp_data_SST = NOAA_OISST_TROPICS_mnly.sst_mnly(region_id_SST_lon,region_id_SST_lat,:); % cover specified domain
        data_SST = cat(3,data_SST,tmp_data_SST);

    end
    
    if ( yr_i == 2019 )
        
        data_SST_lon = NOAA_OISST_TROPICS_mnly.lon(region_id_SST_lon); % cover specified domain
        data_SST_lat = NOAA_OISST_TROPICS_mnly.lat(region_id_SST_lat); % cover specified domain
        
    end
    
    di = di + 1;
    
    clear NOAA_*
    
    pb_2.print(yr_i,2019);
    
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

%% Interpolation:

% Interpolate the map data of IRBT and SST to the given resolution.

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

    data_SSTi(:,:,date_i) = interp2(data_SST_lon,data_SST_lat,data_SST(:,:,date_i)',LONi,LATi)';
    
    pb_1.print(date_i,length(date_dur));
    
end 

%% Averaging:

% data_IRBTvari_q2d = nanmean(data_IRBTvari_q2d,3);
% data_IRBTvari_dc = nanmean(data_IRBTvari_dc,3);
% data_SSTi = nanmean(data_SSTi,3);

% ==============================================================================

%% Calculation

SST_ticks = [20:0.5:33]; % [20:0.2:32]; [20:0.25:32];
SST_range = [19.75:0.5:33.25]; % [19.9:0.2:32.1]; [19.875:0.25:32.125];

data_LONi = repmat(LONi',[1,1,252]);
data_LATi = repmat(LATi',[1,1,252]);

% Basins domain limits:

basin_domain = [[50,100,-10,10]; ...    % IO
                [100,130,-10,10]; ...   % MC
                [130,180,-10,10]; ...   % WPAC
                [10,25,-8,8]; ...       % Congo
                [295,310,-35,-20]; ...  % South America
                [260,285,30,40]; ...    % CONUS
                [288,308,-10,5]; ...    % Amazon
                ];

for basini = 1:3 % IO, MC, WPAC
                
    basin_id = find( data_LONi >= basin_domain(basini,1) & data_LONi <= basin_domain(basini,2) ...
                   & data_LATi >= basin_domain(basini,3) & data_LATi <= basin_domain(basini,4));
    
    data_SSTi_basin = data_SSTi(basin_id);
    data_IRBTvari_q2d_basin = data_IRBTvari_q2d(basin_id);
    data_IRBTvari_dc_basin = data_IRBTvari_dc(basin_id);
    
    for ssti = 1:numel(SST_range)-1
        
        SST_range_id = find( data_SSTi_basin>=SST_range(ssti) & data_SSTi_basin<SST_range(ssti+1) );
        
        IRBTvar_q2d_range_mean(ssti,basini) = nanmean(data_IRBTvari_q2d_basin(SST_range_id));
        IRBTvar_q2d_range_std(ssti,basini) = nanstd(data_IRBTvari_q2d_basin(SST_range_id));
        IRBTvar_q2d_range_num(ssti,basini) = sum(~isnan(data_IRBTvari_q2d(SST_range_id)));
        
        IRBTvar_dc_range_mean(ssti,basini) = nanmean(data_IRBTvari_dc_basin(SST_range_id));
        IRBTvar_dc_range_std(ssti,basini) = nanstd(data_IRBTvari_dc_basin(SST_range_id));
        IRBTvar_dc_range_num(ssti,basini) = sum(~isnan(data_IRBTvari_dc(SST_range_id)));
        
        IRBTvar_range_num(ssti,basini) = numel(SST_range_id);
        
    end

end

%% Criteria for data number:

data_num_cri = 500;

IRBTvar_q2d_range_mean(IRBTvar_range_num<data_num_cri) = NaN;
IRBTvar_q2d_range_std(IRBTvar_range_num<data_num_cri) = NaN;

IRBTvar_dc_range_mean(IRBTvar_range_num<data_num_cri) = NaN;
IRBTvar_dc_range_std(IRBTvar_range_num<data_num_cri) = NaN;

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

for fi = [1,3] % specified domain

    f11{fi} = line(SST_ticks,IRBTvar_q2d_range_mean(:,fi));
    
    f11{fi}.Color = q2d_color;
    f11{fi}.Marker = '.';
    f11{fi}.MarkerSize = 16;
    f11{fi}.LineWidth = 1.5;

    hold on
    
end

f11{1}.LineStyle = '-';
f11{2}.LineStyle = ':';
f11{3}.LineStyle = '--';

for fi = [1,3] % specified domain

    f21{fi} = line(SST_ticks,IRBTvar_dc_range_mean(:,fi));
    
    f21{fi}.Color = dc_color;
    f21{fi}.Marker = '.';
    f21{fi}.MarkerSize = 16;
    f21{fi}.LineWidth = 1.5;

    hold on
    
end

f21{1}.LineStyle = '-';
% f21{2}.LineStyle = ':';
f21{3}.LineStyle = '--';


%% 1. Set axes: Axis 1:

ax11 = gca;

set(ax11,'Box','off','Color','none');
set(ax11,'PlotBoxAspectRatio',[1,1,1])
set(ax11,'Position',[0.125,0.125,0.75,0.75])
set(ax11,'TickDir','out')
set(ax11,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax11,'LineWidth',2)
set(ax11,'Xlim',[20,32])
set(ax11,'XTick',[20:1:32])
set(ax11,'XTickLabel',[])
set(ax11,'XMinorTick','off','XMinorGrid','off')
set(ax11,'Ylim',[-1,170])
set(ax11,'YTick',[0:20:500])
set(ax11,'YMinorTick','on','YMinorGrid','off')
set(ax11,'YAxisLocation','right')
% set(ax1,'YGrid','off');

%% 1. Labels:
% xlabel('\bf{SST (^\circC)}')
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

%% 1. Legends:

% % leg1 = legend([f11{1},f11{2},f11{3},f21{1},f21{2},f21{3}], ...
% %               {'q2d (IO)','q2d (MC)','q2d (WPAC)','dc (IO)','dc (MC)','dc (WPAC)'} ...
% %               );
% leg1 = legend([f11{1},f11{3},f21{1},f21{3}], ...
%               {'q2d(IO)','q2d(WPAC)','dc(IO)','dc(WPAC)'} ...
%               );
% 
% % leg1.Position(1) = 0.60;
% % leg1.Position(2) = 0.82;
% set(leg1,'LineWidth',2)
% set(leg1,'FontName','Helvetica','FontSize',16,'FontWeight','bold')
% set(leg1,'Box','on')
% set(leg1,'Color','none')
% set(leg1,'Location','SouthWest')

% ==============================================================================

disp([num2str(toc),' sec.'])
a
% ==============================================================================

%% Save Figure:
set(gf1,'Color',[1,1,1]);

figname = ['./SST_IRBTvar_Climatology_Basins'];

% print(gf1,'-dpng','-r300',figname);

% export_fig([figname,'.png'],'-r300')
export_fig([figname,'.png'],'-r300','-transparent')

