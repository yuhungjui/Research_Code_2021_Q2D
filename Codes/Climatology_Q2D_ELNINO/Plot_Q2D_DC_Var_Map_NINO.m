clear; close; clc;

addpath(genpath('/Users/yuhungjui/OneDrive/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Plot IRBT variance difference map between [ Q2D ] & [ DC ] over WPAC
% in different [ NINO ] conditions:
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

%% Determine which index phase to plot: 

nino_type = 'Nino34'

switch nino_type
    case 'Nino34'
        nino_index = nino34;
    case 'Nino4'
        nino_index = nino4;
end

% phase_type = 'NINO++'
% phase_type = 'NINO_N'
phase_type = 'NINO--'
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

% gf1 = gcf;
% gf1.WindowState = 'maximized';

%% Plotting:

f11 = pcolor(IRBT_LON,IRBT_LAT,Var_Map_mean(:,:)');
set(f11,'LineStyle','none')
set(f11,'EdgeAlpha',0); % 'FaceAlpha',0.8

caxis([0,120])

if ( freq_id == 3 )
    caxis([-50,1050])
    % caxis([0,55])
end

cm = redblue(12);
switch freq_id
    case 1
        cm = cm(6:-1:1,:);
    case 2
        cm = cm(7:12,:);
    case 3
        load cm_IRBTfreq
        for ii = 1:3; cm2(:,ii) = interp1([1:14],cm(:,ii),linspace(1,14,11)); end
        % cm2 = [[1,1,1];cm2];
        cm = cm2;
        clear cm2
end

colormap(cm)
cb = colorbar;

set(cb,'YTick',[0:20:210])

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

%% 1. Plot the World Map over WPAC:

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

%% Plot the basin boxes:

% Basins domain limits:

basin_domain = [[130,155,-10,10]; ...   % WPAC
                [155,180,-10,10]];      % CPAC

for bi = 1:2
    
    box_lon = [basin_domain(bi,1), basin_domain(bi,2), basin_domain(bi,2), basin_domain(bi,1), basin_domain(bi,1)];
    box_lat = [basin_domain(bi,3), basin_domain(bi,3), basin_domain(bi,4), basin_domain(bi,4), basin_domain(bi,3)];
    
    f1box = plot(box_lon, box_lat,'LineWidth',1.2,'Color',[0.1,0.1,0.1],'LineStyle',':');
    
    hold on;

end

% ==============================================================================

%% Plot the Nino box:

% switch nino_type
%     
%     case 'Nino34'
%         
%         NINObox1_lon1 = 190;
%         NINObox1_lon2 = 240;
%         NINObox1_lat1 = -5;
%         NINObox1_lat2 = 5;
%         
%         NINO_box1_lon = [NINObox1_lon1, NINObox1_lon2, NINObox1_lon2, NINObox1_lon1, NINObox1_lon1];
%         NINO_box1_lat = [NINObox1_lat1, NINObox1_lat1, NINObox1_lat2, NINObox1_lat2, NINObox1_lat1];
%         
%         f51 = plot(NINO_box1_lon, NINO_box1_lat,'LineWidth',1.2,'Color','b','LineStyle','--');
%         
%         hold on;
% 
%     case 'Nino4'
%         
%         NINObox1_lon1 = 160;
%         NINObox1_lon2 = 210;
%         NINObox1_lat1 = -5;
%         NINObox1_lat2 = 5;
%         
%         NINO_box1_lon = [NINObox1_lon1, NINObox1_lon2, NINObox1_lon2, NINObox1_lon1, NINObox1_lon1];
%         NINO_box1_lat = [NINObox1_lat1, NINObox1_lat1, NINObox1_lat2, NINObox1_lat2, NINObox1_lat1];
%         
%         f51 = plot(NINO_box1_lon, NINO_box1_lat,'LineWidth',1.2,'Color','b','LineStyle','--');
%         
%         hold on;
%         
% end


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

leg1_label = {['\bf{Q2D var.' newline '(',nino_type,'=',num2str(NINO_phase_mean,2),')}']};%{['\bf{',freq_type{freq_id},', ',nino_type,'=',num2str(NINO_phase_mean,2),'}']};

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
cbu = text(1.5,-0.15,'(K^2)');
set(cbu,'Parent',cbu_axis)
set(cbu,'FontName','Helvetica','FontSize',axfont,'FontWeight','bold')

% ==============================================================================

disp([num2str(toc),' sec.'])

% ==============================================================================

%% Save Figure:
set(gcf,'Color',[1,1,1]);

figname = ['./IRBT_Var_Map_(',nino_type,'_',phase_type,')'];

% print(gf1,'-dpng','-r300',figname);
export_fig([figname,'.png'],'-r300')

