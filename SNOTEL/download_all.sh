

tail --lines=+2 SNOTEL_ALL_list.csv | while read line; do 

state=`echo $line | awk -F',' '{print $1}' |sed 's/ //g' `
stn_num=`echo $line | awk -F',' '{print $4}' |sed 's/ //g'`

echo Downloading $state $stn_num
 wget -O data_2012-10-01_2016-01-20/${state}_${stn_num}.csv \
http://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/daily/${stn_num}:${state}:SNTL\|id=%22%22\|name/2012-10-01,2016-01-20/WTEQ::value,SNWD::value,PREC::value,TOBS::value,TMAX::value,TMIN::value,TAVG::value

sleep 10
done



