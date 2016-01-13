function [date, snow_depth, snow_depth_std, swegps, lat, lon, station_name ] = readgps(filename)
numheaderlines = 6;

rawdata = importdata(filename, ',', numheaderlines);

varnamessplit = regexp(  rawdata.textdata{numheaderlines}, ',\s*', 'split');
for i = 1:size(rawdata.data, 2)
    varnametokens = regexp( varnamessplit{i+1}, '([^\s\(]*)\s?(\(.*\))?', 'tokens');
    varname = varnametokens{1}{1};
    eval([ 'parseddata.' genvarname(varname, who) '.data = rawdata.data(:,' num2str(i) ');']);
    if ~isempty(varnametokens{1}{2})
        eval([ 'parseddata.' genvarname(varname, who) '.metadata = varnametokens{1}{2};']);
    else
        
        eval([ 'parseddata.' genvarname(varname, who) '.metadata = '''';']);
    
    end
end

datestrings = rawdata.textdata(numheaderlines+1:end);
date = datenum(datestrings, 'yyyy-mm-ddTHH:MM:SS');
station_name = rawdata.textdata{3};
station_name = station_name(3:end);

% use regular expressions to extract lat and lon values from textdata array
lat_lon_str = rawdata.textdata{4};
vector = '\S*\s*';
lat_lon = regexp(lat_lon_str, vector, 'match');
lat = str2double(lat_lon{2});
lon = str2double(lat_lon{3});

% get GPS snow depth and standard deviation values
gpssd = parseddata.snow_depth.data;
gpssdstd = parseddata.snow_depth_std.data;
swe = parseddata.SWE.data;


%get rid of the nans
swegps = swe(~isnan(swe));
snow_depth = gpssd(~isnan(gpssd));
snow_depth_std = gpssdstd(~isnan(gpssdstd));
date = date(~isnan(gpssd));