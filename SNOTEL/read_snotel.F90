! $Id: read_snotel.F90,v 1.1 2013/06/04 23:28:20 ytian Exp ytian $ 
! This program reads daily QC's snotel data for each water year, 
!  project onto 0.25-deg grid and save in binary files 
!ifort -convert big_endian -assume byterecl -o read_snotel read_snotel.F90 
! grid: (30.125N ~ 89.875N), (-179.875 ~ - 60.125)
!  nr = 240, nc = 480


	Program rd3B42V6

	implicit NONE
        integer, parameter :: nc=440, nr=200, max_stns=1000
        integer, parameter :: ndays=1207   ! 2012-10-01 to 2016-01-20
        real, parameter :: lat0=30.125, lon0=-169.875, res=0.25
! fields in file 
! lat lon Year elev(m) yyyy mm dd snd(cm) swe(cm) 
        integer :: yr, mo, dy 
        real :: lat, lon, elev, snd, swe
	real, allocatable :: gswe(:, :, :), gsnd(:, :, :), gelev(:, :, :) 
        integer, allocatable :: cnt(:, :, :)  ! how many stations in one grid box 

        integer i, j, it, iargc, ic, ir, ierr, ierr1, is, maxd, itype
        character*200 filelist, datfile, ofile, ctmp
        ! time management
        character*2 cmon, cdy, chr, cmn
        character*4 cyear

        i =  iargc()
        If (i.NE.2) Then
          call getarg(0, ctmp) !** get program name
          Write(*, *) "Usage: ", trim(ctmp), &
            " <inputfile_list> <output-file> " 
          Stop
        End If

	allocate(gswe(nc, nr, ndays))
	allocate(gsnd(nc, nr, ndays))
	allocate(gelev(nc, nr, ndays))
	allocate(cnt(nc, nr, ndays))

       call getarg(1, filelist)
       call getarg(2, ofile)

! to be used later if more than 1 station fall on to the gridbox  
!       swe_cnt = 0
!       precip_cnt = 0
!       snowf_cnt = 0
       cnt = 0
       gswe=0.0 
       gsnd=0.0 
       gelev=0.0 

       open(15, file=filelist, form="formatted")
         Do is = 1, max_stns 
          read(15, '(A)', iostat=ierr) datfile 
          if (ierr .NE. 0 ) then
             write(*, *) "Reaching end of filelist. Total number of stations: " , is-1 
             close(15) 
             exit
          end if

          write(*, *) "Reading ", trim(datfile) 
            open(17, file=trim(datfile), form="formatted")
            Do it=1, ndays
              read(17, *, iostat=ierr1) lat, lon, elev, yr, mo, dy, snd, swe, itype 
              if (ierr1 .NE. 0 ) then
                 Write(*, *) "Reaching end of datafile, quit ... it=", it
                 exit
              end if 

              ic = nint( (lon - lon0)/res) + 1
              ir = nint( (lat - lat0)/res) + 1
              gswe(ic, ir, it) = gswe(ic, ir, it) + swe 
              gsnd(ic, ir, it) = gsnd(ic, ir, it) + snd 
              gelev(ic, ir, it) = gelev(ic, ir, it) + elev
              cnt(ic, ir, it) = cnt(ic, ir, it) + 1 
            End Do  ! it 
            close(17) 
         End Do ! is 

        Do it=1, ndays
           Do ir=1, nr 
             Do ic=1, nc 
                if (cnt(ic, ir, it) .GE. 1) then 
                  gswe(ic, ir, it) = gswe(ic, ir, it)/cnt(ic, ir, it) 
                  gsnd(ic, ir, it) = gsnd(ic, ir, it)/cnt(ic, ir, it) 
                  gelev(ic, ir, it) = gelev(ic, ir, it)/cnt(ic, ir, it) 
                else 
                  gswe(ic, ir, it) = -9999.0 
                  gsnd(ic, ir, it) = -9999.0 
                  gelev(ic, ir, it) = -9999.0 
               end if 
            End Do 
          End Do 
       End Do 

        open(12, file=trim(ofile), form="unformatted", &
                 access="direct", recl=nc*nr*4*4)
        Do it =1, ndays 
          write(12, rec=it) gsnd(:, :, it), gswe(:, :, it), gelev(:, :, it), &
                            real(cnt(:, :, it))   
        End Do 
        close(12) 

	end 
