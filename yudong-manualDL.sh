#!/usr/local/bin/bash

#year=`date --date='1 day ago' +%Y`
#month=`date --date='1 day ago' +%m`
#yesterday=`date --date='2 day ago' +%d`


cd /discover/nobackup/projects/smos/AMSR2/

for y in 2015
do
mkdir -p $y
cd $y	


for m in 05 06 07 08 09 10 11 12; do 
mkdir -p $m
cd $m
# id and passwd
#id_host="edward.j.kim@nasa.gov@gcom-w1.jaxa.jp"
id_host="yudong.tian@nasa.gov@gcom-w1.jaxa.jp"
pass="gsfc2014"

# auto login
expect -c "
spawn sftp -oPort=2051 ${id_host}
#expect \"Connecting to gcom-w1.jaxa.jp...\n\"
expect \"${id_host}'s password:\"
send \"${pass}\r\"
expect \"sftp>\"
send \"get AMSR2/${y}/${y}.${m}/L1/L1B/2/GW1AM2_${y}${m}* \r\"
set timeout 8000
expect \"sftp>\"
send \"exit \r\"

"

cd ..
done
done
cd /discover/nobackup/projects/smos/AMSR2

