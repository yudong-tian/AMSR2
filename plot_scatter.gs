
* compare AMSR2 with SNOTEL+GPS, scatter plots, western US and Alaska 

* row
t.1='1OCT2012 1APR2013' 
t.2='1OCT2013 1APR2014' 
t.3='1OCT2014 1APR2015' 
t.4='1OCT2015 31DEC2015' 

*col, Alaska and W. US
mylat.1='55 75'
mylon.1='-170 -130'
zname.1='Alaska'
mylat.2='30 50' 
mylon.2='-130 -90'
zname.2='W. US'

yttl="AMSR2 SND (cm)"
xttl="SNOTEL+GPS SND (cm)"

cols=2
rows=4
hgap=0.1
vgap=0.2
vh=11/rows
vw=8.5/cols

parea='3.0 7.0 0.7 4.7'

'open snotel-gps-0.25.ctl'
'open daily_snd.ctl'

ir=1
while (ir <= rows)
 ic=1
 while (ic <= cols)

*compute vpage
 vx1=(ic-1)*vw+hgap
 vx2=ic*vw-hgap
 vy1=(rows-ir)*vh+vgap
 vy2=vy1+vh-vgap

'set vpage 'vx1' 'vx2' 'vy1' 'vy2
'set grads off'
*'set mproj scaled'
'set parea 'parea
'set xlopts 1 0.5 0.15'
'set ylopts 1 0.5 0.15'
'set lat 'mylat.ic
'set lon 'mylon.ic
'set gxout scatter'
'set time 't.ir
'q dims'
 line=sublin(result, 5)
 t1=subwrd(line, 11)
 t2=subwrd(line, 13)

tx=t1
while (tx <= t2) 
 'set t 'tx
 'set vrange 0 200' 
 'set vrange2 0 200' 
 'd snd;snd.2' 
 tx=tx+1
endwhile 
'draw title 'zname.ic' 't.ir 
'draw xlab 'xttl
'draw ylab 'yttl

 ic=ic+1
 endwhile
ir=ir+1
                                                                       
endwhile
'gxyat -x 3000 -y 4000 scatter.png'
'gxyat -x 750 -y 1000 sm-scatter.png' 




