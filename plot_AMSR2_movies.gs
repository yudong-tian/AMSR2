
* plot 30-daily snapshots to make animation 

* row.col
tspan='1OCT2012 31DEC2015'

var='snd'
ttl="AMSR2 SND (cm)"

'open daily_snd.ctl'
'set time 'tspan 
 'q dims'
 line=sublin(result, 5)
 t1=subwrd(line, 11)
 t2=subwrd(line, 13)

while (t1 <= t2) 
 'c' 
 'set t 't1
 'q dims'
 line=sublin(result, 5)
 tstr=subwrd(line, 6)
 'set grads off'
*'set mproj scaled'
'set xlopts 1 0.5 0.15'
'set ylopts 1 0.5 0.15'
'set lon 0 320'
'set lat -60 90'
'set clevs 0 10 20 30 40 50 60 70 80 90 100' 
'set gxout shaded' 
'd 'var
'cbarn' 
'draw title 'ttl' 'tstr 
'gxyat -x 1000 -y 750 movie/'t1'.gif' 

t1=t1+30
endwhile
                                                                       



