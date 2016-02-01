#!/usr/bin/perl
# $Id: format_snotel.pl,v 1.3 2013/06/06 21:53:52 ytian Exp ytian $
# This program reads GPS station data and insert lat/lon values to each line 
# Output fields: 
# lat     lon      elev(m) yyyy  mm dd snd(m) swe(m) type
# 41.817  -116.100 2133.6 2012   10 23 0.0762 0.0127  2


sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

$type=100;   # 1: SNOTEL; 100: GPS
# get GPS file list 
$dir='data_upto_2016_01_26'; 
opendir(DIR, $dir) or die $!; 
 @files = readdir(DIR); 
closedir(DIR); 

 foreach $file (@files) {
   chomp $file;
   next unless ($file =~ m/.csv$/); # skip non-csv files 
   open(DATA, "<$dir/$file") or die "can't open data file: $!\n"; 
   @data = <DATA>; 
   close(DATA); 
   $nlines = @data; 
   # get station id, lat, lon, elev from 3rd line
   ($hash, $stn_id, $lat, $lon, $elev, $text) = split /\s+/, $data[2], 6; 
   if ($lon > 180.0 ) { $lon = $lon - 360.0;  }  # lon in -180~180
   print "reading $dir/$file, id=$stn_id, lat=$lat, lon=$lon, elev=$elev\n"; 
      
   open(ODATA, ">GPS_reformatted/$file") or die "can't open output data file: $!\n"; 
   foreach $line (@data) { 
     chomp $line; 
     next if ($line =~ m/^#/); # skip comment 
     ($yy, $mm, $dd, $doy, $snd, $snd_err, $swe, $swe_err, $fracy) 
       = split /,/, $line, 9; 
     print "$line\n"; 

      if (!trim($swe) || $swe == -99 || $swe =~ /NaN/) { 
          $swe= -9999.0; 
      } else {   
          $swe= $swe*100.0; # m to cm
      } 

      if (!trim($snd) || $snd == -99 || $snd =~ /NaN/) { 
         $snd= -9999.0; 
      } else { 
         $snd= $snd*100.0;  # m to cm   
      }

     print "swe=$swe  snd=$snd\n"; 
         print ODATA "$lat $lon $elev $yy $mm $dd $snd $swe $type\n"; 
   }
   close(ODATA); 
 }

