! This program produces the PDFs for AMSR2 and SNOTEL+GPS, for a user-specified 
! region 
! usage: 
! PDF-compute lat1 lat2 lon1 lon2 outfile 
!ifort -convert big_endian -assume byterecl -o read_snotel read_snotel.F90 


	Program rd3B42V6

	implicit NONE
        integer, parameter :: nc=440, nr=200  ! snotel domain
        integer, parameter :: ndays = 641       ! number of days within given date range 
        real, parameter :: lat0=30.125, lon0=-169.875, res=0.25
        real, parameter :: dbin=3.0    ! binsize: cm 

        integer, parameter :: maxbin=100
        real*8 rain, xbin(0:maxbin), mind, dist
        integer y(0:maxbin)
        integer  ibin, ngrids, mbin

        real :: lat1, lat2, lon1, lon2
	real ::  snd(nc, nr)

        integer i, j, it, iargc, ic, ir, nc1, nc2, nr1, nr2 
        character*200 filelist, datfile, ctmp
        ! time management

        i =  iargc()
        If (i.NE.5) Then
          call getarg(0, ctmp) !** get program name
          Write(*, *) "Usage: ", trim(ctmp), &
            " lat1 lat2 lon1 lon2 inputfile" 
          Stop
        End If
        call getarg(1, ctmp)
        read(ctmp, *) lat1
        call getarg(2, ctmp)
        read(ctmp, *) lat2
        call getarg(3, ctmp)
        read(ctmp, *) lon1
        call getarg(4, ctmp)
        read(ctmp, *) lon2

        call getarg(5, datfile) 

        ! indices in ref data  grid
        nc1 = nint((lon1 - lon0)/res) + 1
        nc2 = nint((lon2 - lon0)/res) + 1
        nr1 = nint((lat1 - lat0)/res) + 1
        nr2 = nint((lat2 - lat0)/res) + 1

        Do ibin=0, maxbin
          xbin(ibin) = ibin*dbin   ! range: 0-300
        End do 

        y = 0 
        ngrids = 0 

       open(15, file=datfile, form="unformatted", access="direct", recl=nc*nr*4)

       Do it = 1, ndays 
         read(15, rec=it) snd
         Do j=nr1, nr2
           Do  i = nc1, nc2
            rain = snd(i, j)   ! cm 
            if( rain.GE.xbin(0) .and. rain.LE.xbin(maxbin)) then
                  ngrids = ngrids + 1
                  ibin = nint( (rain - xbin(0))/dbin )
                  y(ibin) = y (ibin) + 1
            endif

           End Do
        End Do 
      End Do 
      close(15) 

      Do ibin = 0, maxbin
        write(*, '(2F14.6)') xbin(ibin), real(y(ibin))/real(ngrids)*100.0 
      End Do

     end 
