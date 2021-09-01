clear;close all;clc;

addpath(genpath('/Users/yuhungjui/Dropbox/Work/MATLAB_TOOLS/'));

tic;

% ==============================================================================
% 
% Calculate the Fourier components of two-day disturbances (1.6-3 days) for
% IR Brightness Temperature fro every month from 1998 through 2018. 
% 
% The spectral variance is calculated at every grid point 
% over the tropics (40S - 40N), in order to see where the two-day disturbances
% prevail throughout the decade.
% 
% The monthly mean & monthly variance are calculated.
% 
% The Lanczos Band-pass Filter was used.
% See https://www.mathworks.com/matlabcentral/fileexchange/14041-lanczosfilter-m
% 
% Temporal resolution: 3 hourly.
% Spatial resolution: interpolated to 0.25-deg.
% 
% ==============================================================================

%% Set parameters:

% data_path = '/Volumes/GoogleDrive/My Drive/Backup_GoogleDriveNTU/Data/DATA_NOAA_GRIDSAT_B1_IR/';
% data_path = '/Volumes/DM_4T/Data/DATA_NOAA_GRIDSAT_B1_IR/';
data_path = '/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/';

% tmp_path = '/Users/yuhungjui/Downloads/';

output_path_1 = '/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_mean_25km_mat/';

output_path_2 = '/Users/yuhungjui/GoogleDrive_PhD/Data/DATA_NOAA_GRIDSAT_B1_IR_25km_mat/monthly_var_distribution_25km_mat/';

%% Set time:

year_no = 2010:2018;

mon_no = {'01','02','03','04','05','06','07','08','09','10','11','12'};

%% Frequency bands:

fq1_range_ini = 1./(0.9*24);
fq1_range_end = 1./(1.25*24);

fq2_range_ini = 1./(1.55*24);
fq2_range_end = 1./(3*24);


% ==============================================================================
%% Calculation:

for yri = 1:length(year_no)
    
    disp(year_no(yri));
    
    for mni = 1:length(mon_no)
        
        disp(month(datetime(year_no(yri),mni,1),'shortname'));
        
        %% Set time frame:
        
        date_dur = datetime(year_no(yri),mni,1,0,0,0): ...
                   hours(3): ...
                   datetime(year_no(yri),mni,1,0,0,0)+calmonths(1);
        date_dur = date_dur(1:end-1);

        %% Load data:
        % Preallocating the array!
        
        load_IRBT = nan(1441,321,length(date_dur));

        pb1 = CmdLineProgressBar('... start loading ... ');
        
        for ti = 1:length(date_dur)
            
            load([data_path,num2str(year_no(yri)),'/',mon_no{mni},'/GRIDSAT_B1_IRBT_',datestr(date_dur(ti),'yyyymmddHH'),'_25km.mat']); 
            
            % IRWIN_CDR = ncread([data_path,num2str(year_no(yri)),'/GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'],variable_name); % K
            % LON = ncread([data_path,num2str(year_no(yri)),'/GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'],'lon');
            % LAT = ncread([data_path,num2str(year_no(yri)),'/GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'],'lat');
            
            % copyfile([data_path,num2str(year_no(yri)),'/GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'],tmp_path)
            % IRWIN_CDR = ncread([tmp_path,'/GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'],variable_name); % K
            % LON = ncread([tmp_path,'/GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'],'lon');
            % LAT = ncread([tmp_path,'/GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'],'lat');
            % delete([tmp_path,'/GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'])
            
            % FILE_NAME = [tmp_path,'GRIDSAT-B1.',datestr(date_dur(ti),'yyyy.mm.dd.HH'),'.v02r01.nc'];
            % Read_NOAA_GRIDSAT_B1_IR;
            
            %% Arrange data:
            
            load_IRBT(:,:,ti) = IRWIN_CDR(:,:);
            load_LON = LON;
            load_LAT = LAT;
            a
            clear IRWIN_CDR LON LAT
        
            pb1.print(ti,length(date_dur));
            
        end
        
        disp('... finish loading ...');
        
        %% For monthly mean: ===================================================
        
        GRIDSAT_IRBT.irbt_mnly_mean = nanmean(load_IRBT,3);
        GRIDSAT_IRBT.lon = load_LON;
        GRIDSAT_IRBT.lat = load_LAT;
        
        save([output_path_1,num2str(year_no(yri)),'/GRIDSAT_IRBT_TROPICS_mean_',datestr(date_dur(1),'yyyy_mm'),'.mat'],'GRIDSAT_IRBT','-v7.3');
        
        clear GRIDSAT_IRBT

        disp('... monthly mean finished ...')
        
        %% For variance distribution: ==========================================
        
        GRIDSAT_IRBT_VAR.total = nanvar(load_IRBT,0,3);
        
        GRIDSAT_IRBT_VAR.lon = load_LON;
        GRIDSAT_IRBT_VAR.lat = load_LAT;
        
        % dc & q2d:
        % Preallocating the array!
        
        data_1_filtered = nan(size(load_IRBT));
        data_2_filtered = nan(size(load_IRBT));
        
        pb2 = CmdLineProgressBar('... var. cal. ... ');
        % disp('... var. cal. ... ');
        
        % For speeding up, run multiple calculations at the same time.
        
        spup_res = 20;
        
        % tic;
        for gidi = 1:numel(load_LON)
            % tic;
            for gidj = 1:spup_res:numel(load_LAT)-1 % total length: 321
                
                %% Calculate the data trend & detrended timeseries:
                
                data_TimeSeries_sp1     = permute(load_IRBT(gidi,gidj,:),[1,3,2]);
                data_TimeSeries_sp2     = permute(load_IRBT(gidi,gidj+1,:),[1,3,2]);
                data_TimeSeries_sp3     = permute(load_IRBT(gidi,gidj+2,:),[1,3,2]);
                data_TimeSeries_sp4     = permute(load_IRBT(gidi,gidj+3,:),[1,3,2]);
                data_TimeSeries_sp5     = permute(load_IRBT(gidi,gidj+4,:),[1,3,2]);
                data_TimeSeries_sp6     = permute(load_IRBT(gidi,gidj+5,:),[1,3,2]);
                data_TimeSeries_sp7     = permute(load_IRBT(gidi,gidj+6,:),[1,3,2]);
                data_TimeSeries_sp8     = permute(load_IRBT(gidi,gidj+7,:),[1,3,2]);
                data_TimeSeries_sp9     = permute(load_IRBT(gidi,gidj+8,:),[1,3,2]);
                data_TimeSeries_sp10    = permute(load_IRBT(gidi,gidj+9,:),[1,3,2]);
                data_TimeSeries_sp11    = permute(load_IRBT(gidi,gidj+10,:),[1,3,2]);
                data_TimeSeries_sp12    = permute(load_IRBT(gidi,gidj+11,:),[1,3,2]);
                data_TimeSeries_sp13    = permute(load_IRBT(gidi,gidj+12,:),[1,3,2]);
                data_TimeSeries_sp14    = permute(load_IRBT(gidi,gidj+13,:),[1,3,2]);
                data_TimeSeries_sp15    = permute(load_IRBT(gidi,gidj+14,:),[1,3,2]);
                data_TimeSeries_sp16    = permute(load_IRBT(gidi,gidj+15,:),[1,3,2]);
                data_TimeSeries_sp17    = permute(load_IRBT(gidi,gidj+16,:),[1,3,2]);
                data_TimeSeries_sp18    = permute(load_IRBT(gidi,gidj+17,:),[1,3,2]);
                data_TimeSeries_sp19    = permute(load_IRBT(gidi,gidj+18,:),[1,3,2]);
                data_TimeSeries_sp20    = permute(load_IRBT(gidi,gidj+19,:),[1,3,2]);
                
                
                %% Apply the Lanczos Filter & Calculate variance:
                
                % dc:
                
                tmp_data_filtered(1,1,:)    = lanczosfilter(data_TimeSeries_sp1,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp1,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,2,:)    = lanczosfilter(data_TimeSeries_sp2,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp2,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,3,:)    = lanczosfilter(data_TimeSeries_sp3,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp3,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,4,:)    = lanczosfilter(data_TimeSeries_sp4,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp4,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,5,:)    = lanczosfilter(data_TimeSeries_sp5,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp5,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,6,:)    = lanczosfilter(data_TimeSeries_sp6,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp6,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,7,:)    = lanczosfilter(data_TimeSeries_sp7,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp7,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,8,:)    = lanczosfilter(data_TimeSeries_sp8,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp8,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,9,:)    = lanczosfilter(data_TimeSeries_sp9,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp9,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,10,:)   = lanczosfilter(data_TimeSeries_sp10,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp10,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,11,:)   = lanczosfilter(data_TimeSeries_sp11,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp11,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,12,:)   = lanczosfilter(data_TimeSeries_sp12,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp12,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,13,:)   = lanczosfilter(data_TimeSeries_sp13,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp13,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,14,:)   = lanczosfilter(data_TimeSeries_sp14,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp14,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,15,:)   = lanczosfilter(data_TimeSeries_sp15,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp15,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,16,:)   = lanczosfilter(data_TimeSeries_sp16,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp16,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,17,:)   = lanczosfilter(data_TimeSeries_sp17,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp17,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,18,:)   = lanczosfilter(data_TimeSeries_sp18,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp18,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,19,:)   = lanczosfilter(data_TimeSeries_sp19,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp19,3,fq1_range_end,[],'low');
                tmp_data_filtered(1,20,:)   = lanczosfilter(data_TimeSeries_sp20,3,fq1_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp20,3,fq1_range_end,[],'low');
                
                data_1_filtered(gidi,gidj:gidj+spup_res-1,:) = tmp_data_filtered; 
                clear tmp_data_filtered
                
                % q2d:
                
                tmp_data_filtered(1,1,:)    = lanczosfilter(data_TimeSeries_sp1,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp1,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,2,:)    = lanczosfilter(data_TimeSeries_sp2,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp2,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,3,:)    = lanczosfilter(data_TimeSeries_sp3,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp3,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,4,:)    = lanczosfilter(data_TimeSeries_sp4,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp4,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,5,:)    = lanczosfilter(data_TimeSeries_sp5,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp5,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,6,:)    = lanczosfilter(data_TimeSeries_sp6,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp6,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,7,:)    = lanczosfilter(data_TimeSeries_sp7,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp7,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,8,:)    = lanczosfilter(data_TimeSeries_sp8,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp8,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,9,:)    = lanczosfilter(data_TimeSeries_sp9,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp9,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,10,:)   = lanczosfilter(data_TimeSeries_sp10,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp10,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,11,:)   = lanczosfilter(data_TimeSeries_sp11,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp11,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,12,:)   = lanczosfilter(data_TimeSeries_sp12,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp12,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,13,:)   = lanczosfilter(data_TimeSeries_sp13,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp13,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,14,:)   = lanczosfilter(data_TimeSeries_sp14,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp14,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,15,:)   = lanczosfilter(data_TimeSeries_sp15,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp15,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,16,:)   = lanczosfilter(data_TimeSeries_sp16,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp16,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,17,:)   = lanczosfilter(data_TimeSeries_sp17,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp17,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,18,:)   = lanczosfilter(data_TimeSeries_sp18,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp18,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,19,:)   = lanczosfilter(data_TimeSeries_sp19,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp19,3,fq2_range_end,[],'low');
                tmp_data_filtered(1,20,:)   = lanczosfilter(data_TimeSeries_sp20,3,fq2_range_ini,[],'low') - lanczosfilter(data_TimeSeries_sp20,3,fq2_range_end,[],'low');
                
                data_2_filtered(gidi,gidj:gidj+spup_res-1,:) = tmp_data_filtered; 
                clear tmp_data_filtered
                
                clear data_TimeSeries_*
                
            end
            
            % For the end data point:
            data_TimeSeries_sp_end = permute(load_IRBT(gidi,321,:),[1,3,2]);
            tmp_data_filtered(1,1,:) = lanczosfilter(data_TimeSeries_sp_end,3,fq1_range_ini,[],'low') - ...
                                       lanczosfilter(data_TimeSeries_sp_end,3,fq1_range_end,[],'low');
            data_1_filtered(gidi,321,:) = tmp_data_filtered; 
            clear tmp_data_filtered
            tmp_data_filtered(1,1,:) = lanczosfilter(data_TimeSeries_sp_end,3,fq2_range_ini,[],'low') - ...
                                       lanczosfilter(data_TimeSeries_sp_end,3,fq2_range_end,[],'low');
            data_2_filtered(gidi,321,:) = tmp_data_filtered; 
            clear data_TimeSeries_sp_end tmp_data_filtered    
            
            pb2.print(gidi,numel(load_LON));
            % toc;
        end
        % toc;
        
        GRIDSAT_IRBT_VAR.dc = var(data_1_filtered,0,3);
        GRIDSAT_IRBT_VAR.q2d = var(data_2_filtered,0,3);
        
        clear data_1_filtered data_2_filtered
        
        save([output_path_2,num2str(year_no(yri)),'/GRIDSAT_IRBT_TROPICS_var_',datestr(date_dur(1),'yyyy_mm'),'.mat'],'GRIDSAT_IRBT_VAR','-v7.3');
        
        clear GRIDSAT_IRBT_VAR

        disp('... variance distribution finished ...')
        
        %% Clearing:
        
        clear load_*
        clear date_dur
        
    end
    
    disp([num2str(year_no(yri)),' done.']);
    
end

% ==============================================================================

%% Run Time Output

time_cost = toc;

disp([num2str(time_cost),' sec.']);
disp([num2str(time_cost./60),' min']);
disp([num2str(time_cost./3600),' hours']);
disp([num2str(time_cost./(3600*24)),' days']);
