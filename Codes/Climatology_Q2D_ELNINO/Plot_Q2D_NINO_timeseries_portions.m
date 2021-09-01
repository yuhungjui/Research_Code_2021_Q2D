clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot time series of [ Q2D varaince difference ] & [ El Nino Index ].
% 
% ==============================================================================

%% Set time frame:

date_dur = datetime(1998,1,1):calmonths(1):datetime(2019,12,1);

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

%% Load variance significance:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2019_mnly.mat;

% ==============================================================================

%% Load variance:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

% ==============================================================================

%% Calculation for Q2D variance over WPAC:

% % Basins domain limits:
% 
% basin_domain = [[45,100,-15,15]; ...    % IO
%                 [100,130,-10,15]; ...   % MC
%                 [130,180,-15,15]];      % WPAC

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
%         % Q2D_box = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1241:1441,101:221))); % 130-180E, 15S-15N
%         % Q2D_box = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1261:1441,101:221))); % 135-180E, 15S-15N
%         % Q2D_box = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1261:1441,121:201))); % 135-180E, 10S-10N
%         % Q2D_box_W = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1241:1301,121:201))); % 130-145E, 10S-10N, Western portion
%         % Q2D_box_E = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1301:1441,121:201))); % 145-180E, 10S-10N, Eastern portion
%         % Q2D_box_W = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1241:1321,121:201))); % 130-150E, 10S-10N, Western portion
%         % Q2D_box_E = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1321:1441,121:201))); % 150-180E, 10S-10N, Eastern portion
%         Q2D_box_W = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1241:1341,121:201))); % 130-155E, 10S-10N, Western portion
%         Q2D_box_E = nanmean(nanmean(GRIDSAT_IRBT_VAR.q2d(1341:1441,121:201))); % 155-180E, 10S-10N, Eastern portion
%         
%         Q2D_var_index(1,date_i) = Q2D_box_W;
%         Q2D_var_index(2,date_i) = Q2D_box_E;
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

Q2D_box_W = nanmean(GRIDSAT_IRBT_VAR.q2d(1241:1341,121:201,:),[1,2]); % 130-155E, 10S-10N, Western portion
Q2D_box_E = nanmean(GRIDSAT_IRBT_VAR.q2d(1341:1441,121:201,:),[1,2]); % 155-180E, 10S-10N, Eastern portion

Q2D_var_index(1,:) = Q2D_box_W(:);
Q2D_var_index(2,:) = Q2D_box_E(:);

% ==============================================================================

%% Eliminate Seasonal Cycle:

seasonal_elimination = 1

switch seasonal_elimination
    
    case 1
        
        for bi = 1:2
            for mi = 1:12
                Q2D_var_index_month(mi) = mean(Q2D_var_index(bi,mi:12:end));
            end
            
            Q2D_var_index(bi,:) = Q2D_var_index(bi,:) - repmat(Q2D_var_index_month,1,22);
        end
        
end

% ==============================================================================

%% Smooth data:

smooth_type = 1;

switch smooth_type
    
    case 1

        for bi = 1:2
            Q2D_var_index(bi,:) = smooth(Q2D_var_index(bi,:),3);
        end
        
        nino34 = smooth(nino34,3);
        nino4 = smooth(nino4,3);

end

% ==============================================================================

%% Set plotting variables:

nino_type = 'Nino34'

switch nino_type
    case 'Nino34'
        nino_index = nino34;
    case 'Nino4'
        nino_index = nino4;
end

% ==============================================================================

%% Plotting figure.

branches = 'WPAC'
branches_range = '130–155^\circE, 10^\circS–10^\circN'
% branches_range = '155–180^\circE, 10^\circS–10^\circN'
branches_id = 1

close all;

x_datetime = date_dur;

gf1 = gcf;
gf1.WindowState = 'maximized';

% ==============================================================================

%% 1. Q2D var. variation

f11 = plot(x_datetime, Q2D_var_index(branches_id,:));

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
        set(ax11,'Ylim',[-50,50])
        set(ax11,'YTick',[-120:20:120])
    otherwise
        set(ax11,'Ylim',[0,120])
        set(ax11,'YTick',[0:20:120])
end
set(ax11,'YMinorTick','on','YMinorGrid','off')
% set(ax1,'YGrid','off');

%% 1. Labels:

xlab_11 = xlabel('\bf{Year (1998 Jan. – 2019 Dec.)}');

ylab_11 = ylabel('\bf{K^2}');


%% 2. Right Axis: DMI

yyaxis right

nino_index(isnan(Q2D_var_index)) = NaN;

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

f12m = plot(x_datetime, repmat(mean(nino_index),[1,numel(x_datetime)]));

f12m.Color = hex2rgb('339641'); % hex2rgb('48BF91'); % hex2rgb('8BD9C7'); % [0.33,1,0.67];
f12m.LineWidth = 4;
f12m.LineStyle = ':';

hold on;

f12 = plot(x_datetime, nino_index);

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
set(ax12,'Ylim',[-4.1,4.1])
set(ax12,'YTick',[-4:1:4])
% set(ax21,'YTickLabel',{})
set(ax12,'YMinorTick','on')
set(ax12,'YColor',hex2rgb('339641'))

%% 2. Labels:
ylab_12 = ylabel('\bf{^\circC}');

uistack(ax11,'top');

%% 1. Legends:

% leg_1 = legend([f11, f12], ...
%               {['Q2D var.',newline,'(',branches_range,')'], ...
%                [nino_type] ...
%               } ...
%              );

leg_1 = legend([f11, f12], ...
              {['Q2D var. (',branches_range,')'], ...
               [nino_type] ...
              } ...
             );

% leg1.Position(1) = 0.1;
% leg1.Position(2) = 0.7;

leg_1.Location = 'northwest';

set(leg_1,'Color','none')
set(leg_1,'FontName','Helvetica')
set(leg_1,'FontSize',28)
set(leg_1,'FontWeight','bold')
set(leg_1,'EdgeColor','k')
set(leg_1,'LineWidth',2.5)
set(leg_1,'Orientation','horizontal')

%% 1. Correlation Coefficient:

rr = corrcoef(Q2D_var_index(branches_id,:),nino_index);

leg_2_R = ['R: ',num2str(round(rr(2),2))];

leg_2 = text(datetime(2013,1,1),2.5,leg_2_R);

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

figname = ['./Q2D(',branches,')_',nino_type,'_Climatology_Timeseries'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')




