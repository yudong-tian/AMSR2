% function master_amsr2(loopind, snorad)
%YDT cd ~/MATLAB
disp('starting ...') 
loopind = 48;
snorad = 10;
% master script to process GPS station and AMSR2 raw brightness temperature data
% into snow depths using the Kelly et al snow depth conversion algorithm.
% This script puts all of the relevant data into MATLAB  workspace files
% (.mat) so that the SD_data_plotter function can then create slides for each GPS Sation.

% ******************************************************************************
% current method of converting lat-lon matrices from 89 GHz values to 36
% Ghz values is by averaging neighboring columns, e.g. matrices go from 
% size(lat89) = [a,b] to size(lat36) = [a,b/2], instead of using JAXA
% method which is much more computationally expensive. The simpler
% averaging method provided results that were very similar to the JAXA method.
% ******************************************************************************

% load calculations to find the forest fraction value for 
% lat-lon values of GPS station 
% load('ff_settings')
tic
ff_settings

% pull forest fraction data for each land cover type

ff = cell(1,17);
for i = 1:17
    if i < 10
        istr = strcat('0', num2str(i));
    else
        istr = num2str(i);
    end
    fname = strcat('FF/Mh.gl_g.sds01.v4.', istr,'.bin');
    fid = fopen(fname, 'r');
    n= 721;
    ff{i} = fread(fid, [2766,1171],'uint8=>uint8');
end
% open files that specify the lat/lon coordinates of the EASE-grid cells
% that the forest cover values correspond to
fid = fopen('FF/MHLONLSB');
lonease = fread(fid, [2766,1171],'int32')/1e5;
lonease = lonease(:,1);

fid = fopen('FF/MHLATLSB');
latease = fread(fid, [2766,1171],'int32')/1e5;
latease = latease(1,:)';

% load calculations to find the forest density value for 
% lat-lon values of GPS station 
%fd_settings;



%% first date of AMSR2 data, to be able to compare with GPS station data
Y_beg = 2012;
M_beg = 10;
D_beg = 1;

% last date of AMSR2 data
Y_end = 2015;
M_end = 5;
D_end = 1;

% read in the names, locations, elevations, and landcover types of the GPS stations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure to update with new GPS station snow depth data regularly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Reading GPS_stations ...') 

[num, txt, raw] = xlsread('GPS_stations/stations_new.xls');
non_ephm_snow = txt(2:end,1);
state = txt(2:end,2);


% min threshold of GPS derived snow value that must be there to warrant
% comparison with AMSR-2 data
SD_threshold = 0.00001; % meters

% which GPS stations you want to look at
% non_ephm_snow2 = {'ashl'};
% non_ephm_snow2 = {'nwot', 'p052', 'p041', 'p046', 'ac71', 'moil', 'p019', 'p023', 'p088', 'p350', 'p351', 'p682', 'ab33'};
% non_ephm_snow2 = {'p682'};
non_ephm_snow2 = {'nwot', 'moil', 'p019', 'p023', 'p088', 'p350', 'p351', 'p682', 'ab33'};
% list = {'ac61', 'ac78', 'ac09', 'ac23','ashl', ...
%                     'ac24', 'ac34', 'ab13', 'av06', 'av26', 'av38', ...
%                      'blw2', 'p413', 'p023', 'p019', 'p350', ...
%                     'p351','p455', 'p707', 'p676', 'p360', 'p682', 'p683', ...
%                         'p030', 'p101', 'rn86', 'p029', 'p150', 'p346', ...
%                     'sg27', 'p048', 'nwot',  'p052', 'p041', 'p046'};

% initialize GPS snow depth structure
gps = struct('date', [], 'SD', [], 'SD_std', [], 'lat', [], 'lon', [], 'station_name', []);

% import SNOTEL information
    [~,Station_Name,Stn_ID,~,Latitude,Longitude,~] = importsnotelfile('SNOTEL_ALL_list.csv');
    r = 6378;
 
