program daily

! Read ASMR2 snow depth (SND) retrievals and reproject to 0.25-deg lat/lon grid 
! and output daily mean

      use hdf5 

      implicit none

      ! for reprojection
      real, parameter :: lat0=-89.875, lon0=-179.875, res=0.25
      integer, parameter :: nc=1440, nr=720, nz=2  ! lat/lon grid
      integer :: ic, ir, iargc, value
      integer (kind=4), allocatable :: sm(:, :, :)
      real (kind=4), allocatable :: lon(:, :), lat(:, :) 
      real (kind=4) :: osm(nc, nr, nz), scalef
      integer (kind=4) :: cnt(nc, nr, nz), nf, jf 

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

      nf =  iargc()
      If (nf.le.10) Then   ! too few input files. Assuming > 10 
         write(*, *)"too few input files. At least 10."
         stop
      End If

     write(*, *) "number of input h5 files: ", nf-1 
     !output file name
     call getarg(1, ofile)
   
   osm = 0.0 
   cnt = 0 

   Do jf=2, nf 
     
     call getarg(jf, filename)
      
      write(*, *) "reading ", trim(filename) 
      !======= open the interface 
      call h5open_f(status) 
      if (status .ne. 0) write(*, *) "Failed to open HDF interface" 
      
      call h5fopen_f(filename, H5F_ACC_RDONLY_F, file_id, status) 
      if (status .ne. 0) then 
         write(*, *) "Failed to open HDF file" 
         go to 999
      end if 
      
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
      ! write(*, *)"nx = ", nx, " ny= ", ny, " nv=", nv, " scalef=", scalef

      allocate(sm(nv, ny, nx)) 
      allocate(lat(ny, nx)) 
      allocate(lon(ny, nx)) 

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

      !write(*, *) sm

      ! reprojection
      do k=1, nv
       do j=1, ny 
        do i=1, nx 
             ir = nint ( (lat(j, i) - lat0 )/res ) + 1
             ic = nint ( (lon(j, i) - lon0 )/res ) + 1
             value = sm(k, j, i)
             if ( value .GE. 0 ) then 
                 osm(ic, ir, k) = osm(ic, ir, k) + value*scalef
                 cnt(ic, ir, k) = cnt(ic, ir, k) + 1 
             end if 
         end do 
      end do 
      end do 

      deallocate(sm) 
      deallocate(lat) 
      deallocate(lon)

999      call h5close_f(status) 

    End do ! jf

     ! mean  values 
      do k=1, nz
       do j=1, nr 
        do i=1, nc 
           if (cnt(i, j, k) .GE. 1 ) then  ! there are values 
             osm(i, j, k) = osm(i, j, k) / real(cnt(i,  j, k)) 
           else 
             osm(i, j, k) = -9999.0 
           end if 
        end do 
       end do 
      end do 

      write(*, *) "Saving binary format ...", nc, nr
      open(22, file=ofile, form="unformatted", access="direct", recl=nc*nr*nz*4) 
          write(22, rec=1) osm 
      close(22) 
       

end program daily 
