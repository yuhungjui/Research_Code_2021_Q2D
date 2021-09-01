% clear;close all;clc;
% ==============================================================================
%
% Create 48-colored colormaps for SST (Unit:deg-C) according to 
% http://catalog.eol.ucar.edu/cgi-bin/dynamo/loop.pl?category=ops&platform=CSU_SSTWIND&prod=wind_over_sst&start=2011101502&end=2011101514
%
% And 11-colored colormaps for SST (Unit:deg-C) according to 
% https://blogs.mathworks.com/steve/2015/01/20/divergent-colormaps/
% 
% ==============================================================================
%% SST (48 colors):
colormap_SST_48(:,:,1) = ...
                       [  45,   0,  43; ...
                          68,   0,  72; ...
                          79,   0,  95; ...
                          86,   0, 122; ...
                          87,   0, 145; ...
                          84,   0, 168; ...
                          71,   0, 195; ...
                          58,   0, 218; ...
                          33,   0, 250; ...
                           4,   0, 255; ...
                           0,  25, 255; ...
                           0,  51, 255; ...
                           0,  84, 255; ...
                           0, 110, 255; ...
                           0, 135, 255; ...
                           0, 165, 255; ...
                           0, 195, 255; ...
                           0, 225, 255; ...
                           0, 255, 255; ...
                           0, 255, 220; ...
                           0, 255, 195; ...
                           0, 255, 170; ...
                           0, 255, 135; ...
                           0, 255, 110; ...
                           7, 240,  88; ...
                          14, 226,  67; ...
                          21, 211,  46; ...
                          28, 197,  25; ...
                          37, 180,   0; ...
                          80, 195,   0; ...
                         124, 210,   0; ...
                         167, 225,   0; ...
                         211, 240,   0; ...
                         255, 255,   0; ...
                         255, 215,  17; ...
                         255, 175,  35; ...
                         248, 123,  32; ...
                         236,  61,  16; ...
                         226,   8,   8; ...
                         231,  50,  50; ...
                         237,  92,  92; ...
                         243, 134, 134; ...
                         249, 176, 176; ...
                         255, 218, 218; ...
                         235, 181, 199; ...
                         216, 144, 181; ...
                         196, 106, 162; ...
                         177,  70, 144; ...
                       ]./255;

% ==============================================================================
%% SST (11 colors):
colormap_SST_11(:,:,1) = ...
                       [  94,  79, 162; ...
                          50, 136, 189; ...
                         102, 194, 165; ...
                         171, 221, 164; ...
                         230, 245, 152; ...
                         255, 255, 191; ...
                         254, 224, 139; ...
                         253, 174,  97; ...
                         244, 109,  67; ...
                         213,  62,  79; ...
                         158,   1,  66; ...
                       ]./255;
% ==============================================================================