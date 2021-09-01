clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot map of [ SST ] over Indian Ocean in different [ NINO ] conditions:
% 
% ==============================================================================

%% Set time frame:

date_dur = datetime(1998,1,1):calmonths(1):datetime(2019,12,1);

% ==============================================================================

%% Set region:

% % 45E–180E, 20S–20N:
% region_id_IRBT_lon = 901:1441;
% region_id_IRBT_lat = 81:241;
region_id_SST_lon = 1:1440; % 1:721; % 180:721;
region_id_SST_lat = 1:322; % 81:242;

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

% Nino34:
nino34_data_info = ncinfo('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_ELNINO/nino34.nc');
nino34_data = ncread('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_ELNINO/nino34.nc','NINO34');
nino34_data_days = ncread('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_ELNINO/nino34.nc','WEDCEN2');
nino34_date = datetime(1900,1,1) + caldays(nino34_data_days);

% Nino4:
nino4_data_info = ncinfo('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_ELNINO/nino4.nc');
nino4_data = ncread('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_ELNINO/nino4.nc','NINO4');
nino4_data_days = ncread('/Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_ELNINO/nino4.nc','WEDCEN2');
nino4_date = datetime(1900,1,1) + caldays(nino4_data_days);

for di = 1:numel(date_dur)
    
    date_id_nino34 = find( nino34_date.Year == date_dur(di).Year & nino34_date.Month == date_dur(di).Month );
    nino34(di) = mean(nino34_data(date_id_nino34));
    
    date_id_nino4 = find( nino4_date.Year == date_dur(di).Year & nino4_date.Month == date_dur(di).Month );
    nino4(di) = mean(nino4_data(date_id_nino4));
    
    clear date_id_*
    
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

%% Determine which index phase to plot: 

nino_type = 'Nino34'

switch nino_type
    case 'Nino34'
        nino_index = nino34;
    case 'Nino4'
        nino_index = nino4;
end

phase_type = 'NINO++'
% phase_type = 'NINO_N'
% phase_type = 'NINO--'
% phase_type = 'NINO+'
% phase_type = 'NINO-'

switch phase_type
    
    case 'NINO++'
        phase_id = find( nino_index >= mean(nino_index) + std(nino_index) );
    
    case 'NINO_N'
        phase_id = find( nino_index < mean(nino_index) + std(nino_index) & nino_index > mean(nino_index) - std(nino_index) );
    
    case 'NINO--'
        phase_id = find( nino_index <= mean(nino_index) - std(nino_index) );
        
    case 'NINO+'
        phase_id = find( nino_index > mean(nino_index) );
    
    case 'NINO-'
        phase_id = find( nino_index <= mean(nino_index) );

end

NINO_phase_mean = mean(nino_index(phase_id));
disp(NINO_phase_mean);

% phase_id = 1:252;
% SST_mean = mean(mean(data_SST(540:681,161:202,:))); % Northern branch, 135-170, 0-10
% SST_mean = nanmean(nanmean(data_SST(600:761,121:162,:))); % Southern branch, 150-190, -10-0

% ==============================================================================

%% Set plotting variables:

SST_mean = mean(data_SST(:,:,phase_id),3);

% ==============================================================================

%% Make the plot.

close all;

% gf1 = gcf;
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

%% Plot the Nino box:

switch nino_type
    
    case 'Nino34'
        
        NINObox1_lon1 = 190;
        NINObox1_lon2 = 240;
        NINObox1_lat1 = -5;
        NINObox1_lat2 = 5;
        
        NINO_box1_lon = [NINObox1_lon1, NINObox1_lon2, NINObox1_lon2, NINObox1_lon1, NINObox1_lon1];
        NINO_box1_lat = [NINObox1_lat1, NINObox1_lat1, NINObox1_lat2, NINObox1_lat2, NINObox1_lat1];
        
        f51 = plot(NINO_box1_lon, NINO_box1_lat,'LineWidth',1.2,'Color',[0.1,0.1,0.1],'LineStyle',':');
        
        hold on;

    case 'Nino4'
        
        NINObox1_lon1 = 160;
        NINObox1_lon2 = 210;
        NINObox1_lat1 = -5;
        NINObox1_lat2 = 5;
        
        NINO_box1_lon = [NINObox1_lon1, NINObox1_lon2, NINObox1_lon2, NINObox1_lon1, NINObox1_lon1];
        NINO_box1_lat = [NINObox1_lat1, NINObox1_lat1, NINObox1_lat2, NINObox1_lat2, NINObox1_lat1];
        
        f51 = plot(NINO_box1_lon, NINO_box1_lat,'LineWidth',1.2,'Color',[0.1,0.1,0.1],'LineStyle',':');
        
        hold on;
        
end

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
set(ax1,'Xlim',[90,270])
set(ax1,'XTick',[90:30:300])
set(ax1,'XGrid','off');
set(ax1,'XTickLabel',{'90^\circE','120^\circE','150^\circE','180^\circ','150^\circW','120^\circW','90^\circW',})
set(ax1,'XMinorTick','on','XMinorGrid','off')
set(ax1,'Ylim',[-22,22])
set(ax1,'YTick',[-20:5:20])
% set(ax1,'YTickLabel',{'20^\circS','EQ','20^\circN'})
set(ax1,'YMinorTick','off','YMinorGrid','off')
set(ax1,'YGrid','off');

%% 1. Labels:
xlabel('\bf{Lon.}')
ylabel('\bf{Lat.}')

%% 1. Legends:

leg1_label = {['\bf{SST mean' newline '(',nino_type,'=',num2str(NINO_phase_mean,2),')}']};

leg1 = text(267,-19,leg1_label);

set(leg1,'HorizontalAlignment','right')
set(leg1,'VerticalAlignment','bottom')
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

figname = ['./Mean_SST_Map_(',phase_type,')'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

