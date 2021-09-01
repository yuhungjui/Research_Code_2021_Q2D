clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot IRBT mean-variance scatter plot.
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2019,12,1)]';

% Get_Seasons_1998_2018;

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

mon_i = 0;

% ==============================================================================

%% Load IRBT monthly mean:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_mean_1998_2019_mnly.mat;

%% Load variance:

load /Users/yuhungjui/Research_tmp/2021_Q2D/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

% ==============================================================================

%% Averaging:

% IRBT_m = nanmean(GRIDSAT_IRBT_MEAN.irbt_mean,3);
% 
% IRBT_v_total = nanmean(GRIDSAT_IRBT_VAR.total,3);
% IRBT_v_q2d = nanmean(GRIDSAT_IRBT_VAR.q2d,3);
% IRBT_v_dc = nanmean(GRIDSAT_IRBT_VAR.dc,3);

% ==============================================================================

%% Specified domains:

% GRIDSAT_IRBT_MEAN.irbt_mean = GRIDSAT_IRBT_MEAN.irbt_mean(:,81:241,:);
% GRIDSAT_IRBT_VAR.total = GRIDSAT_IRBT_VAR.total(:,81:241,:);
% GRIDSAT_IRBT_VAR.q2d = GRIDSAT_IRBT_VAR.q2d(:,81:241,:);
% GRIDSAT_IRBT_VAR.dc = GRIDSAT_IRBT_VAR.dc(:,81:241,:);

% ==============================================================================

%% Calculation

IRBT_ticks = [240:5:310];
IRBT_range = [237.5:5:312.5];

for irbti = 1:numel(IRBT_range)-1
    
    IRBT_range_id = find( GRIDSAT_IRBT_MEAN.irbt_mean >= IRBT_range(irbti) ...
                        & GRIDSAT_IRBT_MEAN.irbt_mean < IRBT_range(irbti+1) );
    
    IRBTvar_total_range_mean(irbti) = nanmean(GRIDSAT_IRBT_VAR.total(IRBT_range_id));
    IRBTvar_total_range_std(irbti) = nanstd(GRIDSAT_IRBT_VAR.total(IRBT_range_id));
    IRBTvar_total_range_num(irbti) = sum(~isnan(GRIDSAT_IRBT_VAR.total(IRBT_range_id)));
                    
    IRBTvar_q2d_range_mean(irbti) = nanmean(GRIDSAT_IRBT_VAR.q2d(IRBT_range_id));
    IRBTvar_q2d_range_std(irbti) = nanstd(GRIDSAT_IRBT_VAR.q2d(IRBT_range_id));
    IRBTvar_q2d_range_num(irbti) = sum(~isnan(GRIDSAT_IRBT_VAR.q2d(IRBT_range_id)));
    
    IRBTvar_dc_range_mean(irbti) = nanmean(GRIDSAT_IRBT_VAR.dc(IRBT_range_id));
    IRBTvar_dc_range_std(irbti) = nanstd(GRIDSAT_IRBT_VAR.dc(IRBT_range_id));
    IRBTvar_dc_range_num(irbti) = sum(~isnan(GRIDSAT_IRBT_VAR.dc(IRBT_range_id)));

    IRBT_range_num(irbti) = numel(IRBT_range_id);

end

%% Criteria for data number:

data_num_cri = 500;

IRBTvar_total_range_mean(IRBTvar_total_range_num<data_num_cri) = NaN;
IRBTvar_total_range_std(IRBTvar_total_range_num<data_num_cri) = NaN;
IRBTvar_q2d_range_mean(IRBTvar_q2d_range_num<data_num_cri) = NaN;
IRBTvar_q2d_range_std(IRBTvar_q2d_range_num<data_num_cri) = NaN;
IRBTvar_dc_range_mean(IRBTvar_dc_range_num<data_num_cri) = NaN;
IRBTvar_dc_range_std(IRBTvar_dc_range_num<data_num_cri) = NaN;

% ==============================================================================

%% Selecting data for plotting:

% IRBTvar_total_range_mean = nan(size(IRBTvar_total_range_mean));
% IRBTvar_total_range_std = nan(size(IRBTvar_total_range_std)); 
% IRBTvar_q2d_range_mean = nan(size(IRBTvar_q2d_range_mean)); 
% IRBTvar_q2d_range_std = nan(size(IRBTvar_q2d_range_std)); 
% IRBTvar_dc_range_mean = nan(size(IRBTvar_dc_range_mean)); 
% IRBTvar_dc_range_std = nan(size(IRBTvar_dc_range_std)); 

% ==============================================================================

%% 1. Plotting figure.

close all;

gf1 = gcf;

total_color = [0.33,0.33,0.33];
q2d_color = [1,0.33,0.33];
dc_color = [0.33,0.67,1];

y_log_scale_id = 0;

%% Errorbar plot w/ shading:

nanid = ~isnan(IRBTvar_total_range_mean);

lo = IRBTvar_total_range_mean(nanid) - IRBTvar_total_range_std(nanid);
hi = IRBTvar_total_range_mean(nanid) + IRBTvar_total_range_std(nanid);

if (y_log_scale_id==1); lo(lo<0)=1; end

xx = IRBT_ticks(nanid);

f10_2 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f10_2, 'facecolor', total_color, 'edgecolor', 'none', 'FaceAlpha', 0.25);

hold on;

nanid = ~isnan(IRBTvar_q2d_range_mean);

lo = IRBTvar_q2d_range_mean(nanid) - IRBTvar_q2d_range_std(nanid);
hi = IRBTvar_q2d_range_mean(nanid) + IRBTvar_q2d_range_std(nanid);

if (y_log_scale_id==1); lo(lo<0)=1; end

xx = IRBT_ticks(nanid);

f11_2 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f11_2, 'facecolor', q2d_color, 'edgecolor', 'none', 'FaceAlpha', 0.25);

hold on;

nanid = ~isnan(IRBTvar_dc_range_mean);

lo = IRBTvar_dc_range_mean(nanid) - IRBTvar_dc_range_std(nanid);
hi = IRBTvar_dc_range_mean(nanid) + IRBTvar_dc_range_std(nanid);

if (y_log_scale_id==1); lo(lo<0)=1; end

xx = IRBT_ticks(nanid);

f12_2 = patch([xx, xx(end:-1:1), xx(1)], [lo, hi(end:-1:1), lo(1)], [0.8,0.8,0.8]);

set(f12_2, 'facecolor', dc_color, 'edgecolor', 'none', 'FaceAlpha', 0.25);

hold on;

%% Lines:

f10 = line(IRBT_ticks,IRBTvar_total_range_mean);

f10.Color = 'k'
f10.Marker = '.';
f10.MarkerSize = 16;
f10.LineWidth = 1.5;

hold on;

f11 = line(IRBT_ticks,IRBTvar_q2d_range_mean);

f11.Color = [0.635,0.078,0.184];
f11.Marker = '.';
f11.MarkerSize = 16;
f11.LineWidth = 1.5;

hold on;

f12 = line(IRBT_ticks,IRBTvar_dc_range_mean);

f12.Color = [0,0.4,1];
f12.Marker = '.';
f12.MarkerSize = 16;
f12.LineWidth = 1.5;


%% 1. Set axes: Axis 1:

ax11 = gca;

set(ax11,'Box','off','Color','none');
set(ax11,'PlotBoxAspectRatio',[1,1,1])
set(ax11,'Position',[0.125,0.125,0.75,0.75])
set(ax11,'TickDir','out')
set(ax11,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax11,'Position',[0.15 0.5 0.7 0.5])
set(ax11,'LineWidth',2)
set(ax11,'Xlim',[250,300])
set(ax11,'XTick',[250:10:300])
% set(ax11,'XTickLabel',[])
set(ax11,'XDir','reverse')
set(ax11,'XMinorTick','on','XMinorGrid','off')
set(ax11,'Ylim',[-200,800])%set(ax11,'Ylim',[70,800])
% set(ax11,'Ylim',[0,250])%set(ax11,'Ylim',[0,90])
set(ax11,'YTick',[0:100:1e3])
% set(ax11,'YTick',[0:20:100])
if (y_log_scale_id==1)
    set(ax11,'YScale','log') % Log-scale
    set(ax11,'Ylim',[1,1e3]) % Log-scale
    set(ax11,'YTick',[1e0,1e1,1e2,1e3]) % Log-scale
end
set(ax11,'YMinorTick','on','YMinorGrid','off')
set(ax11,'YGrid','off');

%% 1. Labels:
xlabel('\bf{IR Brightness Temperature (K)}')
% ylabel('\bf{IR Brightness Temperature Var. (K^2)}')

%% 2. Set axes: Axis 2:

% ax12 = axes('Position',get(ax11,'Position'),'Box','off','Color','none','XTick',[]);
% 
% set(ax12,'PlotBoxAspectRatio',[1,1,1])
% set(ax12,'TickLength',[0.0050,0.0250])
% set(ax12,'TickDir','out')
% set(ax12,'FontName','Helvetica','FontSize',14,'FontWeight','bold')
% set(ax12,'TickDir','out')
% set(ax12,'LineWidth',2)
% set(ax12,'Xlim',ax11.XLim);
% set(ax12,'Ylim',[1,1e8]);
% % set(ax12,'YTick',[1,]);
% set(ax12,'YMinorTick','off')
% set(ax12,'YScale','log')
% set(ax12,'YAxisLocation','right')
% 
% ylabel('\bf{Grid Number}')

%% 2. Plot numbers:

% f20 = line(IRBT_ticks,IRBTvar_total_range_num);
% 
% f20.Color = [0.5,0.5,0.5];
% f20.LineStyle = '--';
% f20.Marker = 'o';
% f20.MarkerSize = 6;
% f20.LineWidth = 0.5;
% 
% hold on;
% 
% f21 = line(IRBT_ticks,IRBTvar_q2d_range_num);
% 
% f21.Color = [0.635,0.078,0.184];
% f21.LineStyle = '--';
% f21.Marker = 'o';
% f21.MarkerSize = 6;
% f21.LineWidth = 0.5;
% 
% hold on;
% 
% f22 = line(IRBT_ticks,IRBTvar_dc_range_num);
% 
% f22.Color = [0,0.4,1];
% f22.LineStyle = '--';
% f22.Marker = 'o';
% f22.MarkerSize = 6;
% f22.LineWidth = 0.5;

%% 3. Set axes: Axis 3:
ax13 = axes('Position',get(ax11,'Position'),'Box','on','Color','none','XTick',[],'YTick',[]);

set(ax13,'PlotBoxAspectRatio',ax11.PlotBoxAspectRatio)
set(ax13,'TickDir','out')
set(ax13,'LineWidth',2)

%% 1. Legends:

% leg1 = legend([f10,f12,f11,f20,f22,f21],{'total','dc','q2d','#(total)','#(dc)','#(q2d)'});
leg1 = legend([f10,f11,f12],{'Total var.','Q2D var.','DC var.'});

% leg1.Position(1) = 0.60;
% leg1.Position(2) = 0.82;
set(leg1,'LineWidth',2)
set(leg1,'FontName','Helvetica','FontSize',16,'FontWeight','bold')
set(leg1,'Box','on')
set(leg1,'Color','none')
set(leg1,'Location','NorthWest')
if (y_log_scale_id==1)
    set(leg1,'Location','SouthEast')
end

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gf1,'Color',[1,1,1]);

if (y_log_scale_id==1)
    figname = './IRBT_Mean-Var_Climatology_Log';
else
    figname = './IRBT_Mean-Var_Climatology';
end

% export_fig([figname,'.png'],'-r300')
export_fig([figname,'.png'],'-r300','-transparent')
