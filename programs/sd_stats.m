clc
clear
close all

% read in the number of snow classified GPS stations
[num, txt, raw] = xlsread('~/MATLAB/GPS_stations/stations_new.xls');
non_ephm_snow = txt(2:end,1);
state = txt(2:end,2);
elevation = raw(2:end,3);
landcover = raw(2:end,4);

% intialize Sturm snow classification group counters
count_water = 1;
count_tundra = 1;
count_taiga = 1;
count_maritime = 1;
count_ephemeral = 1;
count_prairie = 1;
count_alpine = 1;
count_ice = 1;

% initialize cell arrays that will contain names of GPS stations in each
% classification
water = cell(1);
tundra = cell(1);
taiga = cell(1);
maritime = cell(1);
ephemeral = cell(1);
prairie = cell(1);
alpine = cell(1);
ice = cell(1);

% initialize AMSR2, AMSRE, and GPS snow depth arrays
amsr2sd = zeros(length(non_ephm_snow),200);
amsresd = zeros(length(non_ephm_snow),300);
gpssd2 = amsr2sd;
gpssde = amsresd;

% initialize array that classifies each GPS station by number
types = zeros(58,8);

for i = 1:length(non_ephm_snow)
    
    station = non_ephm_snow{i};
    
    % check for AMSR2 flyover data while GPS station measured snow depth
    % values
    saved_amsr2 = strcat('/discover/nobackup/projects/smos/AMSR2/MATLAB/Test/', station, '_amsr2*');
    station_data_amsr2 = dir(saved_amsr2);
    for a2count = 1:length(station_data_amsr2)
        check1 = strcmp( station_data_amsr2(a2count).name, strcat(station, '_amsr2_newpos.mat') );
        if check1
            break
        end
    end
    
    % check for AMSRE flyover data while GPS station measured snow depth
    % values
    saved_amsre = strcat('/discover/nobackup/projects/smos/AMSR2/MATLAB/Test/', station, '_amsre*');
    station_data_amsre = dir(saved_amsre);
    for aecount = 1:length(station_data_amsre)
        check2 = strcmp( station_data_amsre(aecount).name, strcat(station, '_amsre_newpos.mat') );
        if check2
            break
        end
    end
    
    % if there is no AMSRE or AMSR2 data, move on to next GPS station.
    % otherwise, record GPS station and AMSR(2&E) SD in array.
    if check1
        load(strcat( '/discover/nobackup/projects/smos/AMSR2/MATLAB/Test/', station_data_amsr2(a2count).name), 'AMSR');
        for j = 1:length(AMSR)
            amsr2sd(i,j) = AMSR(j).SD;
            gpssd2(i,j) = AMSR(j).gps_SD;
            flag2(i) = length(AMSR);
        end
    end
    
    if check2
        load(strcat( '/discover/nobackup/projects/smos/AMSR2/MATLAB/Test/', station_data_amsre(aecount).name), 'AMSRE');
        for k = 1:length(AMSRE)
            amsresd(i,k) = AMSRE(k).SD;
            gpssde(i,k) = AMSRE(k).gps_SD;
            flage(i) = length(AMSRE);
        end
    end
    
    
    %% group sets of data into their own groups
    if check1 || check2
        % use nearest neighbor method to find Sturm snow classification
        % closest to GPS station
        sclass = find_snow_class(AMSR(1).gps_lon, AMSR(1).gps_lat);
        station_name = AMSR(1).station_name;
        if sclass==0
            water{count_water} = station_name;
            types(count_water,1) = i;
            count_water = count_water + 1;
        elseif sclass==1
            tundra{count_tundra} = station_name;
            types(count_tundra,2) = i;
            count_tundra = count_tundra + 1;
        elseif sclass==2
            taiga{count_taiga} = station_name;
            types(count_taiga,3) = i;
            count_taiga = count_taiga + 1;
        elseif sclass==3
            maritime{count_maritime} = station_name;
            types(count_maritime,4) = i;
            count_maritime = count_maritime + 1;
        elseif sclass==4
            ephemeral{count_ephemeral} = station_name;
            types(count_ephemeral,5) = i;
            count_ephemeral = count_ephemeral + 1;
        elseif sclass==5
            prairie{count_prairie} = station_name;
            types(count_prairie,6) = i;
            count_prairie = count_prairie + 1;
        elseif sclass==6
            alpine{count_alpine} = station_name;
            types(count_alpine,7) = i;
            count_alpine = count_alpine + 1;
        elseif sclass==7
            ice{count_ice} = station_name;
            types(count_water,8) = i;
            count_ice = count_ice + 1;
        end
    end
end


%% change all negative snow depth values to zero
amsr2sd(amsr2sd<0) = 0;
gpssd2(gpssd2<0) = 0;
amsresd(amsresd<0) = 0;
gpssde(gpssde<0) = 0;


%% remove filler rows with no data before perfoming statistics on full dataset

% first collect AMSR(2&E) data rows that are all zeros (fillers) in between
% actual data
amsr2nodata = [];
amsrenodata = [];
for i = 1:size(amsr2sd,1)
    if amsr2sd(i,:) == 0
        amsr2nodata = [amsr2nodata; i];
    end
end
for i = 1:size(amsresd,1)
    if amsresd(i,:) == 0
        amsrenodata = [amsrenodata; i];
    end
end


for k = 1:8
    sde(k).snowdepth = [];
    sde(k).mat.amsrevals = [];
    sde(k).gpssnowdepth = [];
    sde(k).gpsmat.gpsvals = [];
    % find all GPS stations in this Sturm classification type
    all_data = types(find(types(:,k)),k);
    % use setdiff to find the GPS stations with AMSRE data 
    amsredata = setdiff(1:size(amsresd,1), amsrenodata);
    % record indices of stations with AMSRE data
    ind = intersect(amsredata, all_data);
    % for each GPS station in this classification, perform these operations
    for i = 1:length(ind)
        % find AMSRE and GPS SD values
        vals = amsresd( ind(i) , 1:flage(ind(i)));
        gpsvals = gpssde( ind(i) , 1:flage(ind(i)));
        % record AMSRE and GPS values into arrays and structures for later processing
        sde(k).snowdepth = [sde(k).snowdepth vals];
        sde(k).mat(i).amsrevals = vals;
        sde(k).gpssnowdepth = [sde(k).gpssnowdepth gpsvals];
        sde(k).gpsmat(i).gpsvals = gpsvals;
        % record mean and st. dev. of AMSRE and GPS SD by station
        sde(k).mean_by_station(i) = mean(vals);
        sde(k).gps_mean_by_station(i) = mean(gpsvals);
        sde(k).std_by_station(i) = std(vals);
        sde(k).gps_std_by_station(i) = std(gpsvals);
    end
    % record AMSRE and GPS SD mean and st. dev. for entire classification
    sde(k).mean = mean(sde(k).snowdepth);
    sde(k).std = std(sde(k).snowdepth);
    sde(k).gps_mean = mean(sde(k).gpssnowdepth);
    sde(k).gps_std = std(sde(k).gpssnowdepth);
end

%% create scatter plot with GPS station data on X-axis and AMSR-2 and AMSE data on Y-axis
typesall = {'', 'water', 'tundra', 'taiga', 'maritime', 'ephemeral', 'prairie', ...
    'alpine', 'ice'};
% close all
figure
set(gcf,'Position',[0 0 1920 1000]);
% string array with color options to cycle through for scatter plot
color = 'bgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrmbgkrm';
for k = 1:8
    % do same procedure for AMSR2 data as performed for AMSRE data
    sd2(k).snowdepth = [];
    % sd2(k).snowdepthmat = [];
    sd2(k).gpssnowdepth = [];
    % sd2(k).gpssnowdepthmat = [];
    all_data = types(find(types(:,k)),k);
    amsr2data = setdiff(1:size(amsr2sd,1), amsr2nodata);
    ind = intersect(amsr2data, all_data);
    % create subplots for each classification type
    subplot(2,4,k)
    
    for i = 1:length(ind)
        vals = amsr2sd( ind(i) , 1:flag2(ind(i)));
        gpsvals = gpssd2( ind(i) , 1:flag2(ind(i)));
        sd2(k).snowdepth = [sd2(k).snowdepth vals];
        %     sd2(k).snowdepthmat(i) = vals;
        sd2(k).gpssnowdepth = [sd2(k).gpssnowdepth gpsvals];
        %     sd2(k).gpssnowdepthmat(i) = gpsvals;
        sd2(k).mean_by_station(i) = mean(vals);
        sd2(k).gps_mean_by_station(i) = mean(gpsvals);
        sd2(k).std_by_station(i) = std(vals);
        sd2(k).gps_std_by_station(i) = std(gpsvals);
        
        
        % create scatter plot of GPS station derived SD (on x-axis) vs AMSR2
        % and AMSRE (on y-axis). color is different for each station. 
        if ~isempty(gpsvals)
            scatter(gpsvals, vals, color(i))
        else
            scatter(0,0, 'o')
        end
        hold on
        % only plot AMSRE data for GPS stations that had SD data during the
        % AMSRE timeframe
        if length(sde(k).gpsmat)>= i && ~isempty(sde(k).gpsmat(i).gpsvals)
            scatter(sde(k).gpsmat(i).gpsvals, sde(k).mat(i).amsrevals, color(i))
        else
            scatter(0,0, 'o')
        end
        
        
    end
    % plotting settings
    axis square
    maxlim = max(sd2(k).gpssnowdepth);
    if ~isempty(maxlim)
        axis_length = [0 maxlim];
    else
        axis_length = [0 1];
    end
    xlim(axis_length)
    ylim(axis_length)
    line(axis_length, axis_length, 'Color', 'Black')
    xlabel('GPS Snow Depth (m)')
    ylabel('Snow Depth (m)')
    
    title(strcat('Sturm Type:',typesall{k+1}))
    %     text(1.5,1, {strcat('# of Stations:', length(ind))}, 'EdgeColor','none')
    
    % record mean and st. dev. of total snow depth values
    sd2(k).mean = mean(sd2(k).snowdepth);
    sd2(k).std = std(sd2(k).snowdepth);
    sd2(k).gps_mean = mean(sd2(k).gpssnowdepth);
    sd2(k).gps_std = std(sd2(k).gpssnowdepth);
end



% for k = 1:8
%
% end
% saveas(gcf, 'GPS_stations_snowdepth.bmp')


%
%% plot mean and st. dev. of snow depths by Sturm classification using MATLAB's errorbar function
% delete('stats_by_station_type.txt')

% diary stats_by_station_type.txt
figure
clf
% subplot(4,1,1:3)
for k = 1:8
    %     typesall{k+1}
    %     [sd2(k).mean sd2(k).std, sde(k).mean, sde(k).std]
    %     typesall{k+1}
    %     [sd2(k).gps_mean, sd2(k).gps_std, sde(k).gps_mean, sde(k).gps_std]
    hold on
    % plot AMSR2 derived mean and st.dev. using errorbar function
    % if the (mean - st. dev.) is negative, make lower error bar end at 0
    if (sd2(k).mean - sd2(k).std) < 0
        lower = sd2(k).mean;
        errorbar(k-0.2,sd2(k).mean, lower,sd2(k).std)
    else % otherwise, use st.dev. for lower and upper error bars
        errorbar(k-0.2,sd2(k).mean, sd2(k).std)
    end
    % repeat for GPS derived snow depths during AMSR2 timeframe
    if (sd2(k).gps_mean - sd2(k).gps_std) < 0
        lower = sd2(k).gps_mean;
        errorbar(k-0.1,sd2(k).gps_mean, lower,sd2(k).gps_std, 'k')
    else
        errorbar(k-0.1,sd2(k).gps_mean, sd2(k).gps_std, 'k')
    end
    % repeat for AMSRE derived snow depths
    if (sde(k).gps_mean - sde(k).gps_std) < 0
        lower = sde(k).gps_mean;
        errorbar(k+0.2,sde(k).gps_mean, lower,sde(k).gps_std, 'm')
    else
        errorbar(k+0.2,sde(k).gps_mean, sde(k).gps_std, 'm')
    end
    % repeat for GPS derived snow depths during AMSRE timeframe
    if (sde(k).mean - sde(k).std) < 0
        lower = sde(k).mean;
        errorbar(k+0.1,sde(k).mean, lower,sde(k).std, 'r')
    else
        errorbar(k+0.1,sde(k).mean, sde(k).std, 'r')
    end
    
    % collect number of GPS stations in each classification
    histvals(k) = length(eval(typesall{k+1}));
    % collect statistics data for future plotting
    sd2meanvals(k) = sd2(k).mean;
    sdemeanvals(k) = sde(k).mean;
    gps2meanvals(k) = sd2(k).gps_mean;
    gpsemeanvals(k) = sde(k).gps_mean;
    
end
% diary off

set(gca,'XTickLabel', typesall)
%     set(gca, 'XTickMarks', 'off')
ylabel('Snow Depth (m)')
xlabel('Sturm Classification')
legend('AMSR2 SD', 'GPS SD with AMSR2', 'AMSRE SD', 'GPS SD with AMSRE')

% plot number of GPS stations in each classification on secondary y-axis
[haxes,hline1,hline2] = plotyy([1:8]-0.2,sd2meanvals, 1:8, histvals, 'scatter', 'scatter');

% plot mean values as circles over error bars
axes(haxes(1))
scatter([1:8]-0.1,gps2meanvals, 'ko')
scatter([1:8]+0.1,sdemeanvals, 'ro')
scatter([1:8]+0.2,gpsemeanvals, 'mo')

axes(haxes(2))
set(haxes(2), 'XTickLabel', '')
ylabel('Histogram of GPS Stations in Sturm Classifications (Green Filled in Circles)')

set(hline2, 'MarkerEdgeColor','g','LineWidth',5)

% %%
% % calculate mean of all amsr2 derived snow depth data
% amsr2data = setdiff(1:size(amsr2sd,1), amsr2nodata);
% amsr2meanstation = mean(amsr2sd(amsr2data,:),2);
% amsr2mean = mean(amsr2meanstation);
% gpsmean2station = mean(gpssd2(amsr2data,:),2);
% gpsmean2 = mean(gpsmean2station);
%
% % calculate mean of all amsre derived snow depth data
% amsredata = setdiff(1:size(amsresd,1), amsrenodata);
% amsremeanstation = mean(amsresd(amsredata,:),2);
% amsremean = mean(amsremeanstation);
% gpsmeanestation = mean(gpssde(amsredata,:),2);
% gpsmeane = mean(gpsmeanestation);
%
% % calculate standard deviation of all amsr2 derived snow depth data
% amsr2stdstation = std(amsr2sd(amsr2data,:),0,2);
% amsr2std = std(mat2vec(amsr2sd(amsr2data,:)));
%
% gpsstd2station = std(gpssd2(amsr2data,:),0,2);
% gpsstd2 = std(mat2vec(gpssd2(amsr2data,:)));
%
% % calculate standard deviation of all amsre derived snow depth data
% amsrestdstation = std(amsresd(amsredata,:),0,2);
% amsrestd = std(mat2vec(amsresd(amsredata,:)));
%
% gpsstdestation = std(gpssde(amsredata,:),0,2);
% gpsstde = std(mat2vec(gpssde(amsredata,:)));


