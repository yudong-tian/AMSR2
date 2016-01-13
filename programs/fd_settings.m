% set up forest density data for processing
tree_files = dir('/discover/nobackup/projects/smos/AMSR2/vcf/MOD44B_V5_TRE*.tif');
QA_files = dir('/discover/nobackup/projects/smos/AMSR2/vcf/MOD44B_V5_QA*.tif');
cloud_files = dir('/discover/nobackup/projects/smos/AMSR2/vcf/MOD44B_V5_CLD*.tif');

% put forest fraction data into structures, one containing each square
vcf = struct([]);
for i = 1:length(tree_files)
    [vcf(i).A, vcf(i).cmap, vcf(i).refmat, vcf(i).bbox]= geotiffread(strcat('/discover/nobackup/projects/smos/AMSR2/vcf/', tree_files(i).name));
    [vcf(i).A_QA, vcf(i).R_QA] = geotiffread(strcat('/discover/nobackup/projects/smos/AMSR2/vcf/', QA_files(i).name));
    [vcf(i).A_cloud, vcf(i).R_cloud]= geotiffread(strcat('/discover/nobackup/projects/smos/AMSR2/vcf/', cloud_files(i).name));
end

% value used to average forest density value across AMSR2 footprint
fd_radius = 12;

% save('/discover/nobackup/hpatel2/fd_settings')