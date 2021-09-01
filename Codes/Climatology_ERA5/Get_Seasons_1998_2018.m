% ==============================================================================
% 
% Output seasons (MAM, JJA, SON, DJF) time frames from 1998 MAM to 2018 SON.
% 
% ==============================================================================

%% Set seasons date:

season_dur(:,1) = [datetime(1998,3,1):calmonths(3):datetime(2018,9,1)]';
season_dur(:,2) = [datetime(1998,4,1):calmonths(3):datetime(2018,10,1)]';
season_dur(:,3) = [datetime(1998,5,1):calmonths(3):datetime(2018,11,1)]';

% ==============================================================================

%% Set seasons names:

for si = 1:length(season_dur)
    
    season_dur_name{si,:} = [datestr(season_dur(si,1),'yyyy'),'_',datestr(season_dur(si,1),'m'),datestr(season_dur(si,2),'m'),datestr(season_dur(si,3),'m')];
    
end

% ==============================================================================
