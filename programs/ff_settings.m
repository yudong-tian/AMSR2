% set up forest fraction data for calculations by reading in the full ffcat matrix
A = fopen('/discover/nobackup/projects/smos/AMSR2/MATLAB/gl_ll.sds01.v4.bin');
ffcat = fread(A, [43200, 21600], '*uint8');

% change all instances where ffcat = 255 into ffcat = 0 because they are ocean
% areas
ffcat(ffcat==255) = 0;
ffcat = ffcat';

% set up index of lat and lon vectors with an increment of 30 arcsec
lonffcat = -180:(1/60)*0.5:180; 
lonffcat = lonffcat(1:end-1);
latffcat = 90:-(1/60)*0.5:-90; 
latffcat = latffcat(1:end-1);

% value used to average forest fraction value across AMSR2 footprint
ff_radius = 3;

 save('ff_settings')
