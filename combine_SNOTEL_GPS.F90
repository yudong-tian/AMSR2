! $Id: read_snotel.F90,v 1.1 2013/06/04 23:28:20 ytian Exp ytian $ 
! This program reads daily QC's snotel data for each water year, 
!  project onto 0.25-deg grid and save in binary files 
!ifort -convert big_endian -assume byterecl -o read_snotel read_snotel.F90 
! grid: (30.125N ~ 89.875N), (-179.875 ~ - 60.125)
!  nr = 240, nc = 480


	Program rd3B42V6

	implicit NONE
        integer, parameter :: nc=440, nr=200, max_stns=2000
        integer, parameter :: max_lines=80000   !max possible lines in an input date file 
        integer :: ndays        ! number of days within given date range 
        real, parameter :: lat0=30.125, lon0=-169.875, res=0.25
! fields in file 
! lat lon Year elev(m) yyyy mm dd snd(cm) swe(cm) 
        integer :: yr, mo, dy, esec, iday 
        integer :: yr0, mo0, dy0, esec0, date2esec 
        integer :: yr1, mo1, dy1, esec1 
        real :: lat, lon, elev, snd, swe
	real, allocatable :: gswe(:, :, :), gsnd(:, :, :), gelev(:, :, :) 
        integer, allocatable :: cnt(:, :, :), types(:, :, :)  ! how many and types of stations in one grid box 

        integer i, j, it, iargc, ic, ir, ierr, ierr1, is, maxd, itype
        character*200 filelist, datfile, ofile, ctmp
        ! time management
        character*2 cmon, cdy, chr, cmn
        character*4 cyear

        yr0=2012
        mo0=10
        dy0=1
        esec0 = date2esec(yr0, mo0, dy0, 0, 0, 0)
        yr1=2016
        mo1=1
        dy1=20
        esec1 = date2esec(yr1, mo1, dy1, 0, 0, 0)

        ndays = (esec1 - esec0) / (24*60*60) + 1

        write(*, *) "Total number of days: ", ndays 

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
	allocate(types(nc, nr, ndays))

       call getarg(1, filelist)
       call getarg(2, ofile)

! to be used later if more than 1 station fall on to the gridbox  
!       swe_cnt = 0
!       precip_cnt = 0
!       snowf_cnt = 0
       cnt = 0
       types = 0
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
            Do it=1, max_lines
              read(17, *, iostat=ierr1) lat, lon, elev, yr, mo, dy, snd, swe, itype 
              if (ierr1 .NE. 0 ) then
                 Write(*, *) "Reaching end of datafile, quit ... it=", it
                 exit
              end if 

              esec = date2esec(yr, mo, dy, 0, 0, 0)
              iday = (esec - esec0 ) /(24*60*60) + 1
              if (iday .GE. 1 .and. iday .LE. ndays) then 
                ic = nint( (lon - lon0)/res) + 1
                ir = nint( (lat - lat0)/res) + 1
                if ( ic .GE. 1 .and. ic .LE. nc) then 
                  if ( ir .GE. 1 .and. ir .LE. nr) then 
                    gswe(ic, ir, iday) = gswe(ic, ir, iday) + swe 
                    gsnd(ic, ir, iday) = gsnd(ic, ir, iday) + snd 
                    gelev(ic, ir, iday) = gelev(ic, ir, iday) + elev
                    cnt(ic, ir, iday) = cnt(ic, ir, iday) + 1
                    types(ic, ir, iday) = types(ic, ir, iday) + itype 
                  end if
                end if
               end if 
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
                            real(types(:, :, it))   
        End Do 
        close(12) 

	end 
