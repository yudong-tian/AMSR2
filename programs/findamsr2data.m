function AMSR = findamsr2data(AMSR, gps, snow_depth, gps_date, ff, fd)
r = 6372.8; %km

% use current gps snow depth date to find AMSR2 data for that date
[Y, mm, D] = datevec(gps_date);

%% put date in proper string format to access AMSR2 half orbit files
        if mm < 10
            mm_str = num2str(mm); % for single value months, add leading zero
            mm_str = strcat('0', mm_str);
        elseif mm > 12
            mm_str = strcat('0', num2str(mm-12));
        else
            mm_str = num2str(mm); % should be in format mm
        end
         if D < 10
            D_str = num2str(D); % for single value months, add leading zero
            D_str = strcat('0', D_str);
        else
            D_str = num2str(D); % should be in format DD
         end
        
filename = strcat('/discover/nobackup/projects/smos/AMSR2/', num2str(Y), '/', mm_str, '/GW1AM2_', ...
            num2str(Y), mm_str, D_str, '*.h5');
tb_files = dir(filename);

%% iterate through all AMSR2 files for that day until AMSR2 footprint covers GPS station
    
for p = 1:length(tb_files)
        hour = str2double(tb_files(p).name(16:19));
        % only look for footprint coverage between 0600 and 1800 UTC to get
        % first flyover of GPS station on that date
        if hour > 600
            if hour > 1800
                break
            end
            % get filename for individual half orbit data file
        filename = strcat('/discover/nobackup/projects/smos/AMSR2/',  num2str(Y), '/', mm_str, '/', tb_files(p).name);
        
         % call function to return AMSR2 lat-lon matrices for a given half orbit
        [lat, lon] = latlon_amsr2(filename);
        
        % use haversine formula to determine closest AMSR-2 lat-lon point to GPS station location
        d = 2.*r.*asin( sqrt( sind( (gps.lat - lat)/2 ).^2 + cosd(lat).* ...
            cosd(gps.lat).*sind((gps.lon-lon)/2).^2 ));
        
        % find minimum distance to see if AMSR2 flies over the GPS station
        % on this half-orbit
        min_d = min(min(d));
        
        % find index of closest AMSR2 lat-lon point
        [row, col] = find(min_d==d);
        
        % if less than 10 km from gps station lat-lon at closest approach,
        % this half-orbit file has fly over of GPS station so record snow depth 
        if min_d < 10  
            
            % update count of AMSR2 snow depth values found for each GPS
            % snow depth day for entire list of GPS snow depth data
            AMSR(1).hit = AMSR(1).hit + 1;
            
            % call snow depth calculation function to get AMSR2 snow depth
            % value at GPS station location (in meters)
            [AMSR(AMSR(1).hit).SD AMSR(AMSR(1).hit).qual] = SDcalc_amsr2(filename, ff, fd, row, col);
            % record other information about the fly over for later processing
            AMSR(AMSR(1).hit).station_name = gps.station_name;
            AMSR(AMSR(1).hit).date = gps_date;
            AMSR(AMSR(1).hit).filename = filename;
            AMSR(AMSR(1).hit).lat = lat(row, col);
            AMSR(AMSR(1).hit).lon = lon(row, col);
            AMSR(AMSR(1).hit).d = min_d;
            AMSR(AMSR(1).hit).gps_lat = gps.lat;
            AMSR(AMSR(1).hit).gps_lon = gps.lon;
            AMSR(AMSR(1).hit).gps_SD = snow_depth;
            
            % once the overnight pass of AMSR2 data is found, break out of for-loop
            % processing entire day of data
            break
        end

        end
     
end