clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot IRBT variance maps of [ Q2D ] & [ DC ] over all time (1998–2018).
% 
% ==============================================================================

%% Set time frame:

date_dur = [datetime(1998,1,1):calmonths(1):datetime(2019,12,31)]';

% Get_Seasons_1998_2019;

%% Basins domain limits:

basin_domain = [[50,100,-10,10]; ...            % IO
                [100,130,-10,10]; ...           % MC
                [130,180,-10,10]; ...           % WPAC
                [10,25,-8,8]; ...               % Congo
                [295,310,-35,-20]; ...          % South America
                [260,285,30,40]; ...            % CONUS
                [288,308,-10,5]; ...            % Amazon
                [97,150,5,35]; ...              % TEA
                [119.5,122.5,21.5,25.5]; ...    % Taiwan
                ];

% ==============================================================================

%% Set target time (month or season):

% target_month_id = 166; % 2011 Oct. %42:44; % 2001 Jun.-Aug. %36:38; % 2000 Dec.-2001 Feb.
% target_season_id =  55; % 2011 SON. %14; % 2001 JJA. %12; % 2000 DJF.

% ==============================================================================

%% Frequency types:

freq_type{1} = 'dc';
freq_type{2} = 'q2d';
freq_type{3} = 'total';

freq_id = 1

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

%% Load variance significance:

load /Volumes/Seaweed_10T/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_significance_25km_mat/GRIDSAT_IRBT_TROPICS_significance_1998_2019_mnly.mat;

% ==============================================================================

%% Load variance:

load /Volumes/Seaweed_10T/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/GRIDSAT_IRBT_TROPICS_var_1998_2019_mnly.mat;

% ==============================================================================

%% Calculate the Variance according to its Significance:

eval([ 'Var_Map = GRIDSAT_IRBT_VAR.',freq_type{freq_id},';' ]);

if ( freq_id == 3 )
    Var_Map_bySig = Var_Map;
else
    eval([ 'VarSig_Map = GRIDSAT_IRBT_SIGNIFICANCE.',freq_type{freq_id},';' ]);
    Var_Map_bySig = Var_Map.*VarSig_Map;
    % Var_Map_bySig = Var_Map;
end

% ==============================================================================

%% Get mean:

% eval([ 'Var_Map = sqrt(GRIDSAT_IRBT_VAR.',freq_type{freq_id},');' ]);
% eval([ 'Var_Map = GRIDSAT_IRBT_VAR.',freq_type{freq_id},';' ]);
% eval([ 'Var_Map(GRIDSAT_IRBT_SIGNIFICANCE.',freq_type{freq_id},'==0) = NaN;' ]);

switch mon_id
    case 0
        Var_Map_mean = nanmean(Var_Map_bySig(:,:,:),3);
    otherwise
        Var_Map_mean = nanmean(Var_Map_bySig(:,:,target_month_id{mon_id}),3);
end
% Var_Map_mean = Var_Map;

clear *_Map

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

%% Plotting figure.

close all;

gf1 = gcf;
gf1.WindowState = 'maximized';

% ==============================================================================

%% 1. Variance Difference Map:

%     %% Set sub-pot locations:
    
%     switch mi
%         case 1
%             sub_id_v = 1; sub_id_h = 1;
%         case 2
%             sub_id_v = 1; sub_id_h = 2;
%         case 3
%             sub_id_v = 2; sub_id_h = 1;
%         case 4
%             sub_id_v = 2; sub_id_h = 2;
%     end

%% Sub-Plot:

% subaxis(2,2,sub_id_h,sub_id_v,'Spacing',0.025);


% [f11, f11h] = contourf(IRBT_LON,IRBT_LAT,VarDiff_Map_mean',22,'LineStyle','none');

f11 = pcolor(IRBT_LON,IRBT_LAT,Var_Map_mean');
set(f11,'LineStyle','none')
set(f11,'EdgeAlpha',0); % 'FaceAlpha',0.8

caxis([0,165])

if ( freq_id == 3 )
    caxis([0,600])
    % caxis([0,55])
end

cm = redblue(22);
switch freq_id
    case 1
        cm = cm(11:-1:1,:);
    case 2
        cm = cm(12:22,:);
    case 3
        % load cm_IRBTfreq
        % for ii = 1:3; cm2(:,ii) = interp1([1:14],cm(:,ii),linspace(1,14,11)); end
        % % cm2 = [[1,1,1];cm2];
        % cm = cm2;
        % clear cm2
        cm = haxby(12);
end

colormap(cm)
cb = colorbar;

set(cb,'YTick',[0:30:210])

if ( freq_id == 3 )
    set(cb,'YTick',[0:100:1000])
    % set(cb,'YTick',[0:10:50])
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

%% Plot the world map:

% gshhs_res = 'i'; % f, h, i, l, c
% 
% shorelines = gshhs(['/Users/yuhungjui/GoogleDrive_NTU/Data/MAP/DATA_GSHHG/gshhg-bin-2.3.7/gshhs_',gshhs_res,'.b']);
% levels = [shorelines.Level];
% land = (levels==1);
% 
% % f100 = geoshow(shorelines(~land),'FaceColor',[0.4,1.0,1.0],'FaceAlpha',0.1);
% 
% % hold on;
% 
% f001 = geoshow([shorelines.Lat],[shorelines.Lon],'Color','k','LineWidth',1.2);
% 
% hold on;
% 
% % levels = [shorelines.Level];
% % land = (levels==1);
% % 
% % f002 = geoshow(shorelines(land),'FaceColor',[0.2,1,0.2]);
% % 
% % hold on;

%% Plot the Equator:
fEQ = refline(0,0);
set(fEQ,'LineStyle','-.','LineWidth',1.2,'Color',[0.5,0.5,0.5]);

hold on;

% ==============================================================================

%% Plot the basin boxes:

if ( ismember(freq_id,[1,2,3]) == 1 )
    for bi = [1,3:7]
        
        box_lon = [basin_domain(bi,1), basin_domain(bi,2), basin_domain(bi,2), basin_domain(bi,1), basin_domain(bi,1)];
        box_lat = [basin_domain(bi,3), basin_domain(bi,3), basin_domain(bi,4), basin_domain(bi,4), basin_domain(bi,3)];
        
        f1box = plot(box_lon, box_lat,'LineWidth',2.5,'Color',[0.1,0.1,0.1],'LineStyle',':');
        
        hold on;
        
    end
end

% ==============================================================================

%% 1. Set axes: Axis 1:

axfont = 24;

axis equal

ax1 = gca;
set(ax1,'Color',[0.2,0.2,0.2]); % For NaN points color.
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

switch mon_id
    case 0
        leg1_label = 'DC var.';%'{[freq_type{freq_id}]};
    otherwise
        % leg1_label = ['Q2D (',target_month_name{mon_id},')'];%[freq_type{freq_id},' (',target_month_name{mon_id},')'];
        leg1_label = target_month_name{mon_id};
end

leg1 = text(3,37,leg1_label);

set(leg1,'HorizontalAlignment','left')
set(leg1,'VerticalAlignment','top')
set(leg1,'FontName','Helvetica')
set(leg1,'FontSize',axfont)
set(leg1,'FontWeight','bold')
set(leg1,'BackgroundColor',[1,1,1,0.85])
set(leg1,'EdgeColor','k')
set(leg1,'LineWidth',1.5)

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
cbu = text(1.5,-0.12,'(K^2)');
% cbu = text(1.5,-0.2,'(K)');
set(cbu,'Parent',cbu_axis)
set(cbu,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')

% ==============================================================================

%% Save Figure:

set(gf1,'Color',[1,1,1]);

switch mon_id
    case 0
        figname = ['./IRBT_Var_Map_',freq_type{freq_id},'_Climatology'];
    otherwise
        figname = ['./IRBT_Var_Map_',freq_type{freq_id},'_Climatology_',target_month_name{mon_id}];
end

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

% ==============================================================================

disp([num2str(toc),' sec.'])

