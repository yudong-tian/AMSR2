function [SD, qual_info] = SDcalc_amsr2(h5file, ff, fd, i, j)
% calculates snow depth in meters at the AMSRE lat-lon coordinate pair that 
% covers the GPS station location using the Kelly et al snow depth algorithm

% first check to make sure the data quality flags are not showing errors
dq = h5read(h5file, ...     
    '/Scan Data Quality');
dq = single(dq)';

qual_info = dq(i,472+1:472+4);
if qual_info(1)~=0 || qual_info(2)~=0 || qual_info(3)~=1 || qual_info(4)~=3
    qual_info(5) = 1;
end
    
    
    
% read in brightness temperature data for 36, 18, and 10 Ghz Data
tb36v = h5read(h5file, ...     
    '/Brightness Temperature (36.5GHz,V)');
tb36h = h5read(h5file, ...     
    '/Brightness Temperature (36.5GHz,H)');
tb10v = h5read(h5file, ...     
    '/Brightness Temperature (10.7GHz,V)');
tb10h = h5read(h5file, ...     
    '/Brightness Temperature (10.7GHz,H)');
tb18v = h5read(h5file, ...     
    '/Brightness Temperature (18.7GHz,V)');
tb18h = h5read(h5file, ...     
    '/Brightness Temperature (18.7GHz,H)');

% convert to TB in Kelvin
tb36v = double(tb36v(j,i))/100;
tb36h = double(tb36h(j,i))/100;
tb18v = double(tb18v(j,i))/100;
tb18h = double(tb18h(j,i))/100;
tb10v = double(tb10v(j,i))/100;
tb10h = double(tb10h(j,i))/100;


b = 0.6;

%this if-statment checks for moderate to deep snow, first in the vertical polarization           
if (tb10v - tb36v) > 0;
    pol_diff_1 = tb36v - tb36h;
    pol_diff_2 = tb18v - tb18h;
    % set a minimum polarization diff to make sure p1 and p2 < 1/log(3)
    if pol_diff_1 < 3 
        pol_diff_1 = 3;
    end
    if pol_diff_2 < 3;
        pol_diff_2 = 3;
    end
    p1 = 1 / log10(pol_diff_1);
    p2 = 1 / log10(pol_diff_2);
    
    SD = ff * (p1 * ( tb18v - tb36v )/(1 - b*fd) ) + (1 - ff)* ...
             (p1*(tb10v - tb36v) + p2*(tb10v - tb18v));
        
elseif (tb10h - tb36h) > 0;
    % if the vertical polarization differences do not detect 
    % snow, check the horizontal polarization differences
    pol_diff_1 = tb36v - tb36h;
    pol_diff_2 = tb18v - tb18h;
    if pol_diff_1 < 3 
        pol_diff_1 = 3;

    end
    if pol_diff_2 < 3;
        pol_diff_2 = 3;
    end
    p1 = 1 / log10(pol_diff_1);
    p2 = 1 / log10(pol_diff_2);
    
    SD = ff * (p1 * ( tb18h - tb36h )/(1 - b*fd) ) + (1 - ff)*...
          (p1*(tb10h - tb36h) + p2*(tb10h - tb18h));
        
else
    % if neither polarization detects snow, return a snow depth value of zero
    SD = 0;
end
SD = SD/100; % covert from cm to m


