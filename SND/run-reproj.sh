
# reproject 1-day's worth of data

i=0 
for ifile in `ls 2012/12/GW1AM2_20121201*.h5`; do 
  hr=`printf "%02d" $i`
  ./reproj $ifile snd$hr.1gd4r
  let i=i+1
  #echo $hr
done 
  

