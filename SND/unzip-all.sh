#!/usr/local/bin/bash

#year=`date --date='1 day ago' +%Y`
#month=`date --date='1 day ago' +%m`
#yesterday=`date --date='2 day ago' +%d`


path=/discover/nobackup/projects/smos/AMSR2/SND

for y in 2012; do
  for m in 07 08 09 10 11 12; do 
    cd $path/$y/$m
    gunzip *.gz 
  done 
done 

for y in 2013 2014 2015; do
  for m in 01 02 03 04 05 06 07 08 09 10 11 12; do 
    cd $path/$y/$m
    gunzip *.gz 
  done
done 

