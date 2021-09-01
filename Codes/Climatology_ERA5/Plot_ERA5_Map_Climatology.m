clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot ERA5 maps over all time (1998–).
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2019,12,1)]';

% Get_Seasons_1998_2019;

seasonal_switch = 1;
% seasonal_range = [6,7,8];
seasonal_range = [12,1,2];
seasonal_id = find(ismember(date_dur.Month,seasonal_range)==1);

%% Basins domain limits:

basin_domain = [[50,100,-10,10]; ...    % IO
                [100,130,-10,10]; ...   % MC
                [130,180,-10,10]; ...   % WPAC
                [10,25,-8,8]; ...       % Congo
                [295,310,-35,-20]; ...  % South America
                [260,285,30,40]; ...    % CONUS
                [288,308,-10,5]; ...    % Amazon
                ];

% ==============================================================================

%% Set target time (month or season):

% target_month_id = 166; % 2011 Oct. %42:44; % 2001 Jun.-Aug. %36:38; % 2000 Dec.-2001 Feb.

% target_season_id =  55; % 2011 SON. %14; % 2001 JJA. %12; % 2000 DJF.

% ==============================================================================

%% Set the 4 seasons id:

% for mi = 1:4
%     
%     switch mi
%         case 1
%             target_month_id{mi} = find(ismember(date_dur.Month,[3,4,5]));
%             target_month_name{mi} = 'MAM';
%         case 2
%             target_month_id{mi} = find(ismember(date_dur.Month,[6,7,8]));
%             target_month_name{mi} = 'JJA';
%         case 3
%             target_month_id{mi} = find(ismember(date_dur.Month,[9,10,11]));
%             target_month_name{mi} = 'SON';
%         case 4
%             target_month_id{mi} = find(ismember(date_dur.Month,[12,1,2]));
%             target_month_name{mi} = 'DJF';
%     end
%     
% end
% 
% mon_i = 2;

% ==============================================================================

%% Load ERA5 data:

% load('/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_sfc_1998_2020/monthly_land_SFC_VARIABLES_1998_2020_interp025_40SN.mat');

% load /Users/yuhungjui/GoogleDrive_NTU/Data/DATA_ERA5/monthly_single_level_CLOUD_1998_2020/monthly_CLOUD_1998_2020_40SN.mat;
% ERA5_data.tcc = ERA5_data.tcc.*100;

load /Users/yuhungjui/Data/2021_Q2D/DATA_ERA5/monthly_Conv_Index_1998_2020_40SN.mat;

%% Set variable names:

ERA5_var_name = 'cape';

% ERA5_sfc_var_name = 'sfcT';
% ERA5_sfc_var_name = 'sfcTHETAE';
% ERA5_sfc_var_name = 'sfcRH';
% ERA5_sfc_var_name = 'sfcMR';

% ERA5_var_name = 'TotalCloudCover';

%% Set plotting variables:

eval([ 'ERA5_variable = ERA5_data.',ERA5_var_name,';' ]);

% ==============================================================================

%% Get mean:

switch seasonal_switch 
    case 0
        ERA5_variable = nanmean(ERA5_variable(:,:,1:numel(date_dur)),3);
    case 1
        ERA5_variable = nanmean(ERA5_variable(:,:,seasonal_id),3);
end

%% Get Lon/Lat:

ERA5_LON = ERA5_data.lon;
ERA5_LAT = ERA5_data.lat;

clear ERA5_data*

% ==============================================================================

%% SHIFT LONGITUDES:

% shift_longitude = 1
% 
% switch shift_longitude
%     case 1
%         
%         ERA5_LON = [ ERA5_LON(721:end-1), ERA5_LON(1:720) + 360 ];
%         Var_Map_mean = [ Var_Map_mean(721:end-1,:,:); Var_Map_mean(1:720,:,:)];
%         
% end

% ==============================================================================

%% Plotting figure.

close all;

gf1 = gcf;
gf1.WindowState = 'maximized';

% ==============================================================================

%% 1. 

f11 = pcolor(ERA5_LON,ERA5_LAT,ERA5_variable');
set(f11,'LineStyle','none')
set(f11,'EdgeAlpha',0); % 'FaceAlpha',0.8

switch ERA5_var_name
    case 'sfcMR'
        caxis([0,20])
        colormap(flipud(parula(10)));
        cb = colorbar;
        set(cb,'YTick',[0:4:20])
    case 'TotalCloudCover'
        caxis([0,100])
        colormap(cbrewer('seq','YlGnBu',10,'linear'));
        cb = colorbar;
        set(cb,'YTick',[0:20:100])
    case 'cape'
        caxis([0,2400])
        colormap(cbrewer('seq','YlOrBr',12));
        % colormap(haxby(12));
        cb = colorbar;
        set(cb,'YTick',[0:400:3200])
end

% set(cb,'YTickLabel',{'0','5','10','15','20','25','30',''})
set(cb,'TickDirection','Out');
set(cb,'Location','EastOutside');

hold on;

%% Contours:

% [f11_1, f11_1h] = contour(IRBT_LON,IRBT_LAT,Var_Map_mean');
% 
% set(f11_1h,'LineColor','b','LineStyle','--','LineWidth',1.0);
% % set(f11_1h,'LevelList',[25]);
% 
% clabel(f11_1,f11_1h,'FontSize',8,'Color','b');
% 
% hold on;

%     [f11_2, f11_2h] = contour(IRBT_LON,IRBT_LAT,Var_Map_mean(:,:,mi)');
%
%     set(f11_2h,'LineColor','k','LineStyle','--','LineWidth',0.8);
%     set(f11_2h,'LevelList',[20]);
%
%     % clabel(f112,f112h,'FontSize',8,'Color','k');
%
%     hold on;

% ==============================================================================

%% 1. Plot the World Map over Indian Ocean:

load coastlines.mat

f10_1 = plot(coastlon,coastlat);
set(f10_1,'Color','k','LineWidth',1.2);

hold on;

tmp_coastlon = coastlon + 360;
tmp_coastlat = coastlat;

f10_2 = plot(tmp_coastlon,tmp_coastlat);
set(f10_2,'Color','k','LineWidth',1.2);

hold on;

%% Plot the Equator:
fEQ = refline(0,0);
set(fEQ,'LineStyle','-.','LineWidth',1.2,'Color',[0.5,0.5,0.5]);

hold on;

% ==============================================================================

%% Plot the basin boxes:

for bi = [1,3:7] % IO, MC, WPAC

    box_lon = [basin_domain(bi,1), basin_domain(bi,2), basin_domain(bi,2), basin_domain(bi,1), basin_domain(bi,1)];
    box_lat = [basin_domain(bi,3), basin_domain(bi,3), basin_domain(bi,4), basin_domain(bi,4), basin_domain(bi,3)];

    f1box = plot(box_lon, box_lat,'LineWidth',2.5,'Color',[0.1,0.1,0.1],'LineStyle',':');

    hold on;

end

% ==============================================================================

%% 1. Set axes: Axis 1:

axfont = 24;

axis equal

ax1 = gca;
set(ax1,'Color','w'); % For NaN points color.
set(ax1,'Box','on');
set(ax1,'TickDir','out')
set(ax1,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax1,'LineWidth',1.5)
set(ax1,'Xlim',[-0.1,360.1])
set(ax1,'XTick',[0:30:360])
set(ax1,'XGrid','on');
set(ax1,'XTickLabel',{'0^\circ','30^\circE','60^\circE','90^\circE','120^\circE','150^\circE','180^\circ','150^\circW','120^\circW','90^\circW','60^\circW','30^\circW','0^\circ'});
set(ax1,'XMinorTick','on','XMinorGrid','off')
set(ax1,'Ylim',[-40,40])
set(ax1,'YTick',[-40:20:40])
set(ax1,'YTickLabel',{'40^\circS','20^\circS','EQ','20^\circN','40^\circN'})
set(ax1,'YMinorTick','on','YMinorGrid','off')
set(ax1,'YGrid','on');

%% 1. Labels:
xlabel('\bf{Lon.}')
ylabel('\bf{Lat.}')

%% 1. Legends:

if ( seasonal_switch == 1 )
    leg1_label = {['DJF']};
    
    leg1 = text(3,37,leg1_label);
    
    set(leg1,'HorizontalAlignment','left')
    set(leg1,'VerticalAlignment','top')
    set(leg1,'FontName','Helvetica')
    set(leg1,'FontSize',axfont)
    set(leg1,'FontWeight','bold')
    set(leg1,'BackgroundColor',[1,1,1,0.85])
    set(leg1,'EdgeColor','k')
    set(leg1,'LineWidth',1.5)
end

%% 1. Change the size(width) of colorbar.
axpos = get(ax1,'Position');
cpos = get(cb,'Position');
cpos(1) = 0.8;
cpos(3) = 0.25*cpos(3);
cpos(4) = 1*cpos(4);
% cpos(2) = 0.5-0.5.*cpos(4);
set(cb,'Position',cpos)
set(gca,'Position',axpos)

%% 1. Colorbar unit:
cbu_axis = axes('Position',[cb.Position(1),cb.Position(2),cb.Position(3),cb.Position(4)], ...
    'XLim',[0,1],'YLim',[0,1], ...
    'visible','off');

switch ERA5_var_name
    case 'sfcMR'
        cbu = text(1.5,-0.2,'(g/kg)');
    case 'TotalCloudCover'
        cbu = text(1.5,-0.2,'(%)');
    case 'cape'
        cbu = text(1.5,-0.2,'(J\cdotkg^{-1})');
end

% cbu = text(1.5,-0.2,'(K)');
set(cbu,'Parent',cbu_axis)
set(cbu,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')

% ==============================================================================
a
%% Save Figure:

set(gf1,'Color',[1,1,1]);

figname = ['./ERA5_Map_',ERA5_var_name,'_Climatology'];

export_fig([figname,'.png'],'-r300')

% ==============================================================================

disp([num2str(toc),' sec.'])

