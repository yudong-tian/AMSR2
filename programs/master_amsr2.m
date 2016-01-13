% function master_amsr2(loopind, snorad)
%YDT cd ~/MATLAB
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

% fd_settings;
load('fd_settings')



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
 
for i = 15:length(non_ephm_snow)
    
%     if length(find(strcmp(non_ephm_snow{i}, list))) > 0
    % initialize AMSR2 snow depth structure
    AMSR = struct('station_name', [], 'date', [], 'swe', [], 'filename',[], 'scan_time', [], 'SD', [], 'lat', [], 'lon', [], 'hit', 0, 'qual', []);
    % read in snow data for current GPS station in station list. 
    % first check if file exists for current GPS station.
    %YDT file = strcat('~/MATLAB/GPS_stations/', non_ephm_snow{i}, '/', non_ephm_snow{i}, '_v1.csv')
    file = strcat('/discover/nobackup/projects/smos/GPS/', non_ephm_snow{i}, '_snow_v1.csv')
    proceed = 0;
        for m = 1:length(non_ephm_snow2)
    if strcmp(non_ephm_snow2{m}, non_ephm_snow{i});
        proceed = 1;
        break
    end
        end   
    
    if exist(file) == 2 && proceed;
    %% call readgps function to get snowfall, dates of snowfall, lat-lon
    % values and gps station name from the Pb0-H20 master excel file
    [gps.date, gps.SD, gps.SD_std, gps.swe, gps.lat, gps.lon, gps.station_name] = my_readgps(file);
    
    %% filter GPS station snow depth data for date range of interest after AMSR-2 launch
    
    % find gps station snow data after AMSR2 launch and before final date
    % in analysis
    index3 = find(gps.date >= datenum(Y_beg,M_beg,D_beg) & gps.date <= datenum(Y_end,M_end,D_end)); 
    gps_dates = gps.date(index3);
    SD = gps.SD(index3);
    
    % find gps station snow data larger than minimum snow depth threshold
    ind2 = find(SD >= SD_threshold);
    gps_dates = gps_dates(ind2);
    SD = SD(ind2);
    
   % YDT
    disp('Saving GPS data ...') 
    %% if there is no snow depth values larger than the threshold, save GPS 
    % station data in a mat file with the label of "no data"
    if isempty(gps_dates)
        % , num2str(Y), '_', num2str(M_beg), '_', num2str(M_end), '_no_data'
        save(strcat('/discover/nobackup/projects/smos/AMSR2/programs/GPS/', non_ephm_snow{i}, '_amsr2_no_data_', num2str(snorad)), 'gps'); 
    else
        % otherwise start process to find matching AMSR data
    
   % YDT
    disp('finding AMSR2 data  ...') 

    %convert gps longitude value from [0,360] to [-180,180]
    if gps.lon > 180
        gps.lon = gps.lon - 360;
    end
    
 
    %% find forest fraction value that corresponds to the gps station lat-lon values
%     gps.lat = 41.2258; 
%     gps.lon = -76.0462;
    [~,ilat] = min(abs(gps.lat - latffcat));
    [~,ilon] = min(abs(gps.lon - lonffcat));
    
    % take average of forest fraction data from a square area sized 7 km X 7 km 
    % to match AMSR2 resolution (7 X 12) km
    ffval = ffcat(end - ilat, ilon);
    % use forest fraction value to determine forest fraction % there
    if ffval > 0
        [~,latind] = min(abs(gps.lat - latease));
        [~,lonind] = min(abs(gps.lon - lonease));
        ffdata = double(ff{ffval}(lonind, latind))/100;
    elseif ffval == 0
        ffdata = 0;
    end

   % YDT
    disp('finding foreest density  ...') 
    
    %% find forest density value that corresponds to the gps station lat-lon values 
    for j = 1:length(tree_files)
    
    % find fd square that has gps lat-lon coordinates in its range
    check1 = gps.lat < vcf(j).bbox(4) && gps.lat > vcf(j).bbox(3);
    check2 = gps.lon < vcf(j).bbox(2) && gps.lon > vcf(j).bbox(1);
    
    % if GPS station location is within the current square, proceed here
    if check1 && check2
    A = double(vcf(j).A);
    % valid range is from 0-100 percent so zero out any higher values
    A(A > 100) = 0;
    fd = A;
    
    % get cloud cover values to make sure forest density data is not
    % corrupted
    A_cloud = double(vcf(j).A_cloud);
    
    % index the forest density square from the left most longitude value to the
    % right most longitude value with an increment found by dividing the
    % longitude span by the resolution of the forest density data in the
    % longitude direction 
    
    % for lat- lon range values, stop at (final value - increment) when 
    % indexing to match the length of the fd data
    lon_sep = (vcf(j).bbox(2) - vcf(j).bbox(1))/size(A,2);
    lonfd = vcf(j).bbox(1):lon_sep:(vcf(j).bbox(2)-lon_sep);
    
    % index the forest density square from the top latitude value to the
    % bottom latitude value with an increment found by dividing the
    % latitude span by the resolution of the forest density data in the
    % latitude direction 
    
    % increment is negative in latitude because fd lat values decrease 
    % down the matrix
    lat_sep = (vcf(j).bbox(4) - vcf(j).bbox(3))/size(A,1);
    latfd = vcf(j).bbox(4):-lat_sep:(vcf(j).bbox(3)+lat_sep);
    
    % find index of least lat and lon separation between GPS station
    % location and forest density lat lon vectors
    
    % this finds forest density value closest to the GPS station location
    [~,ilat] = min(abs(gps.lat - latfd));
    [~,ilon] = min(abs(gps.lon - lonfd));
    
    % take average of forest density data from a square area sized 7 km X 7 km 
    % to match AMSR2 resolution (7 X 12) km
    fd_avg = mean(mean(fd(ilat-fd_radius:ilat+fd_radius, ilon-fd_radius:ilon+fd_radius)));
    fd_avg = fd_avg/100; % convert to value from percentage
    
    % find the number of cloud cover pixels with nonzero values in the
    % AMSR2 footprint
    cloud_flag = find(A_cloud(ilat-fd_radius:ilat+fd_radius, ilon-fd_radius:ilon+fd_radius)>0);
    
    % if there are more than 50 pixels with cloud cover data, it is a safe
    % bet that cloud cover is hampering the forest density observations.
    % therefore, increase the forest density average value by 25% to
    % account for the cloud cover.
    if length(cloud_flag) > 50
        fd_avg = fd_avg * 1.25;
        if fd_avg > 1
            fd_avg = 1;
        end
    end
        % once forest density square for the GPS station location is found,
    % break out of loop searching for the fd square
    break
    end
    end
            %% find closest SNOTEL station to current GPS station
    
    d = zeros(length(Station_Name), 1);
    for m = 1:length(Station_Name)
        d(m) = 2.*r.*asin( sqrt( sind( (Latitude(m) - gps.lat)/2 ).^2 + cosd(gps.lat).* ...
               cosd(Latitude(m)).*sind((Longitude(m)-gps.lon)/2).^2 ));
    end
    
    % get SNOTEL snow depth if station is less than 10 km from GPS station
    [min_dist, ind_closest_snotel_station] = min(d);
    
    if min_dist < snorad
       %YDT
       disp('do snotel ... ') 

        stnid = lower(Stn_ID(ind_closest_snotel_station));
        stnname = Station_Name(ind_closest_snotel_station)
        %YDT keyboard
        % YDT type 'dbcont' to conditue ... funny 
        gpsdatevec = datevec(gps_dates(1));
        % SNOTEL data files are based on 'Water Year' which starts on
        % October 1 of the previous year. Therefore, pull the correct year's 
        % data file based on current GPS SD data point. If before Oct 1, 
        % use current year's data file and if after Oct 1, use next year's data file.
        if gpsdatevec(2)>= 10
            wateryear = gpsdatevec(1)+1;
        else
            wateryear = gpsdatevec(1);
        end
        if wateryear == 2013
        % create SNOTEL water year file name to read in
        stnfile = strcat('/discover/nobackup/projects/lis/STN_DATA/SNOTEL/QC_Daily/', state{i},'/',...
            'snotelproc_', stnid, '_wy', num2str(wateryear),'d.csv');
        
       %YDT
       disp(strcat('Reading SNOTEL QC_daily ', stnfile)) 
        
        [Year,Mo,Dy,HrMn,swe_accum] = importsnoindfile(stnfile{1});
        AMSR(1).snoteldist = min_dist;
        end
    end

        %% if there are GPS snow depth dates that meet the criteria,
        % look for AMSR2 snow depth data on the dates of the GPS station
        % measurements
       %YDT
       disp('Reading AMSR2  ...') 

        for n = 1:length(gps_dates)
            % Call function that scans AMSR2 half orbit swaths to find data when 
            % AMSR2 footprint includes GPS station location. Then record
            % the snow depth at that location.
            AMSR = findamsr2data(AMSR, gps, SD(n), gps_dates(n), ffdata, fd_avg);
                        
            % ***********for GPS stations with SNOTEL sites nearby
            % if the current GPS data point date changes the water year,
            % must pull in new water year SNOTEL data file
            gpsdatevec = datevec(gps_dates(n));
            if min_dist  < snorad 
            
%             if gpsdatevec(1) == (wateryear-1) 
%                 % do nothing
%             elseif  (gpsdatevec(1) == wateryear && gpsdatevec(2) > 10) || gpsdatevec(1) == (wateryear+1)
%                 % change to next water year file since GPS date has moved
%                 % past Oct 1st of next year
%                 wateryear = gpsdatevec(1)+1;
%                         % create SNOTEL water year file name to read in
%             stnfile = strcat('/discover/nobackup/projects/lis/STN_DATA/SNOTEL/QC_Daily/', state{i},'/',...
%             'snotelproc_', stnid, '_wy', num2str(wateryear),'d.csv');
%                         
%                         [Year,Mo,Dy,HrMn,swe_accum] = importsnoindfile(stnfile{1});
%             end
            
            
            % find exact day of SNOTEL data to correspond with GPS station SD data
            indmonth = find(gpsdatevec(2) == Mo);
            indday = find(gpsdatevec(3) == Dy);
            
            
            inddate = intersect(indmonth, indday);
            AMSR(end).swe = swe_accum(inddate)/100; % get SWE in meters
            end

        end
        % once all of the gps snow depth dates have been compared with
        % AMSR2 data, save data in .mat file
        save(strcat('/discover/nobackup/projects/smos/AMSR2/programs/GPS/', non_ephm_snow{i}, '_amsr2_', num2str(snorad)), 'AMSR');
       
       %YDT
       disp('Done  ... ') 

    end
    end
%     end
end
toc
