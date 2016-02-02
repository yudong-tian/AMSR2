for reg in AK WUS; do 
   
agrf=PDF-$reg.agr
psf=PDF-$reg.ps 

cat > $agrf <<EOF
#
@version 50109
@    title "Histogram of Snow Depth (cm), $reg, Oct. 2012- Dec. 2015"
@    title size 1.0
@    xaxis label "Snow Depth (cm)"
@    yaxis label "Frequency (%)"
@    legend 0.95, 0.85
@    s0 legend "In-situ"
@    s1 legend "AMSR2"
@    s0 line linewidth 3.0
@    s1 line linewidth 2.0
@    world xmin 1
@    world xmax 300
@    world ymin 0
@    world ymax 15
@    yaxis  tick major 3

EOF
cat Ref_PDF_$reg.txt >> $agrf 
echo '&' >> $agrf 
cat AMSR2_PDF_$reg.txt >> $agrf 

xmgrace -hardcopy -printfile $psf $agrf 

done 
