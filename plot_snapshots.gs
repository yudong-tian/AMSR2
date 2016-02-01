
* compare AMSR2 with SNOTEL+GPS

* row
t.1='31DEC2012'
t.2='31DEC2013'
t.3='31DEC2014'
t.4='31DEC2015'

*col
var.1='snd.2'
var.2='snd'
ttl.1="AMSR2 SND (cm)"
ttl.2="964 SNOTEL+GPS SND (cm)"

cols=2
rows=4
hgap=0.1
vgap=0.2
vh=11/rows
vw=8.5/cols

parea='0.7 7.5 0.5 4.5'

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
'set mproj scaled'
'set parea 'parea
'set xlopts 1 0.5 0.15'
'set ylopts 1 0.5 0.15'


'set time 't.ir 
'set clevs 0 10 20 30 40 50 60 70 80 90 100' 
'set gxout grfill'
'd 'var.ic
'cbarn' 
'draw title 'ttl.ic' 't.ir 

 ic=ic+1
 endwhile
ir=ir+1
                                                                       
endwhile
'gxyat -x 3000 -y 4000 snapshots-4yr.png'
'gxyat -x 750 -y 1000 sm-snapshots-4yr.png' 




