
gifs=`ls [0-9]*.gif |sort -n`

convert -delay 50 -loop 0 $gifs movie.gif 


