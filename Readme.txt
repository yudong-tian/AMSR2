
2/1/2016

combine_SNOTEL_GPS.F90: combine SNOTEL and GPS data and project to 0.25-deg lat/lon grid. 
See subdirectories below for the input data. 


GPS data: 

GPS/format_gps.pl: reformat raw csv to new csv data for Fortran to process

GPS/convert_GPS.F90: convert the formatted data to binary, as described in GPS/gps-0.25.ctl. 


SNOTEL data:

Similar programs to GPS: 

SNOTEL/format_snotel.pl

SNOTEL/read_snotel.F90


AMSR2 SND data: 

SND/reproj.F90: reproject L2 data to 0.25-deg lat/lon   
SND/to-daily-0.25.F90: aggregate to daily




