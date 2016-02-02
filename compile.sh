
export INC_HDF=/home/ytian/proj-disk/libs/hdf5/1.8.8_intel_15_0_0_090/include
export LIB_HDF=/home/ytian/proj-disk/libs/hdf5/1.8.8_intel_15_0_0_090/lib

ifort -g -u -traceback -names lowercase  -nomixed_str_len_arg -convert big_endian -assume byterec \
-o PDF-compute  PDF-compute.F90

ifort -g -u -traceback -names lowercase  -nomixed_str_len_arg -convert big_endian -assume byterec \
-o combine_SNOTEL_GPS combine_SNOTEL_GPS.F90 ~/lib/fmktime/fmktime.a

