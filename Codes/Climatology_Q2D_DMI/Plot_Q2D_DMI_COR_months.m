clear; close; clc;
addpath(genpath('/Users/yuhungjui/Dropbox/Work/MATLAB_TOOLS/'));
tic;

% ==============================================================================
% 
% Plot time series of correlation between [ Q2D varaince difference ] & [ IOD index ] in each month.
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

DMI_data_info = ncinfo('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc');
DMI_data = ncread('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc','DMI');
DMI_data_days = ncread('/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_OISST_v2/monthly_dmi/dmi.nc','WEDCEN2');
DMI_date = datetime(1900,1,1) + caldays(DMI_data_days);

for di = 1:numel(date_dur)
    
    date_id = find( DMI_date.Year == date_dur(di).Year & DMI_date.Month == date_dur(di).Month );
    
    DMI(di) = mean(DMI_data(date_id));
    
    clear date_id
    
end

% ==============================================================================

%% Calculation for Q2D variance difference:

% time_phase = 'MONTHLY'

% freq_id = 2

pb_1 = CmdLineProgressBar('... Loading ... ');

for date_i = 1:length(date_dur)

    %% Load FFT Variance Map Data:
    
    if ( ismember(str2double(datestr(date_dur(date_i),'mm')),[1:12]) == 1 ) % & ismember(str2double(datestr(date_dur(date_i),'yyyy')),[1998:2012]) == 1 )
        
        load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
    
        %% Calculate the Q2D variance difference as DMI:
        
        Q2D_box1 = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(921:1001,121:201))); % 50-70E, 10S-10N
        Q2D_box2 = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1081:1161,121:161))); % 90-110E, 10S-EQ
        
        Q2D_var_index(date_i) = Q2D_box1 - Q2D_box2;
        
    else
        
        Q2D_var_index(date_i) = NaN;
    
    end
    
    clear GRIDSAT_IRBT_VAR
    
    pb_1.print(date_i,length(date_dur));
    
end

% ==============================================================================

%% Smooth data:

% Q2D_var_index = smooth(Q2D_var_index,3);
% DMI = smooth(DMI,3);

% ==============================================================================

%% Set plotting variables:

for mi = 1:12
    
    DMI_mon = DMI(date_dur.Month==mi);
    
    Q2D_var_index_mon = Q2D_var_index(date_dur.Month==mi);
    
    rr = corrcoef(Q2D_var_index_mon,DMI_mon);
    
    CORR_Q2D_DMI(mi) = rr(2);
    
end

% ==============================================================================

%% Plotting figure.
close all;

% gf1 = gcf;
% gf1.WindowState = 'maximized';

% ==============================================================================

%% 1. zero line: 

f10 = plot([1:12],zeros(1,12));

f10.LineStyle = ':';
f10.Color = [0.4,0.4,0.4];
f10.LineWidth = 2;

hold on;

%% 1. Q2D var. variation:

f11 = plot([1:12], CORR_Q2D_DMI);

f11.Color = 'k'; % [0.635,0.078,0.184];
f11.LineWidth = 2;

hold on;

%% 1. axis:

% ax1 = axes;

ax11 = gca;

set(ax11,'Box','off','Color','none')
set(ax11,'PlotBoxAspectRatio',[4,1,1])
set(ax11,'TickDir','out')
set(ax11,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax11,'LineWidth',1.5)
set(ax11,'Xlim',[1,12])
set(ax11,'XTick',[1:12])
set(ax11,'XTickLabel',{'J','F','M','A','M','J','J','A','S','O','N','D',})
% set(ax11,'XTickLabelRotation',[])
set(ax11,'XMinorTick','of','XMinorGrid','off')
set(ax11,'Ylim',[-0.5,1])
set(ax11,'YTick',[-0.5:0.5:1])
set(ax11,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','off');

%% 1. Labels:

xlab_11 = xlabel('\bf{Month}');

ylab_11 = ylabel('\bf{corr. coef.}');

%% 2. Set axes: Axis 2:

ax12 = axes('Box','on','Color','none');

set(ax12,'Box','on','Color','none')
set(ax12,'PlotBoxAspectRatio',[4,1,1])
% set(ax12,'PlotBoxAspectRatio',ax11.PlotBoxAspectRatio)
set(ax12,'TickDir','out')
set(ax12,'LineWidth',1.5)
% set(ax22,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax22,'Xlim',[1,length(TT_range)])
set(ax12,'XTick',[])
% set(ax22,'XTickLabel',TimeTable([1:48:length(TT_range)],1))
% set(ax12,'Ylim',[-2.1,2.1])
set(ax12,'YTick',[])
% set(ax21,'YTickLabel',{})
% set(ax12,'YMinorTick','on')
% set(ax12,'YColor',[0,0.4,1])

%% 2. Labels:

% ylab_12 = ylabel('\bf{^\circC}');

% uistack(ax11,'top');

%% 1. Legends:

leg_1 = legend([f11], ...
              {['corr(Q2D,DMI)'], ...
               } ...
               );

% leg1.Position(1) = 0.1;
% leg1.Position(2) = 0.7;

leg_1.Location = 'northwest';

set(leg_1,'Color','none')
set(leg_1,'FontName','Helvetica')
set(leg_1,'FontSize',14)
set(leg_1,'FontWeight','bold')
set(leg_1,'EdgeColor','k')
set(leg_1,'LineWidth',1.5)


% ==============================================================================

disp(toc)

% ==============================================================================

%% Save Figure:
set(gcf,'Color',[1,1,1]);

figname = ['./Q2D_DMI_COR_months'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')




