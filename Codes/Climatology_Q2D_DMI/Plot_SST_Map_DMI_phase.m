clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot map of [ SST ] over Indian Ocean in different [ DMI ] conditions:
% 
% 1. DMI positive:  DMI >= 1x std.
% 2. DMI neutral:   DMI < 1x std. & DMI > -1x std.
% 3. DMI negative:  DMI < -1x std.
% 
% ==============================================================================

%% Set time frame:

date_dur = datetime(1998,1,1):calmonths(1):datetime(2019,12,1);

% ==============================================================================

%% Set region:

% 45E–180E, 20S–20N:
% region_id_IRBT_lon = 901:1441;
% region_id_IRBT_lat = 81:241;
region_id_SST_lon = 1:1440; % 1:721; % 180:721;
region_id_SST_lat = 1:322; % 81:242;

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

DMI_data_info = ncinfo('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc');
DMI_data = ncread('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc','DMI');
DMI_data_days = ncread('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc','WEDCEN2');
DMI_date = datetime(1900,1,1) + caldays(DMI_data_days);

for di = 1:numel(date_dur)
    
    date_id = find( DMI_date.Year == date_dur(di).Year & DMI_date.Month == date_dur(di).Month );
    
    DMI(di) = mean(DMI_data(date_id));
    
    clear date_id
    
end

% ==============================================================================

%% Load SST:

pb_2 = CmdLineProgressBar('... Loading ... ');

di = 1;

for yr_i = 1998:2019
    
    %% Load SST Map Data:
    
    load(['/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_OISST_v2/monthly_hires_mat/NOAA_OISST_TROPICS_',num2str(yr_i),'_mnly.mat']);
    
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

%% Determine which phase to plot: 

% phase_type = 'DMI++'
% phase_type = 'DMI_n'
phase_type = 'DMI--'
% phase_type = 'DMI+'
% phase_type = 'DMI-'

switch phase_type
    
    case 'DMI++'
        phase_id = find( DMI >= mean(DMI) + std(DMI) );
    
    case 'DMI_n'
        phase_id = find( DMI < mean(DMI) + std(DMI) & DMI > mean(DMI) - std(DMI) );
    
    case 'DMI--'
        phase_id = find( DMI <= mean(DMI) - std(DMI) );
        
    case 'DMI+'
        phase_id = find( DMI > mean(DMI) );
    
    case 'DMI-'
        phase_id = find( DMI <= mean(DMI) );

end

DMI_phase_mean = mean(DMI(phase_id));
disp(DMI_phase_mean);

% ==============================================================================

%% Set plotting variables:

SST_mean = mean(data_SST(:,:,phase_id),3);

% ==============================================================================

%% Make the plot.

close all;

gf1 = gcf;
% gf1.WindowState = 'maximized';

%% Plotting SST field:

% f1 = contourf(LON,LAT,SST_mean',14,'LineColor','none');
f1 = pcolor(data_SST_lon,data_SST_lat,SST_mean');
set(f1,'EdgeColor','none')

caxis([23,31])

%% Set colorbar:

colormap_SST;
colormap(colormap_SST_48)
cb = colorbar;
set(cb,'YTick',[23:1:31])
set(cb,'TickDirection','Out');

hold on;

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
f51 = plot(IOD_box1_lon, IOD_box1_lat,'LineWidth',1.5,'Color',[0.1,0.1,0.1],'LineStyle',':');
hold on;

IODbox2_lon1 = 90;
IODbox2_lon2 = 110;
IODbox2_lat1 = -10;
IODbox2_lat2 = 0;
IOD_box2_lon = [IODbox2_lon1, IODbox2_lon2, IODbox2_lon2, IODbox2_lon1, IODbox2_lon1];
IOD_box2_lat = [IODbox2_lat1, IODbox2_lat1, IODbox2_lat2, IODbox2_lat2, IODbox2_lat1];
f52 = plot(IOD_box2_lon, IOD_box2_lat,'LineWidth',1.5,'Color',[0.1,0.1,0.1],'LineStyle',':');

%% Write the mean SST for each IOD box:

% t21 = text(IODbox1_lon1,IODbox1_lat2,{[num2str(IOD_box1),'^\circC']});
% set(t21,'Color','b','FontWeight','bold','FontSize',10,'VerticalAlignment','top');
% 
% t22 = text(IODbox2_lon1,IODbox2_lat2,{[num2str(IOD_box2),'^\circC']});
% set(t22,'Color','b','FontWeight','bold','FontSize',10,'VerticalAlignment','top');

% ==============================================================================

%% Set axes:

axfont = 12;

axis equal

ax1 = gca;
set(ax1,'Box','on');
set(ax1,'TickDir','out')
set(ax1,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax1,'LineWidth',1.5)
set(ax1,'Xlim',[25,125])
set(ax1,'XTick',[0:30:360])
set(ax1,'XGrid','off');
% set(ax1,'XTickLabel',{'45^\circE','90^\circE','135^\circE','180^\circE','135^\circW','90^\circW','45^\circW',})
set(ax1,'XMinorTick','on','XMinorGrid','off')
set(ax1,'Ylim',[-18,18])
set(ax1,'YTick',[-20:5:20])
% set(ax1,'YTickLabel',{'20^\circS','EQ','20^\circN'})
set(ax1,'YMinorTick','off','YMinorGrid','off')
set(ax1,'YGrid','off');

%% 1. Labels:
xlabel('\bf{Lon.(^\circE)}')
ylabel('\bf{Lat.}')

%% 1. Legends:

leg1_label = {['\bf{SST mean' newline '(DMI=',num2str(DMI_phase_mean,2),')}']};

leg1 = text(27,16,leg1_label);

set(leg1,'HorizontalAlignment','left')
set(leg1,'VerticalAlignment','top')
set(leg1,'FontName','Helvetica')
set(leg1,'FontSize',axfont)
set(leg1,'FontWeight','bold')
set(leg1,'BackgroundColor',[1,1,1,0.85])
set(leg1,'EdgeColor','k')
set(leg1,'LineWidth',1.0)

%% 1. Change the size(width) of colorbar.
axpos = get(ax1,'Position');
cpos = get(cb,'Position');
cpos(3) = 0.5*cpos(3);
cpos(4) = 0.8*cpos(4);
cpos(2) = 0.5-0.5.*cpos(4);
set(cb,'Position',cpos)
set(gca,'Position',axpos)

%% 1. Colorbar unit:
cbu_axis = axes('Position',[cb.Position(1),cb.Position(2),cb.Position(3),cb.Position(4)], ...
    'XLim',[0,1],'YLim',[0,1], ...
    'visible','off');
cbu = text(1.5,-0.15,'(^\circC)');
set(cbu,'Parent',cbu_axis)
set(cbu,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gcf,'Color',[1,1,1]);

figname = ['./Mean_SST_Map_IO_(',phase_type,')'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

