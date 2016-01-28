
'open snd.ctl'
'set gxout shaded'

t=1
while(t<=28) 
  'set t 't
  'set grads off'
  'set clevs 0 5 10 15 20 25 30 35 40 45 50 55 60 65' 
  'd snd' 
 t=t+1
endwhile 
'cbarn' 
'draw title SNOW DEPTH (1st field) (cm)' 

'gxyat -x 1200 -y 900 snd.png' 


'reinit'


'open snd.ctl'
'set gxout shaded'

t=1
while(t<=28)
  'set t 't
  'set grads off'
  'set clevs 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14' 
  'd swe'
 t=t+1
endwhile
'cbarn'
'draw title SWE (cm)'

'gxyat -x 1200 -y 900 swe.png'


