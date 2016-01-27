function [date, snow_depth, snow_depth_std, swegps, lat, lon, station_name ] = my_readgps(filename)
numheaderlines = 16;

fid=fopen(filename); 
% third line contains stuff like: 
% # p062    43.112383   238.909302  1350.7  / station Lat. Lon. Elev.(m)
a=fgetl(fid); 
a=fgetl(fid); 
a=fgetl(fid); 
fclose(fid) ; 

c = textscan(a, '%s %s %f %f %f %s %s %s %s %s'); 
station_name=c{2}; 
lat = c{3}; 
lon = c{4}; 
elev = c{5}; 

rows=csvread(filename, numheaderlines, 0) ; 
date=datenum(rows(:, 1:3)) ; 

snow_depth=rows(:, 5); 
snow_depth_std = rows(:, 6) ; 
swegps=rows(:, 7) ; 

 



