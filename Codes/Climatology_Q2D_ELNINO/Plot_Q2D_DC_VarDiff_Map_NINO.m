clear; close; clc;
addpath(genpath('/Users/yuhungjui/Dropbox/Work/MATLAB_TOOLS/'));
tic;

% ==============================================================================
% 
% Plot IRBT variance difference map between [ Q2D ] & [ DC ] over WPAC
% in different [ NINO ] conditions:
% 
% ==============================================================================

%% Set time frame:

date_dur = datetime(1998,1,1):calmonths(1):datetime(2018,12,1);

% ==============================================================================

%% Set region:

% % 45E–180E, 20S–20N:
% region_id_IRBT_lon = 901:1441;
% region_id_IRBT_lat = 81:241;
% region_id_SST_lon = 180:721;
% region_id_SST_lat = 81:242;

% ==============================================================================

%% Nino 3.4:

% load /Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_ELNINO/nino34_data_monthly_1948_2019.txt; % deg-C
% 
% nino34_1 = reshape(nino34_data_monthly_1948_2019(51:71,2:end)',[252,1]);

% nino34_mean = mean(nino34_data);
% nino34_std = std(nino34_data);

% %% Find H-ENSO, N-ENSO, L-ENSO:
% 
% % nino34_std_cri = 1;
% 
% nino34_id_H = find( nino34_data > nino34_mean + 1 );
% nino34_id_N = find( nino34_data <= nino34_mean + 1 & nino34_data > nino34_mean - 1  );
% nino34_id_L = find( nino34_data <= nino34_mean - 1 );

%% Calculate monthly Nino Index from the other source (originally weekly):

nino34_data_info = ncinfo('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_ELNINO/nino34.nc');
nino34_data = ncread('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_ELNINO/nino34.nc','NINO34');
nino34_data_days = ncread('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_ELNINO/nino34.nc','WEDCEN2');
nino34_date = datetime(1900,1,1) + caldays(nino34_data_days);

nino4_data_info = ncinfo('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_ELNINO/nino4.nc');
nino4_data = ncread('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_ELNINO/nino4.nc','NINO4');
nino4_data_days = ncread('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_ELNINO/nino4.nc','WEDCEN2');
nino4_date = datetime(1900,1,1) + caldays(nino4_data_days);

for di = 1:numel(date_dur)
    
    date_id_nino34 = find( nino34_date.Year == date_dur(di).Year & nino34_date.Month == date_dur(di).Month );
    nino34(di) = mean(nino34_data(date_id_nino34));
    
    date_id_nino4 = find( nino4_date.Year == date_dur(di).Year & nino4_date.Month == date_dur(di).Month );
    nino4(di) = mean(nino4_data(date_id_nino4));
    
    clear date_id_*
    
end

% ==============================================================================

%% Load variance:

pb_1 = CmdLineProgressBar('... Loading ... ');

di = 1;

for date_i = 1:length(date_dur)
    
    %% Load Variance Map Data:
    
    load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
    % load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_(pn15d)_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
    
    %% Get Q2D-DC variance difference data w/ QBO conditions:
    
    VarDiff_Map(:,:,di) = GRIDSAT_IRBT_VAR.q2d - GRIDSAT_IRBT_VAR.dc;

    di = di + 1;
    
    clear GRIDSAT_IRBT_VAR
    
    pb_1.print(date_i,length(date_dur));
    
end

%% Get Lon/Lat:

load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);

IRBT_LON = GRIDSAT_IRBT_VAR.lon;
IRBT_LAT = GRIDSAT_IRBT_VAR.lat;

clear GRIDSAT_IRBT_VAR

% ==============================================================================

%% SHIFT LONGITUDES:

shift_longitude = 1

switch shift_longitude
    case 1
        
        IRBT_LON = [ IRBT_LON(721:end-1), IRBT_LON(1:720) + 360 ];
        VarDiff_Map = [ VarDiff_Map(721:end-1,:,:); VarDiff_Map(1:720,:,:)];
        
end

% ==============================================================================

%% Determine which index phase to plot: 

nino_type = 'Nino34'

switch nino_type
    case 'Nino34'
        nino_index = nino34;
    case 'Nino4'
        nino_index = nino4;
end

% phase_type = 'NINO_positive'
% phase_type = 'NINO_neutral'
% phase_type = 'NINO_negative'
phase_type = 'NINO+'
% phase_type = 'NINO-'

switch phase_type
    
    case 'NINO_positive'
        phase_id = find( nino_index >= mean(nino_index) + std(nino_index) );
    
    case 'NINO_neutral'
        phase_id = find( nino_index < mean(nino_index) + std(nino_index) & nino_index > mean(nino_index) - std(nino_index) );
    
    case 'NINO_negative'
        phase_id = find( nino_index <= mean(nino_index) - std(nino_index) );
        
    case 'NINO+'
        phase_id = find( nino_index > mean(nino_index) );
    
    case 'NINO-'
        phase_id = find( nino_index <= mean(nino_index) );

end

% ==============================================================================

%% Set plotting variables:

VarDiff_Map_mean = nanmean(VarDiff_Map(:,:,phase_id),3);

% clear VarDiff_Map

% ==============================================================================

%% Make the plot.

close all;

% gf1 = gcf;
% gf1.WindowState = 'maximized';

%% Plotting:

f11 = pcolor(IRBT_LON,IRBT_LAT,VarDiff_Map_mean(:,:)');
set(f11,'LineStyle','none')
set(f11,'EdgeAlpha',0); % 'FaceAlpha',0.8

caxis([-110,110])

cm = redblue(22);

colormap(cm);
cb = colorbar;

% set(cb,'YTick',[0:20:200])

set(cb,'YTick',[-200:50:200])

% set(cb,'YTickLabel',{'0','5','10','15','20','25','30',''})
set(cb,'TickDirection','Out');
set(cb,'Location','EastOutside');

hold on;

%% Contours:

[f11_1, f11_1h] = contour(IRBT_LON,IRBT_LAT,VarDiff_Map_mean(:,:)');

set(f11_1h,'LineColor','k','LineStyle','-','LineWidth',0.8);
set(f11_1h,'LevelList',[30]);

% clabel(f112,f112h,'FontSize',8,'Color','k');

hold on;

[f11_2, f11_2h] = contour(IRBT_LON,IRBT_LAT,VarDiff_Map_mean(:,:)');

set(f11_2h,'LineColor',[0.3,0.3,0.3],'LineStyle','--','LineWidth',0.8);
set(f11_2h,'LevelList',[15]);

% clabel(f112,f112h,'FontSize',8,'Color','k');

hold on;

% ==============================================================================

%% 1. Plot the World Map over WPAC:

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

%% Plot the basin boxes:

% Basins domain limits:

basin_domain = [[130,150,-10,10]; ...   % WPAC
                [150,180,-10,10]];      % CPAC

for bi = 1:2
    
    box_lon = [basin_domain(bi,1), basin_domain(bi,2), basin_domain(bi,2), basin_domain(bi,1), basin_domain(bi,1)];
    box_lat = [basin_domain(bi,3), basin_domain(bi,3), basin_domain(bi,4), basin_domain(bi,4), basin_domain(bi,3)];
    
    f1box = plot(box_lon, box_lat,'LineWidth',1.5,'Color',[1,0.0,0.2],'LineStyle','--');
    
    hold on;

end

% ==============================================================================

%% Plot the Nino box:

% switch nino_type
%     
%     case 'Nino34'
%         
%         NINObox1_lon1 = 190;
%         NINObox1_lon2 = 240;
%         NINObox1_lat1 = -5;
%         NINObox1_lat2 = 5;
%         
%         NINO_box1_lon = [NINObox1_lon1, NINObox1_lon2, NINObox1_lon2, NINObox1_lon1, NINObox1_lon1];
%         NINO_box1_lat = [NINObox1_lat1, NINObox1_lat1, NINObox1_lat2, NINObox1_lat2, NINObox1_lat1];
%         
%         f51 = plot(NINO_box1_lon, NINO_box1_lat,'LineWidth',1.2,'Color','b','LineStyle','--');
%         
%         hold on;
% 
%     case 'Nino4'
%         
%         NINObox1_lon1 = 160;
%         NINObox1_lon2 = 210;
%         NINObox1_lat1 = -5;
%         NINObox1_lat2 = 5;
%         
%         NINO_box1_lon = [NINObox1_lon1, NINObox1_lon2, NINObox1_lon2, NINObox1_lon1, NINObox1_lon1];
%         NINO_box1_lat = [NINObox1_lat1, NINObox1_lat1, NINObox1_lat2, NINObox1_lat2, NINObox1_lat1];
%         
%         f51 = plot(NINO_box1_lon, NINO_box1_lat,'LineWidth',1.2,'Color','b','LineStyle','--');
%         
%         hold on;
%         
% end


%% Write the mean SST for each IOD box:

% t21 = text(IODbox1_lon1,IODbox1_lat2,{[num2str(IOD_box1),'^\circC']});
% set(t21,'Color','b','FontWeight','bold','FontSize',10,'VerticalAlignment','top');
% 
% t22 = text(IODbox2_lon1,IODbox2_lat2,{[num2str(IOD_box2),'^\circC']});
% set(t22,'Color','b','FontWeight','bold','FontSize',10,'VerticalAlignment','top');

% ==============================================================================

%% Set axes:

axfont = 14;

axis equal

ax1 = gca;
set(ax1,'Box','on');
set(ax1,'TickDir','out')
set(ax1,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax1,'LineWidth',1.5)
set(ax1,'Xlim',[90,270])
set(ax1,'XTick',[45:45:315])
set(ax1,'XGrid','on');
set(ax1,'XTickLabel',{'45^\circE','90^\circE','135^\circE','180^\circE','135^\circW','90^\circW','45^\circW',})
set(ax1,'XMinorTick','on','XMinorGrid','off')
set(ax1,'Ylim',[-25,35])
set(ax1,'YTick',[-20:20:20])
set(ax1,'YTickLabel',{'20^\circS','EQ','20^\circN'})
set(ax1,'YMinorTick','on','YMinorGrid','off')
set(ax1,'YGrid','on');

%% 1. Labels:
xlabel('\bf{Lon.}')
ylabel('\bf{Lat.}')

%% 1. Legends:

leg1_label = {['\bf{var(q2d)-var(dc), Nino=',num2str(mean(nino_index(phase_id)),2),'}']};

leg1 = text(92,33,leg1_label);

set(leg1,'HorizontalAlignment','left')
set(leg1,'VerticalAlignment','top')
set(leg1,'FontName','Helvetica')
set(leg1,'FontSize',12)
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

figname = ['./IRBT_VarDiffMap_WPAC_(',nino_type,'_',phase_type,')'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

