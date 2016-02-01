#!/usr/bin/perl
# $Id: format_snotel.pl,v 1.3 2013/06/06 21:53:52 ytian Exp ytian $
# This program reads snotel station data and insert lat/lon values to each line 
# grid: (30.125N ~ 89.875N), (-179.875 ~ - 60.125) 
#  nr = 240, nc = 480

use File::Basename; 

$minlines=1215;  # minimum number of lines a snotel file has to have to be valid  

$type=1;   # 1: SNOTEL; 100: GPS

if ( $#ARGV != 0 ) {
 print "usage: $0 <filelist> \n"; 
 exit;
}

$filelist = $ARGV[0]; 

%lats = (); 
%lons = (); 
%elev = ();   # station elevation, converted to m from ft. 

# get and save the stations' lat/lon 
 open(SLL, ">station-latlon-elev.txt") or die "Can not save station file: $!\n";
 open(DATA, "</home/ytian/proj-disk/STN_DATA/SNOTEL/QC_Daily/SNOTEL_ALL_list.csv") 
      or die "Can not open station file: $!\n";
 @lines = <DATA>;
 close(DATA);
 foreach $line (@lines) {
   chomp $line;
   unless ($line =~ /^#/ or !$line) {
     ($state, $stn_name, $stn_ID, $stn_num, $lat, $lon, $elev_ft) =  split /,/, $line; 
     $stn_id = "${state}_${stn_num}"; 
     $stn_id =~ s/\s+//g; 
     $lats{$stn_id} = $lat; 
     $lons{$stn_id} = $lon; 
     $elev{$stn_id} = $elev_ft * 0.3048; 
     print SLL ($stn_id, $lats{$stn_id}, $lons{$stn_id}, $elev{$stn_id}, "\n"); 
   }

 } # end of foreach
 close(SLL); 

 open(FILES, "<$filelist") or die "can not open filelist: $!\n"; 
 @files = <FILES>;
 close(FILES);
 foreach $file (@files) {
   chomp $file;
   # typical file name: data_2012-10-01_2016-01-20/WY_806.csv
   $stn_id=basename($file); 
   $bfile=basename($file); 
   $stn_id =~ s/.csv//g; 
   $lat0=$lats{$stn_id}; 
   $lon0=$lons{$stn_id}; 
   $elev0=$elev{$stn_id}; 
   print "Station: $stn_id  lat=$lat0 lon=$lon0 elev=$elev0\n"; 
   open(DATA, "<$file") or die "can't open data file: $!\n"; 
   @data = <DATA>; 
   close(DATA); 
   $nlines = @data; 

   if ($nlines < $minlines) { 
      print "Skipping $file ... only has $nlines lines \n"; 
      next; 
   } 
      
   open(ODATA, ">SNOTEL_reformatted/$bfile") or die "can't open output data file: $!\n"; 
   foreach $line (@data) { 
     chomp $line; 
     ($ymd, $swe, $snd, $ppt_daily, $tmp, $tmp_max, $tmp_min, $tmp_avg) 
       = split /,/, $line; 
     if ($ymd =~ /^[12][0-9]{3}-[0-9]{2}-[0-9]{2}$/) {
         $swe = $swe * 2.54;  # inch to cm
         $snd = $snd * 2.54; 
         ($yy, $mm, $dd) = split /-/, $ymd; 
         print ODATA "$lats{$stn_id} $lons{$stn_id} $elev{$stn_id} $yy $mm $dd $snd $swe $type\n"; 
     } else { 
       print "Skiping $line\n"; 
     }
   }
   close(ODATA); 
 }

