#!/usr/bin/perl
# $Id: plot_snotel_area.pl,v 1.3 2013/06/07 18:16:21 ytian Exp ytian $
# This program outputs grads script to plot snotel station data within a given area

use File::Basename; 

if ( $#ARGV != 4 ) {
 print "usage: $0 <lat1> <lat2> <lon1> <lon2> <area_name> \n"; 
 exit;
}

$lat1 = $ARGV[0]; 
$lat2 = $ARGV[1]; 
$lon1 = $ARGV[2]; 
$lon2 = $ARGV[3]; 
$aname = $ARGV[4]; 

$gcom=<<EOL;
*generated with:
* $0 $lat1 $lat2 $lon1 $lon2 
open snotel-0.25.ctl
*open swe-0.25.ctl
open filtered-swe-0.25.ctl
set time 1nov2009 1feb2010
set grads off
set datawarn off
set vrange 0 500
EOL

# get and save the stations lat/lon 
 open(DATA, "</home/ytian/proj-disk/STN_DATA/SNOTEL/QC_Daily/SNOTEL_ALL_list.csv") 
      or die "Can not open station file: $!\n";
 @lines = <DATA>;
 close(DATA);

 foreach $line (@lines) {
   chomp $line;
   unless ($line =~ /^#/ or !$line) {
     ($state, $stn_name, $stn_ID, $stn_num, $lat, $lon, $elev_ft) =  split /,/, $line; 
     $stn_id = lc($stn_ID); 
     $stn_id =~ s/\s+//gi; 
     if ($lat >= $lat1 && $lat <= $lat2 && $lon >= $lon1 && $lon <= $lon2) {
    $tmp=<<EOF;
*$stn_id ($lat, $lon)
set lat $lat
set lon $lon
set ccolor 1 
set cmark 0 
d swe
set ccolor 2
set cmark 0 
d swe.2
draw title lat($lat1, $lat2) lon($lon1, $lon2)
draw ylab SWE(mm)

EOF

 $gcom="$gcom\n$tmp"; 
     } # end if 
   } # unless 

 } # end of foreach
$last=<<EOD; 
* click grads window to quit 
q pos
gxyat -x 1400 -y 1000 SNOTEL_vs_AE/$aname.png 
EOD
$gcom="$gcom $last"; 

system("grads -l << $gcom");  




