function [lat36, lon36] = latlon_amsre2(h5file)

% read in lat-lon values from AMSR2 hdf5 file
lat89A = h5read(h5file, ...
    '/Latitude of Observation Point for 89A')';
lon89A = h5read(h5file, ...  
    '/Longitude of Observation Point for 89A')';
lat89A = double(lat89A);
lon89A = double(lon89A);
%% convert 89 Ghz lat-long values to 36 Ghz resolution in method provided by JAXA
% this method is extremely computationally expensive

% data = h5info(h5file);
% vector = '[3][6]\S*';
% a1str = regexp(data.Attributes(115).Value, vector, 'match');
% a2str = regexp(data.Attributes(116).Value, vector, 'match');
% 
% a1str = a1str{1}{1};
% a2str = a2str{1}{1};
% 
% if ~strcmp('36G',a1str(1:3)) || ~strcmp('36G',a2str(1:3))
%     disp('Wrong coefficient')
%     keyboard
% end
% 
% index1 = find(a1str=='-');
% index2 = find(a2str=='-');
% A1 = str2double(a1str(index1(end)+1:end));
% A2 = str2double(a2str(index2(end)+1:end));


%% convert 89 Ghz lat-long values to 36 Ghz resolution using shortcut that provides 
 % very close results much faster
 
 % convert 89 Ghz lat-long values to 36 Ghz resolution by 
 % averaging neighboring columns in lat-lon matrices
 
 % e.g. matrices go from size(lat89) = [a,b] to size(lat36) = [a,b/2]
 
 % initialize 36 GHz lat-lon values as zeros
L89 = size(lat89A,1);
w89 = size(lat89A,2);
lat36 = zeros(L89,w89/2);
lon36 = lat36;

for i = 1:w89/2
        %initialize arrays to make parallel computing possible
%             lonvec1 = lon89A(:,2*i-1);
%             lonvec2 = lon89A(:,2*i);
%             
%             latvec1 = lat89A(:,2*i-1);
%             latvec2 = lat89A(:,2*i);
    
    for j = 1:L89
        
% %      
        % since latitude values are from [-90,90], there are no problems
        % with averaging
        lat36(j,i) = (lat89A(j,2*i-1) + lat89A(j,2*i))/2;
        
        % for longitudes, for neighboring points that are -180 and 180, 
        % just take first point to avoid averaging error
        if ((lon89A(j,2*i-1) * lon89A(j,2*i)) > 0) || (abs((lon89A(j,2*i-1) * lon89A(j,2*i))) < 100)
            
            lon36(j,i) = (lon89A(j,2*i-1) + lon89A(j,2*i))/2;
        else
            lon36(j,i) = lon89A(j,2*i-1);
        end
    end
end

%% more of JAXA's way
% (if trying to use this method, comment out previous two end statements so
% the following code is inside the two for loops

%             P1 = [ cosd(lonvec1(j)) * cosd(latvec1(j)); ...
%                    sind(lonvec1(j)) * cosd(latvec1(j)); ...
%                    sind(latvec1(j)) ] ;
%             P2 = [ cosd(lonvec2(j)) * cosd(latvec2(j));  ...
%                    sind(lonvec2(j)) * cosd(latvec2(j)); ...
%                    sind(latvec2(j)) ] ;
%             ex = P1;
%             ez = cross(P1,P2)/norm(cross(P1,P2));
%             ey = cross(ez, ex);
%             theta = acosd(dot(P1,P2));
%             Pt = cosd(A2*theta) * (cosd(A1*theta) * ex + sind(A1*theta) * ey) + ...
%                     sind(A2*theta) * ez;
%                 
%             lat36(j,i) = asind(Pt(3));
%             
%             % if original latitude is between [90,270] deg, 
%             % make lat36 likewise
%             if latvec1(j) > 90
%                 lat36(j,i) = 180 - lat36(j,i);
%             elseif latvec1(j) < -90
%                 lat36(j,i) = -180 - lat36(j,i);
%             end  
%               
%             lon36(j,i) = acosd( Pt(1) / cosd(lat36(j,i)) );
%             
%             % if original longitude is between [-180,0] deg, 
%             % make lon36 likewise
%             if lonvec1(j) < 0
%                 lon36(j,i) = - lon36(j,i);
%             end
% 
%     end
% end
% 
