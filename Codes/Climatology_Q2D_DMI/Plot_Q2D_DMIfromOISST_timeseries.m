clear; close; clc;
addpath(genpath('/Users/yuhungjui/Dropbox/Work/MATLAB_TOOLS/'));
tic;

% ==============================================================================
% 
% Plot time series of [ Q2D varaince difference ] & [ IOD index ].
% 
% ==============================================================================

%% Set time frame:

date_dur = datetime(1998,1,1):calmonths(1):datetime(2018,12,1);

% ==============================================================================

%% Calculation for Q2D variance difference:

% time_phase = 'MONTHLY'

% freq_id = 2

pb_1 = CmdLineProgressBar('... Loading ... ');

for date_i = 1:length(date_dur)

    %% Load FFT Variance Map Data:
    
    if ( ismember(str2double(datestr(date_dur(date_i),'mm')),[1:12]) == 1 ) % & ismember(str2double(datestr(date_dur(date_i),'yyyy')),[1998:2012]) == 1 )
        
        load(['/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/',datestr(date_dur(date_i),'yyyy'),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(date_i),'yyyy'),'_',datestr(date_dur(date_i),'mm'),'.mat']);
    
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

% %% Load SST:
% 
% pb_2 = CmdLineProgressBar('... Loading ... ');
% 
% di = 1;
% 
% for yr_i = 1998:2018
%     
%     %% Load SST Map Data:
%     
%     load(['/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_OISST_v2/monthly_hires_mat/NOAA_OISST_TROPICS_',num2str(yr_i),'_mnly.mat']);
%     
%     %% Calculate the DMI:
% 
%     if ( yr_i == 1998 )
%         
%         SST_box1 = nanmean( nanmean( NOAA_OISST_TROPICS_mnly.sst_mnly(200:281,121:202,:) ),2 ); % 50-70E, 10S-10N
%         SST_box2 = nanmean( nanmean( NOAA_OISST_TROPICS_mnly.sst_mnly(360:441,121:162,:) ),2 ); % 90-110E, 10S-EQ
%         SST_box1 = SST_box1(:);
%         SST_box2 = SST_box2(:);
%         
%     else
%         
%         tmp_SST_box1 = nanmean( nanmean( NOAA_OISST_TROPICS_mnly.sst_mnly(200:281,121:202,:) ),2 ); % 50-70E, 10S-10N
%         tmp_SST_box2 = nanmean( nanmean( NOAA_OISST_TROPICS_mnly.sst_mnly(360:441,121:162,:) ),2 ); % 90-110E, 10S-EQ
%         SST_box1 = [SST_box1; tmp_SST_box1(:)];
%         SST_box2 = [SST_box2; tmp_SST_box2(:)];
% 
%     end
%     
%     di = di + 1;
%     
%     clear NOAA_OISST_TROPICS_mnly.sst_mnly
%     
%     pb_2.print(yr_i,2018);
%     
% end
% 
% DMI = (SST_box1-mean(SST_box1)) - (SST_box2-mean(SST_box2));

%% Load SST:

pb_2 = CmdLineProgressBar('... Loading ... ');

di = 1;

for yr_i = 1998:2018
    
    %% Load SST Map Data:
    
    load(['/Users/yuhungjui/GoogleDrive_NTU/Data/DATA_NOAA_OISST_v2/monthly_hires_mat/NOAA_OISST_TROPICS_',num2str(yr_i),'_mnly.mat']);
    
    %% Calculate the DMI:

    if ( yr_i == 1998 )
        
        SST_box1 = NOAA_OISST_TROPICS_mnly.sst_mnly(200:281,121:202,:); % 50-70E, 10S-10N
        SST_box2 = NOAA_OISST_TROPICS_mnly.sst_mnly(360:441,121:162,:); % 90-110E, 10S-EQ
        
    else
        
        tmp_SST_box1 = NOAA_OISST_TROPICS_mnly.sst_mnly(200:281,121:202,:); % 50-70E, 10S-10N
        tmp_SST_box2 = NOAA_OISST_TROPICS_mnly.sst_mnly(360:441,121:162,:); % 90-110E, 10S-EQ
        SST_box1 = cat(3,SST_box1,tmp_SST_box1);
        SST_box2 = cat(3,SST_box2,tmp_SST_box2);
        
    end
    
    di = di + 1;
    
    clear NOAA_OISST_TROPICS_mnly.sst_mnly
    
    pb_2.print(yr_i,2018);
    
end

SSTa_box1 = SST_box1 - nanmean(SST_box1,3);
SSTa_box2 = SST_box2 - nanmean(SST_box2,3);

DMI = nanmean( nanmean( SSTa_box1, 1 ), 2 ) - nanmean( nanmean( SSTa_box2, 1 ), 2 );
DMI = DMI(:);

% ==============================================================================

%% Smooth data:

Q2D_var_index = smooth(Q2D_var_index,3);
DMI = smooth(DMI,3);

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

ax1 = gca;

set(ax1,'Box','on','Color','none')
set(ax1,'PlotBoxAspectRatio',[4,1,1])
set(ax1,'TickDir','out')
set(ax1,'FontName','Helvetica','FontSize',24,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax1,'LineWidth',2.5)
% set(ax1,'Xlim',x_datetime)
set(ax1,'XTick',x_datetime(1:12:end))
% set(ax1,'XTickLabelRotation',45)
% set(ax11,'XTickLabel',[])
set(ax1,'XMinorTick','on','XMinorGrid','off')
set(ax1,'Ylim',[-85,85])
set(ax1,'YTick',[-100:20:100])
set(ax1,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','off');

%% 1. Labels:

xlab_11 = xlabel('\bf{Year}');

ylab_11 = ylabel('\bf{K^2}');

%% 2. Right Axis: DMI

yyaxis right

DMI(isnan(Q2D_var_index)) = NaN;

f12 = plot(x_datetime, DMI);

f12.Color = [0,0.4,1];
f12.LineWidth = 4;

%% 2. Set axes: Axis 2:
ax12 = gca;

% set(ax22,'Box','on','Color','none')
% set(ax22,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax22,'Xlim',[1,length(TT_range)])
% set(ax22,'XTick',[1:48:length(TT_range)])
% set(ax22,'XTickLabel',TimeTable([1:48:length(TT_range)],1))
set(ax12,'Ylim',[-1.6,1.6])
set(ax12,'YTick',[-2:0.5:2])
% set(ax21,'YTickLabel',{})
set(ax12,'YMinorTick','on')
set(ax12,'YColor',[0,0.4,1])

%% 2. Labels:
ylab_12 = ylabel('\bf{^\circC}');

%% 1. Legends:

leg_1 = legend([f11, f12], ...
              {['Q2D var. diff.'], ...
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

rr = corrcoef(Q2D_var_index(1:end-1),DMI(1:end-1));

leg_2_R = ['R = ',num2str(round(rr(2),2))];

leg_2 = text(datetime(2017,1,1),1.3,leg_2_R);

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
a
% ==============================================================================
%% Save Figure:
set(gcf,'Color',[1,1,1]);

figname = ['./Q2D_DMI_Climatology_Timeseries_OISST'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')




