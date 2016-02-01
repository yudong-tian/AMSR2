

ls SNOTEL/SNOTEL_reformatted/*.csv > reform_data_list.txt 
ls GPS/GPS_reformatted/*.csv >> reform_data_list.txt 

./combine_SNOTEL_GPS reform_data_list.txt snotel-gps-0.25.4gd4r



