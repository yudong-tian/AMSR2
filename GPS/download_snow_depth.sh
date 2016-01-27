
#URL sample
#http://xenon.colorado.edu/portal/data/yfb1/csv/yfb1_snow_v1.csv

stations=`tail -n +2 Stations.csv |awk -F',' '{print $1}' |tr -d '"'`

for station in $stations; do 
  echo Downloading $station 
  wget -O data_upto_2016_01_26/${station}_snow_v1.csv http://xenon.colorado.edu/portal/data/$station/csv/${station}_snow_v1.csv
 
done

