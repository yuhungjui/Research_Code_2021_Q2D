clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot time series of [ Q2D varaince difference ] & [ IOD index ].
% 
% ==============================================================================

%% Set time frame:

date_dur = datetime(1998,1,1):calmonths(1):datetime(2019,12,1);

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

%% Load variance significance:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2019_mnly.mat;

% ==============================================================================

%% Load variance:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

% ==============================================================================

%% Calculation for Q2D variance difference:

% pb_1 = CmdLineProgressBar('... Loading ... ');
% 
% for date_i = 1:length(date_dur)
% 
%     %% Load FFT Variance Map Data:
%     
%     if ( ismember(str2double(datestr(date_dur(date_i),'mm')),[1:12]) == 1 ) % & ismember(str2double(datestr(date_dur(date_i),'yyyy')),[1998:2012]) == 1 )
%         
%         load(['/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
%     
%         %% Calculate the Q2D variance difference as DMI:
%         
%         Q2D_box1 = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(921:1001,121:201))); % 50-70E, 10S-10N
%         Q2D_box2 = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1081:1161,121:161))); % 90-110E, 10S-EQ
%         
%         Q2D_var_index(date_i) = Q2D_box1 - Q2D_box2;
%         
%     else
%         
%         Q2D_var_index(date_i) = NaN;
%     
%     end
%     
%     clear GRIDSAT_IRBT_VAR
%     
%     pb_1.print(date_i,length(date_dur));
%     
% end

Q2D_box1 = nanmean(GRIDSAT_IRBT_VAR.q2d(921:1001,121:201,:),[1,2]); % 50-70E, 10S-10N
Q2D_box2 = nanmean(GRIDSAT_IRBT_VAR.q2d(1081:1161,121:161,:),[1,2]); % 90-110E, 10S-EQ

Q2D_var_index = Q2D_box1 - Q2D_box2;
Q2D_var_index = Q2D_var_index(:);

% ==============================================================================

%% Eliminate Seasonal Cycle:

seasonal_elimination = 1

switch seasonal_elimination
    
    case 1
        
        for mi = 1:12
            Q2D_var_index_month(mi) = mean(Q2D_var_index(mi:12:end));
        end
        
        Q2D_var_index = Q2D_var_index' - repmat(Q2D_var_index_month,1,22);

end

% ==============================================================================

%% Smooth data:

smooth_type = 1

switch smooth_type
    
    case 1

        Q2D_var_index = smooth(Q2D_var_index,3);
        DMI = smooth(DMI,3);

end

% ==============================================================================

%% Plotting figure.
close all;

x_datetime = date_dur;

gf1 = gcf;
gf1.WindowState = 'maximized';

% ==============================================================================

%% 1. Q2D var. variation

f11 = plot(x_datetime, Q2D_var_index);

f11.Color = [0.635,0.078,0.184];
f11.LineWidth = 4;

hold on;

%% 1. axis:

% ax1 = axes;

ax11 = gca;

set(ax11,'Box','on','Color','none')
set(ax11,'PlotBoxAspectRatio',[4,1,1])
set(ax11,'TickDir','out')
set(ax11,'FontName','Helvetica','FontSize',24,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax11,'LineWidth',2.5)
% set(ax1,'Xlim',x_datetime)
set(ax11,'XTick',x_datetime(1:12:end))
% set(ax1,'XTickLabelRotation',45)
% set(ax11,'XTickLabel',[])
set(ax11,'XMinorTick','on','XMinorGrid','off')
switch seasonal_elimination
    case 1
        set(ax11,'Ylim',[-70,70])
        set(ax11,'YTick',[-120:20:120])
    otherwise
        set(ax11,'Ylim',[-85,85])
        set(ax11,'YTick',[-100:20:100])
end
set(ax11,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','off');

%% 1. Labels:

xlab_11 = xlabel('\bf{Year (1998 Jan. – 2019 Dec.)}');

ylab_11 = ylabel('\bf{K^2}');


%% 2. Right Axis: DMI

yyaxis right

DMI(isnan(Q2D_var_index)) = NaN;

%% 2. Std. plot w/ shading:

% lo = repmat(mean(DMI) - std(DMI),[1,numel(x_datetime)]);
% hi = repmat(mean(DMI) + std(DMI),[1,numel(x_datetime)]);
% 
% xx = x_datetime;
% 
% f12std = fill([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.33,0.67,1]);
% 
% set(f12std, 'facecolor', [0.33,0.67,1], 'edgecolor', 'none', 'FaceAlpha', 0.25);
% 
% hold on;

f12m = plot(x_datetime, repmat(mean(DMI),[1,numel(x_datetime)]));

f12m.Color = hex2rgb('339641'); % hex2rgb('48BF91'); % hex2rgb('8BD9C7'); % [0.33,1,0.67];
f12m.LineWidth = 4;
f12m.LineStyle = ':';

hold on;

f12 = plot(x_datetime, DMI);

f12.Color =  hex2rgb('339641'); % hex2rgb('48BF91'); % hex2rgb('8BD9C7'); % [0,1,0.4];
f12.LineWidth = 4;
f12.LineStyle = '-.';

hold on;

%% 2. Set axes: Axis 2:

ax12 = gca;

% set(ax22,'Box','on','Color','none')
% set(ax22,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax22,'Xlim',[1,length(TT_range)])
% set(ax22,'XTick',[1:48:length(TT_range)])
% set(ax22,'XTickLabel',TimeTable([1:48:length(TT_range)],1))
set(ax12,'Ylim',[-2.1,2.1])
set(ax12,'YTick',[-2:0.5:2])
% set(ax21,'YTickLabel',{})
set(ax12,'YMinorTick','on')
set(ax12,'YColor',hex2rgb('339641'))

%% 2. Labels:
ylab_12 = ylabel('\bf{^\circC}');

uistack(ax11,'top');

%% 1. Legends:

leg_1 = legend([f11, f12], ...
              {['Q2D variance index'], ...
               ['DMI'] ...
              } ...
             );

% leg1.Position(1) = 0.1;
% leg1.Position(2) = 0.7;

leg_1.Location = 'northwest';

set(leg_1,'Color','none')
set(leg_1,'FontName','Helvetica')
set(leg_1,'FontSize',36)
set(leg_1,'FontWeight','bold')
set(leg_1,'EdgeColor','k')
set(leg_1,'LineWidth',2.5)

%% 1. Correlation Coefficient:

DMI = DMI(~isnan(Q2D_var_index));

Q2D_var_index = Q2D_var_index(~isnan(Q2D_var_index));

rr = corrcoef(Q2D_var_index,DMI);

leg_2_R = ['R: ',num2str(round(rr(2),2))];

leg_2 = text(datetime(2017,1,1),1.5,leg_2_R);

set(leg_2,'HorizontalAlignment','center')
set(leg_2,'VerticalAlignment','middle')
set(leg_2,'Units','normalized')
set(leg_2,'FontName','Helvetica')
set(leg_2,'FontSize',36)
set(leg_2,'FontWeight','bold')
% set(leg_2,'BackgroundColor','w')
% set(leg_2,'EdgeColor','k')
set(leg_2,'LineWidth',1)

% ==============================================================================

disp(toc)

% ==============================================================================
%% Save Figure:
set(gcf,'Color',[1,1,1]);

figname = ['./Q2D_DMI_Climatology_Timeseries'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')




