
# reproject GPS data to 0.25-deg lat/lon grid 
# reuse ../combine_SNOTEL_GPS

ls GPS_reformatted/*.csv > reform_data_list.txt 

../combine_SNOTEL_GPS reform_data_list.txt gps-0.25.4gd4r



