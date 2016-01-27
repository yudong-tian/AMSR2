program reproj

! Read ASMR2 snow depth (SND) retrievals and reproject to 0.25-deg lat/lon grid 

      use hdf5 

      implicit none

      ! for reprojection
      real, parameter :: lat0=-89.875, lon0=-179.875, res=0.25
      integer, parameter :: nc=1440, nr=720, nz=2  ! lat/lon grid
      integer :: ic, ir, iargc, value
      integer (kind=4), allocatable :: sm(:, :, :)
      real (kind=4), allocatable :: lon(:, :), lat(:, :) 
      real (kind=4) :: osm(nc, nr, nz), scalef

      ! declarations
      integer (kind=4) :: fid,swid,status,astat
      integer (hsize_t) :: rank,dims(3),maxdims(3), datatype,i,j,k, nx, ny, nv
      character (len=255) :: dimlist
      integer (kind=4), allocatable :: start(:),stride(:)

      !======= choose the file and field to read
      character (len=128) :: filename, ofile ! input and output file names 
      character*100,   parameter    :: sm_gr_name = "/"
      character*100,   parameter    :: sm_field_name = "Geophysical Data"
      character*100,   parameter    :: lon_name = "Longitude of Observation Point"
      character*100,   parameter    :: lat_name = "Latitude of Observation Point"
      character*100,   parameter    :: scalef_name = "SCALE FACTOR" 
      integer(hid_t)                :: file_id, sm_gr_id,sm_field_id, attr_id
      integer(hid_t)                :: lon_id, lat_id 
      integer(hid_t)                :: dataspace

      i =  iargc()
      If (i.ne.2) Then   ! wrong cmd line args, print usage
         write(*, *)"Usage:"
         write(*, *)"reproj input_h5_file output_bin_file"
         stop
      End If

     call getarg(1, filename)
     call getarg(2, ofile)
      
      !======= open the interface 
      call h5open_f(status) 
      if (status .ne. 0) write(*, *) "Failed to open HDF interface" 
      
      call h5fopen_f(filename, H5F_ACC_RDONLY_F, file_id, status) 
      if (status .ne. 0) write(*, *) "Failed to open HDF file" 
      
      call h5gopen_f(file_id,sm_gr_name,sm_gr_id, status)
      if (status .ne. 0) write(*, *) "Failed to get group: ", sm_gr_name 

      call h5dopen_f(sm_gr_id,sm_field_name,sm_field_id, status)
      if (status .ne. 0) write(*, *) "Failed to get dataset: ", sm_field_name 

      call h5dget_space_f(sm_field_id, dataspace, status)
      if (status .ne. 0) write(*, *) "Failed to get dataspace id" 

      CALL h5sget_simple_extent_dims_f(dataspace, dims, maxdims, status)
      if (status .lt. 0) write(*, *) "Failed to get dims, status=", status 

      ! get scale factor 
      call h5aopen_by_name_f(sm_field_id, ".", scalef_name, attr_id, status) 
      if (status .ne. 0) write(*, *) "Failed to get attribute id" 
      call h5aread_f(attr_id, H5T_NATIVE_REAL, scalef, dims, status) 
      if (status .ne. 0) write(*, *) "Failed to read attribute" 


      nx = dims(3) 
      ny = dims(2) 
      nv = dims(1) 
      write(*, *)"nx = ", nx, " ny= ", ny, " nv=", nv, " scalef=", scalef
      ! assuming lat/lon has same first 2 dimensions as data array
      ! weird dimension layout
      !allocate(sm(nx, ny, nv)) 
      allocate(sm(nv, nx, ny)) 
      allocate(lat(nx, ny)) 
      allocate(lon(nx, ny)) 

      call h5dread_f(sm_field_id, H5T_NATIVE_INTEGER, sm, dims, status)
      if (status .ne. 0) write(*, *) "Failed to read sm" 

      call h5dopen_f(sm_gr_id, lon_name, lon_id, status)
      if (status .ne. 0) write(*, *) "Failed to get lon_id" 

      call h5dread_f(lon_id, H5T_NATIVE_REAL, lon, dims(1:2), status)
      if (status .ne. 0) write(*, *) "Failed to read lon" 

      call h5dopen_f(sm_gr_id, lat_name, lat_id, status)
      if (status .ne. 0) write(*, *) "Failed to get lat_id" 

      call h5dread_f(lat_id, H5T_NATIVE_REAL, lat, dims(1:2), status)
      if (status .ne. 0) write(*, *) "Failed to read lat" 

      call h5fclose_f(file_id, status)  
      call h5close_f(status) 

      !write(*, *) sm

      osm = -9999.0
      ! reprojection
      do k=1, nv
      do j=1, ny 
        do i=1, nx 
             ir = nint ( (lat(i, j) - lat0 )/res ) + 1
             ic = nint ( (lon(i, j) - lon0 )/res ) + 1
             !value = sm(i, j, 1)
             value = sm(k, i, j)
             if ( value .GE. 0 ) osm(ic, ir, k) = value*scalef
         end do 
      end do 
      end do 

      write(*, *) "Saving binary format ...", nc, nr
      open(22, file=ofile, form="unformatted", access="direct", recl=nc*nr*nz*4) 
          write(22, rec=1) osm 
      close(22) 
       

      deallocate(sm) 
      deallocate(lat) 
      deallocate(lon)

end program reproj 
