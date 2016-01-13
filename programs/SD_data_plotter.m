clc
clear
close all

%YDT [num, txt, raw] = xlsread('~/MATLAB/GPS_stations/stations.xls');
[num, txt, raw] = xlsread('GPS_stations/stations.xls');
non_ephm_snow = txt(2:end,1);

% non_ephm_snow2 = non_ephm_snow;
% non_ephm_snow2 = {'nwot', 'p052', 'p041', 'p046', 'p351', 'p682', 'ab33', 'ashl'};
% non_ephm_snow2 = {'ashl', 'p048' 'nwot', 'p052', 'p041', 'p046', 'ac71', 'moil', 'p019', 'p023', 'p088', 'p350', 'p351', 'p682', 'ab33'};
% non_ephm_snow2 = {'ashl'};
non_ephm_snow2 = { 'ab33', 'nwot', 'moil', 'p019', 'p023', 'p088', 'p350', 'p351', 'p682'};
midtextbox = {'p023', 'p351','ashl'};
yliminput = 2;
ytextbox = 0.7;
state = txt(2:end,2);
elevation = raw(2:end,3);
landcover = raw(2:end,4);


for i = 1:length(landcover)
    if ~isempty(find(landcover{i} ==  '_'))
     landcover{i}(find(landcover{i} ==  '_')) = ' ';
    end
end

% %%
% cd /discover/nobackup/projects/smos/AMSR2/MATLAB/GPS/GPS_station_pictures/
% files = dir;
% filezero = [];
% count = 0;
% for i = 1:length(files)
%     
%     if files(i).bytes == 3004
%         count = count + 1;
%         fileszero(count) = i;
%     end
% end
% %%
% clear instruct
% instruct = cell(52,1);
% for j = 1:length(fileszero)
%     filenameoo = files(fileszero(j)).name(1:4);
%     
%     file = strcat('~/MATLAB/GPS_stations/', filenameoo, '/', filenameoo, '_v1.csv');
%     
%     [gps.date, gps.SD, gps.SD_std, gps.swe, gps.lat, gps.lon, gps.station_name] = readgps(file);
%     
%     instruct{j} = ['wget --output-document=',filenameoo,'_aerial.jpg' 'https://maps.google.com/maps?q=', num2str(gps.lat), ',+', num2str(gps.lon), '+(Station+p033)&iwloc=A&hl=en'];
% %     instruct{j-2} = ['wget --output-document=',filenameoo,'_aerial.jpg http://maps.google.com/maps/api/staticmap?center=', num2str(gps.lat), ',', num2str(gps.lon), '&zoom=15&markers=color:yellow|', num2str(gps.lat), ',', num2str(gps.lon), '&size=200x200&maptype=satellite&sensor=false'];
% end
%%


%    loop = [      92]
%     24
%     25
%     26
%     34
%     35f
%     66
%     89
%     90
%     92
%     110
%     115];


for i = 1:length(non_ephm_snow2)
    proceed = 0;
    % choose station to make slide of
    % st = loop(i);
    for m = 1:length(non_ephm_snow)
    if strcmp(non_ephm_snow2{i}, non_ephm_snow{m});
        st = m;
        stat2 = i;
        proceed = 1;
        break
    end
    end   
    if proceed
    station = non_ephm_snow2{stat2};
    
    % % read in ground truth for stations that have it
    if strcmp(station, 'p041');
        ground = csvread('manual_marshall_obs.csv', 1, 0);
        ground_date = datenum(ground(:,1), ground(:,2), ground(:,3));
    end

       
    
    % check for AMSR2 flyover data while GPS station measured snow depth
    % values
    saved_amsr2 = strcat('/discover/nobackup/projects/smos/AMSR2/programs/GPS/', station, '_amsr2*');
    station_data_amsr2 = dir(saved_amsr2);
    %YDT, initialize it
    check2 = 0; 
      
    for a2count = 1:length(station_data_amsr2)
        check2 = strcmp( station_data_amsr2(a2count).name, strcat(station, '_amsr2_10.mat') );
        if check2
            break
        end
    end
    
    % check for AMSRE flyover data while GPS station measured snow depth
    % values
    saved_amsre = strcat('/discover/nobackup/projects/smos/AMSR2/programs/GPS/', station, '_amsre*');
    station_data_amsre = dir(saved_amsre);
    %YDT, initialize it
    check1 = 0; 
    for aecount = 1:length(station_data_amsre)
        check1 = strcmp( station_data_amsre(aecount).name, strcat(station, '_amsre_newpos.mat') );
        if check1
            break
        end
    end
    

% if there is no GPS derived data with corresponding AMSRE or AMSR2 data, 
% move on to next GPS station
if ~check1 && ~check2
    disp(strcat('No AMSR data for this station:', station))
    
else
    disp(strcat('Doing AMSR data for this station:', station))

    load(strcat( '/discover/nobackup/projects/smos/AMSR2/programs/GPS/',station_data_amsr2(a2count).name));
    % first plot is AMSRE, AMSR2, GPS station, and ground truth (if available)
    % snow depth values vs time
    
    
%     % find nearby SNOTEL data for each day of AMSR-2 observation
%     [dateSNOTEL,~,swe_in] = importSnotelManual(['SNOTEL/snotel_', station, '.txt']);
%     AMSR(1).swe_val = 1;
%     for k = 1:length(AMSR)
%         indSNOTEL = find(dateSNOTEL == floor(AMSR(k).date));
%         AMSR(k).swe_val = str2double(swe_in{indSNOTEL})*2.54/100;
%     end
    
    close
    hfig = figure;
    set(hfig,'Position',[200 0 1600 900]);
    set(hfig, 'PaperPositionMode', 'auto')
    
    subplot(2,4,1:4)
    hold on
    firstdate = datenum(2009,07,01);
    
%     % Plot ground data
        if strcmp(station, 'p041')
            scatter(ground_date, ground(:,8)/100, 'k*')
        end
    % use this flag to only plot AMSR2 data on first iteration of AMSRE plotting
    first = 1;
    
    if check1
        %YDT load(strcat( '/discover/nobackup/projects/smos/AMSR2/MATLAB/GPS/',station_data_amsre(aecount).name));
        load(strcat( '/discover/nobackup/projects/smos/AMSR2/programs/GPS/',station_data_amsre(aecount).name));
        
        % plot AMSRE data, one iteration of the structure at a time
        for j = 1:length(AMSRE)
        
        amsre_snow = AMSRE(j).SD;
        

        % change abnormal negative snow depth values to zero
                if amsre_snow < 0
                    amsre_snow = 0;
                end
            
            scatter(AMSRE(j).date, amsre_snow, 'b^');
            scatter(AMSRE(j).date, AMSRE(j).gps_SD,  'kv');
            
%             if SWE
%                 % find nearby SNOTEL SWE observation when there is an AMSR-E flyover
%                 indSNOTEL = find(dateSNOTEL == floor(AMSRE(j).date));
%                 AMSRE(j).swe_val = str2double(swe_in{indSNOTEL})*2.54/100;
%                 scatter(AMSRE(j).date, AMSRE(j).swe_val*0.3,  'g*');
%             end
        if first && check2
  
            % plot AMSR2 data on same plot, only on first iteration of
            % AMSRE plotting
            
    
        for k = 1:length(AMSR)
           
            if isfield(AMSR(k), 'swe')
                %YDT scatter(AMSR(k).date, AMSR(k).swe_val*0.3,  'g*');
                scatter(AMSR(k).date, AMSR(k).swe*0.3,  'g*');
            end
            
            
            amsr_snow = AMSR(k).SD;
            if amsr_snow < 0
                amsr_snow = 0;
            end
            scatter(AMSR(k).date, amsr_snow, 'r+');
            scatter(AMSR(k).date, AMSR(k).gps_SD,  'kv');

        end
        

            % reset flag to zero to stop plotting of AMSR2 data
            first = 0;
        end
            
        end
        if isfield(AMSR, 'snoteldist')
          
            legend('AMSR-E', 'GPS', 'SNOTEL', 'SNOTEL', 'AMSR-2', 'Location', 'northwest')

        
        else
            if ~strcmp(station, 'p041');
            legend('AMSR-E', 'GPS', 'AMSR-2', 'Location', 'northwest')
        else
            legend('Ground Truth', 'AMSR-E', 'GPS', 'AMSR-2', 'Location', 'northwest')
            end
        end
            
        
    else % there is no AMSRE data, but there may be AMSR2 data
        if check2

        for k = 1:length(AMSR)
            amsr_snow = AMSR(k).SD;
            if amsr_snow < 0
                amsr_snow = 0;
            end
            scatter(AMSR(k).date, amsr_snow, 'r+');
%             errorbar(AMSR(k).date, AMSR(k).gps_SD, AMSR(k).gps_SD_std(1),  'mo');     
            scatter(AMSR(k).date, AMSR(k).gps_SD', 'kv');
            if isfield(AMSR(k), 'swe')
            %YDT scatter(AMSR(k).date, AMSR(k).swe_val*0.3,  'g*');
            scatter(AMSR(k).date, AMSR(k).swe*0.3,  'g*');
            end
        end
    
        end
        if isfield(AMSR, 'snoteldist')
            legend('AMSR-2', 'GPS', 'SNOTEL', 'Location', 'northwest')
        else
            legend('AMSR-2', 'GPS', 'Location', 'northwest')
        end
    end
    

amsre_end = datenum(2011,10,04);
amsr2_beg = datenum(2012,07,02);

% if ~strcmp(station, 'nwot');
%     ylimmax = yliminput;
% else
%     ylimmax = 3;
% end

yrange = get(gca, 'ylim');
ylimmax = yrange(2);

textloc = amsr2_beg+30;
if sum(strcmp(station, midtextbox))
    textloc = amsre_end+30;
end
line([amsre_end amsre_end], [0 ylimmax], 'LineWidth', 3)
line([amsr2_beg amsr2_beg], [0 ylimmax], 'Color', 'Red', 'LineWidth', 3)
xlabel('Time', 'FontSize', 15)
title(strcat('Station Name: ', station), 'FontSize', 15);
ylabel('Snow Depth (m)', 'FontSize', 15)
ylim([0 ylimmax])
set(gca,'fontsize',15)
% find gps lat lon values
if isfield(AMSR, 'gps_lat')
    gpslat = AMSR(1).gps_lat;
    gpslon = AMSR(1).gps_lon;
elseif isfield(AMSRE, 'gps_lat')
    gpslat = AMSRE(1).gps_lat;
    gpslon = AMSRE(1).gps_lon;
end
if isfield(AMSR, 'snotelname')
    text(textloc,ylimmax*ytextbox, {['Station ID: ', station]; ...
    ['State: ', state{st}]; ...
    ['Landcover Type: ', landcover{st}]; ...
%     ['Sturm Classification:', snotel(st).sclass]; ...
    ['GPS Lat: ', num2str(gpslat)]; ...
    ['GPS Lon: ', num2str(gpslon)]; ...
    ['GPS Elevation (m): ', num2str(elevation{st})]; ...
    ['SNOTEL Station Name:', num2str(AMSR(1).snotelname)]; ...
    ['SNOTEL Distance from GPS Station (km):', num2str(AMSR(1).snoteldist)]; ...
    ['SNOTEL Elevation (m):', num2str(AMSR(1).snotelelev)]}, 'EdgeColor','black')
else
    text(textloc,ylimmax*0.8, {['Station ID: ', station]; ...
    ['State: ', state{st}]; ...
    ['Landcover Type: ', landcover{st}]; ...
    ['GPS Lat: ', num2str(gpslat)]; ...
    ['GPS Lon: ', num2str(gpslon)]; ...
    ['GPS Elevation (m): ', num2str(elevation{st})]}, 'EdgeColor','black')
end

%YDT xlim([datenum(2009,1,1), datenum(2015,1,1)])
xlim([datenum(2012,1,1), datenum(2016,1,1)])

%YDT XTick = [datenum(2009:2015,1,1)];
XTick = [datenum(2012:2016,1,1)];
set(gca, 'xtick', XTick)
%YDT set(gca, 'xticklabel', [2009:2015])
set(gca, 'xticklabel', [2012:2016])

%% plot AMSR2 and AMSRE snow depth data vs GPS snow depth data in scatter plot
subplot(245)
axis_length = [0 1];
xlim(axis_length)
ylim(axis_length)
line(axis_length, axis_length, 'Color', 'Magenta')
hold on
first = 1;
%% watch for stations with no AMSRE snow depth data
    if check1
        for j = 1:length(AMSRE)
            amsre_snow = AMSRE(j).SD; 
            if amsre_snow < 0
                amsre_snow = 0;
            end
          
        scatter(AMSRE(j).gps_SD, amsre_snow, 'b^');
        
        if first && check2
            
        % plot AMSR2 data on same plot
        for k = 1:length(AMSR)
            amsr_snow = AMSR(k).SD;
            if amsr_snow < 0
                amsr_snow = 0;
            end
          
        scatter(AMSR(k).gps_SD, amsr_snow, 'r+');
        end

    % reset flag to zero to stop plotting of AMSR2 data
    first = 0;
        end
        
        end
    legend('Linear Fit', 'AMSR-E', 'AMSR-2',  'Location', 'NorthWest')
    
    else % there is no AMSRE data, but there may be AMSR2 data
        if check2
    
        for k = 1:length(AMSR)
            amsr_snow = AMSR(k).SD;
            if amsr_snow < 0
                amsr_snow = 0;
            end
          
        scatter(AMSR(k).gps_SD, amsr_snow, 'r+');
        end
        
        end
        legend('Linear Fit', 'AMSR-2', 'Location', 'NorthWest')
    end
  
title('AMSR Snow Depth vs GPS Snow Depth',  'FontSize', 15);
ylabel('AMSR Snow Depth (m)',  'FontSize', 15)
set(gca,'fontsize',15)
xlabel('GPS Snow Depth (m)',  'FontSize', 15)
axis square


%% next plot of a on-ground picture of the GPS station site
%YDT station_pics_loc = strcat('/discover/nobackup/projects/smos/AMSR2/MATLAB/GPS/GPS_station_pictures/', station, '.jpg');
station_pics_loc = strcat('/discover/nobackup/projects/smos/AMSR2/programs/GPS/GPS_station_pictures/', station, '.jpg');
station_pics = dir(station_pics_loc);

subplot(246)
if isempty(station_pics)
    text(0.25,0.5, 'No Site Picture for this Station')
else
A = imread(station_pics_loc, 'jpg');
image(A)
title('Site Picture',  'FontSize', 15)
end
axis off
axis square
%% next plot is an aerial photo of the GPS station site
subplot(247)
[A, cmap] = imread(strcat('/discover/nobackup/projects/smos/AMSR2/programs/GPS/GPS_station_pictures/', station, '_aerial.jpg'));
image(A(end*1/10:end*9/10,end*1/10:end*9/10,  :))
colormap(cmap)
title('Aerial Image',  'FontSize', 15)
axis off
axis square
%% next plot shows the location of the GPS station in the US
subplot(248)
A = imread(strcat('/discover/nobackup/projects/smos/AMSR2/programs/GPS/GPS_station_pictures/', 'map_', station, '.png'));
image(A)
title('US Location',  'FontSize', 15)
axis off
axis square
%% save figure
% save(strcat('/discover/nobackup/projects/smos/AMSR2/MATLAB/GPS/', station, '_amsr2_SWE'), 'AMSR*');
saveas(hfig,strcat('/discover/nobackup/projects/smos/AMSR2/programs/GPS/station_slides/', station, '_auto'), 'jpg') 
end % end if-statement checking for AMSRE and AMSR2 data

    end
end % end for-loop cycling through all of the GPS stations


