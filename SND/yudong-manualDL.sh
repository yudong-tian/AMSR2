#!/usr/local/bin/bash

#year=`date --date='1 day ago' +%Y`
#month=`date --date='1 day ago' +%m`
#yesterday=`date --date='2 day ago' +%d`


path=/discover/nobackup/projects/smos/AMSR2/SND

# for y in 2012; do
#for y in 2013 2014 2015; do
#for y in 2013; do
#for y in 2014; do
for y in 2015; do
  #for m in 01 02 03 04 05 06 07 08 09 10 11 12; do 
  #for m in 07 08 09 10 11 12; do 
  for m in 01 02 03; do 
   mkdir -p $path/$y/$m
   cd $path/$y/$m
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
send \"get AMSR2/${y}/${y}.${m}/L2/SND/2/GW1AM2_${y}${m}* \r\"
set timeout 8000
expect \"sftp>\"
send \"exit \r\"

"

 done  # m
done  # y

