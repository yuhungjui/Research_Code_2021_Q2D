clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot IRBT variance of [ Q2D ] & [ DC ] over Indian Ocean 
% in different [ DMI ] conditions:
% 
% 1. DMI positive:  DMI >= 1x std.
% 2. DMI neutral:   DMI < 1x std. & DMI > -1x std.
% 3. DMI negative:  DMI < -1x std.
% 
% ==============================================================================

%% Set time frame:

date_dur = datetime(1998,1,1):calmonths(1):datetime(2019,12,1);

% ==============================================================================

%% Frequency types:

freq_type{1} = 'dc';
freq_type{2} = 'q2d';
freq_type{3} = 'total';

freq_id = 2

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

%% Determine which phase to plot: 

phase_type = 'DMI++'
% phase_type = 'DMI_N'
% phase_type = 'DMI--'
% phase_type = 'DMI+'
% phase_type = 'DMI-'

switch phase_type
    
    case 'DMI++'
        phase_id = find( DMI >= mean(DMI) + std(DMI) );
    
    case 'DMI_N'
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

%% Load variance significance:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2019_mnly.mat;

% ==============================================================================

%% Load variance:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

% ==============================================================================

%% Calculate the Variance according to its Significance:

eval([ 'Var_Map = GRIDSAT_IRBT_VAR.',freq_type{freq_id},';' ]);
eval([ 'VarSig_Map = GRIDSAT_IRBT_SIGNIFICANCE.',freq_type{freq_id},';' ]);

Var_Map_bySig = Var_Map.*VarSig_Map;

%% Get Var Maps:

% VarDiff_Map = Var_Map_bySig_q2d-Var_Map_bySig_dc;
% clear *_q2d *_dc

%% Get mean:

% Var_Map_mean = nanmean(Var_Map(:,:,phase_id),3);
Var_Map_mean = nanmean(Var_Map_bySig(:,:,phase_id),3);

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
        Var_Map_mean = [ Var_Map_mean(721:end-1,:,:); Var_Map_mean(1:720,:,:)];
        
end

% ==============================================================================

%% Make the plot.

close all;

gf1 = gcf;
% gf1.WindowState = 'maximized';

%% Plotting:

f11 = pcolor(IRBT_LON,IRBT_LAT,Var_Map_mean(:,:)');
set(f11,'LineStyle','none')
set(f11,'EdgeAlpha',0); % 'FaceAlpha',0.8

% caxis([0,165])
caxis([0,80])

if ( freq_id == 3 )
    caxis([-50,1050])
    % caxis([0,55])
end

cm = redblue(16);
switch freq_id
    case 1
        cm = cm(8:-1:1,:);
    case 2
        cm = cm(9:16,:);
    case 3
        load cm_IRBTfreq
        for ii = 1:3; cm2(:,ii) = interp1([1:14],cm(:,ii),linspace(1,14,11)); end
        % cm2 = [[1,1,1];cm2];
        cm = cm2;
        clear cm2
end

colormap(cm)
cb = colorbar;

% set(cb,'YTick',[0:30:210])
set(cb,'YTick',[0:20:100])

if ( freq_id == 3 )
    set(cb,'YTick',[0:200:1000])
    % set(cb,'YTick',[0:10:50])
end

% set(cb,'YTickLabel',{'0','5','10','15','20','25','30',''})
set(cb,'TickDirection','Out');
set(cb,'Location','EastOutside');

hold on;

%% Contours:

if ( freq_id == 2 )

    [f11_1, f11_1h] = contour(IRBT_LON,IRBT_LAT,Var_Map_mean(:,:)');
    
    set(f11_1h,'LineColor','k','LineStyle','-','LineWidth',0.8);
    set(f11_1h,'LevelList',[30]);
    
    % clabel(f11_1,f11_1h,'FontSize',8,'Color','k');
    
    hold on;
    
    % [f11_2, f11_2h] = contour(IRBT_LON,IRBT_LAT,VarDiff_Map_mean(:,:)');
    %
    % set(f11_2h,'LineColor',[0.3,0.3,0.3],'LineStyle','--','LineWidth',0.8);
    % set(f11_2h,'LevelList',[15]);
    %
    % % clabel(f112,f112h,'FontSize',8,'Color','k');
    %
    % hold on;

end

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

leg1_label = {['\bf{Q2D var.' newline '(DMI=',num2str(DMI_phase_mean,2),')}']}; %{['\bf{',freq_type{freq_id},', DMI=',num2str(DMI_phase_mean,2),'}']};

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
cbu = text(1.5,-0.15,'(K^2)');
set(cbu,'Parent',cbu_axis)
set(cbu,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gcf,'Color',[1,1,1]);

figname = ['./IRBT_Var_Map_',freq_type{freq_id},'_IO_(',phase_type,')'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

