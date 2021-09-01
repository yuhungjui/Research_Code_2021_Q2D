clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot the IRBT spectrum for specified area and period.
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2019,12,1)]';

% date_dur = [datetime(2007,1,1):calmonths(1):datetime(2007,12,31)]'; % Yuan & Houze 2010 (2007)
% date_dur = [datetime(2007,1,1):calmonths(1):datetime(2007,2,28),datetime(2007,12,1):calmonths(1):datetime(2007,12,31)]'; % Yuan & Houze 2010 (DJF)
% date_dur = [datetime(2007,6,1):calmonths(1):datetime(2007,8,31)]'; % Yuan & Houze 2010 (JJA)

%% Specify domain:

basin_domain = [[50,100,-10,10]; ...            % IO
                [100,130,-10,10]; ...           % MC
                [130,180,-10,10]; ...           % WPAC
                [10,25,-8,8]; ...               % Congo
                [295,310,-35,-20]; ...          % South America
                [260,285,30,40]; ...            % CONUS
                [288,308,-10,5]; ...            % Amazon
                [97,150,5,35]; ...              % TEA
                [119.5,122.5,21.5,25.5]; ...    % Taiwan
                [240,280,-30,-5]; ...           % southeastern Pacific
                [340,360,-30,-5]; ...           % southeastern Atlantic
                ];

            
% target_domian = [0,360,-40,40]; 
target_domian = basin_domain(11,:);

% ==============================================================================

%% Set the 4 seasons id:

for mi = 1:4
    
    switch mi
        case 1
            target_month_id{mi} = find(ismember(date_dur.Month,[3,4,5]));
            target_month_name{mi} = 'MAM';
        case 2
            target_month_id{mi} = find(ismember(date_dur.Month,[6,7,8]));
            target_month_name{mi} = 'JJA';
        case 3
            target_month_id{mi} = find(ismember(date_dur.Month,[9,10,11]));
            target_month_name{mi} = 'SON';
        case 4
            target_month_id{mi} = find(ismember(date_dur.Month,[12,1,2]));
            target_month_name{mi} = 'DJF';
    end
    
end

mon_id = 0;

% ==============================================================================

%% Load Ocean Area:

load /Users/yuhungjui/Data/2021_Q2D/DATA_NOAA_OISST_v2/Ocean_Area.mat;

%% Categorize Ocean & Land:

oceanid = Ocean_Area.Ocean_ID;
oceanid(oceanid==0) = nan;
landid = Ocean_Area.Ocean_ID;
landid(landid==1) = nan;
landid(landid==0) = 1;

oceanid = repmat(oceanid',1,1,500);
landid = repmat(landid',1,1,500);

% ==============================================================================

pb_1 = CmdLineProgressBar('... Loading ... ');

di = 1;

date_spec = 134;

for date_i = 1:length(date_dur) %166:168;
    
    %% Load spectrum data:
    
    load(['/Volumes/Seaweed_10T/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_spectrum_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_spectrum_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
    
    data_IRBT_lon = GRIDSAT_IRBT_SPECTRUM.lon;
    data_IRBT_lat = GRIDSAT_IRBT_SPECTRUM.lat;
    
    %% SHIFT LONGITUDES:
    
    data_IRBT_lon = [ data_IRBT_lon(721:end-1), data_IRBT_lon(1:720) + 360 ];
    data_IRBT_spectrum = [ GRIDSAT_IRBT_SPECTRUM.power(721:end-1,:,:); GRIDSAT_IRBT_SPECTRUM.power(1:720,:,:)];
    
    %% Categorize Ocean & Land:
    
    % data_IRBT_spectrum = data_IRBT_spectrum.*landid(:,:,1:size(data_IRBT_spectrum,3));
    
    %% Get spectrum for specified area:
    
    lon_id = find( data_IRBT_lon >= target_domian(1) & data_IRBT_lon <= target_domian(2) );
    lat_id = find( data_IRBT_lat >= target_domian(3) & data_IRBT_lat <= target_domian(4) );
    
    tmp_spectrum = nanmean(nanmean(data_IRBT_spectrum(lon_id,lat_id,:)));
    % tmp_spectrum = nanmean(nanmean(data_IRBT_spectrum));
    
    IRBT_Spectrum(di,:) = interp1(GRIDSAT_IRBT_SPECTRUM.frequency,tmp_spectrum(:),linspace(0,4,100));
    
    
    clear GRIDSAT_IRBT_SPECTRUM

    
    pb_1.print(date_i,length(date_dur));
    
    di = di+1;
    
end

IRBT_Spectrum_m = nanmean(IRBT_Spectrum);
IRBT_Spectrum_s = nanstd(IRBT_Spectrum);

% ==============================================================================

%% Plotting figure.

close all;

gf1 = gcf;
% gf1.WindowState = 'maximized';

% ==============================================================================

%% 1. Error range:

xx = linspace(0,4,100);

lo = IRBT_Spectrum_m - IRBT_Spectrum_s;
hi = IRBT_Spectrum_m + IRBT_Spectrum_s;

lo = xx.*lo;
hi = xx.*hi;

xx(xx==0) = 1e-7;

f11_0 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f11_0, 'facecolor', [0.33,0.33,0.33], 'edgecolor', 'none', 'FaceAlpha', 0.25);

hold on;

%% 1. Periodogram:

% f11 = plot(linspace(0,4,100),IRBT_Spectrum_m,'LineWidth',2.5,'Color',[0,0,0],'LineStyle','-');
% f11 = plot(linspace(0,4,100),linspace(0,4,100).*IRBT_Spectrum,'LineWidth',2.5,'Color',[0,0,0],'LineStyle','-');
f11 = plot(linspace(0,4,100),linspace(0,4,100).*IRBT_Spectrum_m,'LineWidth',2.5,'Color',[0,0,0],'LineStyle','-');

f11.LineStyle = '-.';

hold on;

% ==============================================================================

%% Indication lines:

ind_yloc = 300;

v1 = line([1/3,1/3],[-10,1000]);
set(v1,'Color','k','LineStyle','--','LineWidth',1.2);
v2 = line([1/1.55,1/1.55],[-10,1000]);
set(v2,'Color','k','LineStyle','--','LineWidth',1.2);

v3 = line([1/1.25,1/1.25],[-10,1000]);
set(v3,'Color','k','LineStyle','--','LineWidth',1.2);
v4 = line([1/0.9,1/0.9],[-10,1000]);
set(v4,'Color','k','LineStyle','--','LineWidth',1.2);

t1 = text(1/3,ind_yloc-20,'3');
set(t1,'FontName','Helvetica','FontSize',10,'FontWeight','Bold','HorizontalAlignment','center')
set(t1,'BackgroundColor','w','EdgeColor','k','LineWidth',0.8)
t2 = text(1/1.55,ind_yloc-20,'1.55');
set(t2,'FontName','Helvetica','FontSize',10,'FontWeight','Bold','HorizontalAlignment','center')
set(t2,'BackgroundColor','w','EdgeColor','k','LineWidth',0.8)

t3 = text(1/1.25,ind_yloc,'1.25');
set(t3,'FontName','Helvetica','FontSize',10,'FontWeight','Bold','HorizontalAlignment','center')
set(t3,'BackgroundColor','w','EdgeColor','k','LineWidth',0.8)
t4 = text(1/0.9,ind_yloc,'0.9');
set(t4,'FontName','Helvetica','FontSize',10,'FontWeight','Bold','HorizontalAlignment','center')
set(t4,'BackgroundColor','w','EdgeColor','k','LineWidth',0.8)

% ==============================================================================

%% Set axes:

% Axis 1:
a1 = gca;
set(a1,'Box','off','Color','none','PlotBoxAspectRatio',[1,1,1]);
set(a1,'TickDir','out');
set(a1,'Linewidth',2);
set(a1,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
set(a1,'Xlim',[1/25,1/0.77])
set(a1,'XScale','log');
% set(a1,'XTick',[1/60,1/30,1/13,1/5,1/2,1]);
% set(a1,'XTickLabel',{'60';'30';'13';'5';'2';'1'});
set(a1,'XTick',[1/60,1/50,1/40,1/30,1/20,1/14,1/10,1/7,1/5,1/4,1/3,1/2,1/1.55,1/1.25,1,1/0.9]);
set(a1,'XTickLabel',{'60';'';'';'30';'20';'14';'10';'7';'5';'4';'3';'2';'1.55';'';'1';''});
set(a1,'XMinorTick','off');
set(a1,'XMinorGrid','off');
% set(a1,'Xdir','Reverse')
set(a1,'Ylim',[-0.1,330])
% set(a1,'YTick',[0:0.1:1]);
% a1.YTickLabel
set(a1,'YMinorTick','off');
set(a1,'YMinorGrid','off');
% a1.YDir = 'Reverse';

% Axis 2:
% Create new, empty axes with box but with ticks changed:
a2 = axes('Position',get(a1,'Position'),'Box','on','Color','none');
set(a2,'PlotBoxAspectRatio',[1,1,1])
set(a2,'LineWidth',2)
set(a2,'TickLength',[0.0050,0.0250])
set(a2,'TickDir','out')
set(a2,'Xlim',a1.XLim)
set(a2,'XScale','log');
set(a2,'XTick',[1/3,1/1.55,1/1.25,1/0.9]);
set(a2,'XTickLabel',[]);
set(a2,'XMinorTick','off');
% set(a2,'Xdir','Reverse')
set(a2,'Ylim',a1.YLim)
set(a2,'YTick',a1.YTick)
set(a2,'YTickLabel',[])
set(a2,'YMinorTick','off')

% Set original axes as active
axes(a1)

% Link axes in case of zooming
linkaxes([a1 a2])

%% Labels:

xlabel('\bf{period (day)}','FontName','Helvetica','FontSize',14,'FontWeight','bold')
ylabel('\bf{power\cdotfrequency}','FontName','Helvetica','FontSize',14,'FontWeight','bold')

% ==============================================================================

%% Save Figure:

set(gf1,'Color',[1,1,1]);

figname = ['./IRBT_Spectrum_Climatology'];
% figname = ['./IRBT_Spectrum_Climatology_Land'];
% figname = ['./IRBT_Spectrum_specified_',datestr(date_dur(date_spec),'yyyymm')];
% figname = ['./IRBT_VarDiffMap_Climatology_YH10_2007DJF'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300','-transparent')

% ==============================================================================

disp([num2str(toc),' sec.'])
