clear; close; clc;
addpath(genpath('/Users/yuhungjui/Dropbox/Work/MATLAB_TOOLS/'));
tic;

% ==============================================================================
% 
% Plot IRBT variance difference map between [ Q2D ] & [ DC ] over Indian Ocean 
% in different [ DMI ] conditions:
% 
% 1. DMI positive:  DMI >= 1x std.
% 2. DMI neutral:   DMI < 1x std. & DMI > -1x std.
% 3. DMI negative:  DMI < -1x std.
% 
% ==============================================================================

%% Set time frame:

date_dur = datetime(1998,1,1):calmonths(1):datetime(2018,12,1);

% ==============================================================================

%% Load DMI monthly data (the 1st, 2nd sources):

% DMI_mnly_raw = importdata('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_OISST_v2/monthly_dmi/dmi.long.data.txt',' ',1);
% 
% DMI_mnly = DMI_mnly_raw.data(129:149,2:13)';
% DMI = DMI_mnly(:);
% DMI(DMI == -999) = NaN;

% DMI_mnly_raw = importdata('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_OISST_v2/monthly_dmi/SINTEX_DMI.csv');
% 
% DMI = DMI_mnly_raw.data(194:445,1);
% DMI(DMI == -999) = NaN;

%% Calculate monthly DMI from the 3rd sources (originally weekly):

DMI_data_info = ncinfo('/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc');
DMI_data = ncread('/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc','DMI');
DMI_data_days = ncread('/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc','WEDCEN2');
DMI_date = datetime(1900,1,1) + caldays(DMI_data_days);

for di = 1:numel(date_dur)
    
    date_id = find( DMI_date.Year == date_dur(di).Year & DMI_date.Month == date_dur(di).Month );
    
    DMI(di) = mean(DMI_data(date_id));
    
    clear date_id
    
end

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
Var_Map_bySig_dc = Var_Map_dc.*VarSig_Map_dc;

Var_Map_q2d = GRIDSAT_IRBT_VAR.q2d;
VarSig_Map_q2d = GRIDSAT_IRBT_SIGNIFICANCE.q2d;
Var_Map_bySig_q2d = Var_Map_q2d.*VarSig_Map_q2d;

%% Get Var Maps:

VarDiff_Map = Var_Map_bySig_q2d-Var_Map_bySig_dc;

clear *_q2d *_dc

%% Get mean:

VarDiff_Map_mean = nanmean(VarDiff_Map(:,:,:),3);

clear VarDiff_Map

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
        VarDiff_Map_mean = [ VarDiff_Map_mean(721:end-1,:,:); VarDiff_Map_mean(1:720,:,:)];
        
end

% ==============================================================================

%% Determine which phase to plot: 

phase_type = 'DMI_positive'
% phase_type = 'DMI_neutral'
% phase_type = 'DMI_negative'
% phase_type = 'DMI+'
% phase_type = 'DMI+'

switch phase_type
    
    case 'DMI_positive'
        phase_id = find( DMI >= mean(DMI) + std(DMI) );
    
    case 'DMI_neutral'
        phase_id = find( DMI < mean(DMI) + std(DMI) & DMI > mean(DMI) - std(DMI) );
    
    case 'DMI_negative'
        phase_id = find( DMI <= mean(DMI) - std(DMI) );
        
    case 'DMI+'
        phase_id = find( DMI > mean(DMI) );
    
    case 'DMI-'
        phase_id = find( DMI <= mean(DMI) );

end

% ==============================================================================

%% Make the plot.

close all;

gf1 = gcf;
gf1.WindowState = 'maximized';

%% Plotting:

f11 = pcolor(IRBT_LON,IRBT_LAT,VarDiff_Map_mean(:,:)');
set(f11,'LineStyle','none')
set(f11,'EdgeAlpha',0); % 'FaceAlpha',0.8

caxis([-160,160])

cm = redblue(16);

colormap(cm);
cb = colorbar;

% set(cb,'YTick',[0:20:200])

set(cb,'YTick',[-200:50:200])

% set(cb,'YTickLabel',{'0','5','10','15','20','25','30',''})
set(cb,'TickDirection','Out');
set(cb,'Location','EastOutside');

hold on;

%% Contours:

% [f11_1, f11_1h] = contour(IRBT_LON,IRBT_LAT,VarDiff_Map_mean(:,:)');
% 
% set(f11_1h,'LineColor','k','LineStyle','-','LineWidth',0.8);
% set(f11_1h,'LevelList',[30]);
% 
% % clabel(f112,f112h,'FontSize',8,'Color','k');
% 
% hold on;
% 
% [f11_2, f11_2h] = contour(IRBT_LON,IRBT_LAT,VarDiff_Map_mean(:,:)');
% 
% set(f11_2h,'LineColor',[0.3,0.3,0.3],'LineStyle','--','LineWidth',0.8);
% set(f11_2h,'LevelList',[15]);
% 
% % clabel(f112,f112h,'FontSize',8,'Color','k');
% 
% hold on;

% ==============================================================================

%% 1. Plot the World Map over Indian Ocean:

load coastlines.mat

f10_1 = plot(coastlon,coastlat);
set(f10_1,'Color','k','LineWidth',1.0);

hold on;

tmp_coastlon = coastlon + 360;
tmp_coastlat = coastlat;

f10_2 = plot(tmp_coastlon,tmp_coastlat);
set(f10_2,'Color','k','LineWidth',1.0);

hold on;

%% Plot the Equator:
fEQ = refline(0,0);
set(fEQ,'LineStyle','-.','LineWidth',1.0,'Color',[0.5,0.5,0.5]);

hold on;

% ==============================================================================

%% Plot the IOD boxes:

IODbox1_lon1 = 50;
IODbox1_lon2 = 70;
IODbox1_lat1 = -10;
IODbox1_lat2 = 10;
IOD_box1_lon = [IODbox1_lon1, IODbox1_lon2, IODbox1_lon2, IODbox1_lon1, IODbox1_lon1];
IOD_box1_lat = [IODbox1_lat1, IODbox1_lat1, IODbox1_lat2, IODbox1_lat2, IODbox1_lat1];
f51 = plot(IOD_box1_lon, IOD_box1_lat,'LineWidth',1.2,'Color','b','LineStyle','--');
hold on;

IODbox2_lon1 = 90;
IODbox2_lon2 = 110;
IODbox2_lat1 = -10;
IODbox2_lat2 = 0;
IOD_box2_lon = [IODbox2_lon1, IODbox2_lon2, IODbox2_lon2, IODbox2_lon1, IODbox2_lon1];
IOD_box2_lat = [IODbox2_lat1, IODbox2_lat1, IODbox2_lat2, IODbox2_lat2, IODbox2_lat1];
f52 = plot(IOD_box2_lon, IOD_box2_lat,'LineWidth',1.2,'Color','b','LineStyle','--');

%% Write the mean SST for each IOD box:

% t21 = text(IODbox1_lon1,IODbox1_lat2,{[num2str(IOD_box1),'^\circC']});
% set(t21,'Color','b','FontWeight','bold','FontSize',10,'VerticalAlignment','top');
% 
% t22 = text(IODbox2_lon1,IODbox2_lat2,{[num2str(IOD_box2),'^\circC']});
% set(t22,'Color','b','FontWeight','bold','FontSize',10,'VerticalAlignment','top');

% ==============================================================================

%% Set axes:

axfont = 24;

axis equal

ax1 = gca;
set(ax1,'Box','on');
set(ax1,'TickDir','out')
set(ax1,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax1,'LineWidth',1.5)
set(ax1,'Xlim',[45,135])
set(ax1,'XTick',[45:45:315])
set(ax1,'XGrid','on');
set(ax1,'XTickLabel',{'45^\circE','90^\circE','135^\circE','180^\circE','135^\circW','90^\circW','45^\circW',})
set(ax1,'XMinorTick','on','XMinorGrid','off')
set(ax1,'Ylim',[-20,20])
set(ax1,'YTick',[-20:20:20])
set(ax1,'YTickLabel',{'20^\circS','EQ','20^\circN'})
set(ax1,'YMinorTick','on','YMinorGrid','off')
set(ax1,'YGrid','on');

%% 1. Labels:
xlabel('\bf{Lon.}')
ylabel('\bf{Lat.}')

%% 1. Legends:

leg1_label = {['\bf{var(q2d)-var(dc), DMI=',num2str(mean(DMI(phase_id)),2),'}']};

leg1 = text(47,18,leg1_label);

set(leg1,'HorizontalAlignment','left')
set(leg1,'VerticalAlignment','top')
set(leg1,'FontName','Helvetica')
set(leg1,'FontSize',axfont)
set(leg1,'FontWeight','bold')
set(leg1,'BackgroundColor',[1,1,1,0.85])
set(leg1,'EdgeColor','k')
set(leg1,'LineWidth',1.5)

%% 1. Change the size(width) of colorbar.
axpos = get(ax1,'Position');
cpos = get(cb,'Position');
cpos(3) = 0.5*cpos(3);
cpos(4) = 0.75*cpos(4);
cpos(2) = 0.5-0.5.*cpos(4);
set(cb,'Position',cpos)
set(gca,'Position',axpos)

%% 1. Colorbar unit:
cbu_axis = axes('Position',[cb.Position(1),cb.Position(2),cb.Position(3),cb.Position(4)], ...
    'XLim',[0,1],'YLim',[0,1], ...
    'visible','off');
cbu = text(1.5,-0.15,'(K^2)');
set(cbu,'Parent',cbu_axis)
set(cbu,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gcf,'Color',[1,1,1]);

figname = ['./IRBT_VarDiffMap_IO_(',phase_type,')'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

