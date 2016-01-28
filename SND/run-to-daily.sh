
# reproject 1-day's worth of data

t0="Jul 3 2012"   # starting time: 0Z
t1="Dec 31 2015"   # end time: 0Z

sec0=`date -u -d "$t0" +%s`
sec1=`date -u -d "$t1" +%s`
let days=(sec1-sec0)/86400

for day in `seq 0 $days`; do
  tx=`date -u -d "$t0 $day day"`  
  cyr=`date -u -d "$tx" +%Y`
  cmn=`date -u -d "$tx" +%m`
  cdy=`date -u -d "$tx" +%d`

  echo Processing $cyr$cmn$cdy
  ./to-daily-0.25 $cyr/$cmn/$cyr$cmn$cdy.2gd4r $cyr/$cmn/GW1AM2_$cyr$cmn${cdy}*.h5 

done
  

