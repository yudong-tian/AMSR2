
* plot global AMSR2 snapshots

* row.col
t.1.1='31DEC2012'
t.1.2='28FEB2013'
t.2.1='31DEC2013'
t.2.2='28FEB2014'
t.3.1='31DEC2014'
t.3.2='28FEB2015'
t.4.1='31DEC2015'
t.4.2='28FEB2016'

*col
var='snd'
ttl="AMSR2 SND (cm)"

cols=2
rows=4
hgap=0.1
vgap=0.2
vh=11/rows
vw=8.5/cols

parea='0.7 7.5 0.5 4.5'

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

if (ic != cols | ir != rows )

'set time 't.ir.ic 
'set clevs 0 10 20 30 40 50 60 70 80 90 100' 
'set gxout grfill'
'd 'var
'cbarn' 
'draw title 'ttl' 't.ir.ic 

endif 

 ic=ic+1
 endwhile
ir=ir+1
                                                                       
endwhile
'gxyat -x 3000 -y 4000 global-snapshots-4yr.png'
'gxyat -x 750 -y 1000 sm-global-snapshots-4yr.png' 




