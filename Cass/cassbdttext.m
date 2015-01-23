function bdt = cassbdttext(x, y, depth, rangeUnit, depthUnit)
%CASSBDTTEXT Create a CASS bottom depth table
%
% bdt = cassbdttext(x, y, depth, rangeUnit, depthUnit)
%
% This function generates a CASS bottom depth table.
%
% Input variables:
%
%   x:          x values, vector or m x n meshgrid-style array 
%
%   y:          y values, vector or m x n meshgrid-style array.  Can also
%               be an empty array; y will be set to zero for all points (2D
%               scenario)   
%
%   depth:      depth values corresponding to x and y coordinates.
%
%   rangeUnit:  'CM', 'IN', 'FT', 'YD', 'M', 'F', 'KFT', 'KYD', 'KM', 'MI',
%               'N MI', 'DEG L', or 'DEG'.  If 'DEG' is chosen, x values
%               are considered latitudes and y values are longitudes.
%
%   depthUnit:  same options as rangeUnit, minus 'DEG'
%
% Output variables:
%
%   bdt:        n x 1 cell array of strings holding text of a properly
%               formattted CASS bottom depth table
%
% Example:
%
% [x,y] = meshgrid(1:2);
% z = 10*rand(size(x));
% a = cassbdttext(x,y,z,'km','m')
% 
% a = 
% 
%     'BOTTOM DEPTH TABLE'
%     'KM        KM        M         '
%     '    1.0000    1.0000    0.1779'
%     '    2.0000    1.0000    3.5254'
%     '    1.0000    2.0000    8.7794'
%     '    2.0000    2.0000    7.2214'
%     'EOT'

% Copyright 2005 Kelly Kearney

%-----------------------------
% Check input
%-----------------------------

if isempty(y)
    y = zeros(size(x));
end

if ~isequal(size(x), size(y), size(depth))
    error('Size of x, y, and depth must match');
end

unitOptions = {'CM','IN','FT','YD','M','F','KFT','KYD','KM','MI','N MI','DEG L', 'DEG'};
rangeUnit = upper(rangeUnit);
depthUnit = upper(depthUnit);
if ~ismember(rangeUnit, unitOptions)
    error('Invalid unit for range');
end
if ~ismember(depthUnit, unitOptions(~strcmp(unitOptions,'DEG')))
    error('Invalid unit for depth');
end

%-----------------------------
% Table header
%-----------------------------

bdtHeader = {...
   'BOTTOM DEPTH TABLE';
   sprintf('%-10s%-10s%-10s', rangeUnit, rangeUnit, depthUnit)
   };

%-----------------------------
% Table body
%-----------------------------

x = roundn(x, -4);
y = roundn(y, -4);
depth = roundn(depth, -4);
xyz = [x(:) y(:) depth(:)];
xyz = sortrows(xyz, [2 1]);
isDuplicate = (diff(xyz(:,1)) == 0) & (diff(xyz(:,2)) == 0);
xyz(isDuplicate,:) = [];

formatText = @(a) sprintf('%10.4f%10.4f%10.4f', a);
bdtBody = cellfun(formatText, num2cell(xyz,2), 'UniformOutput', false);
bdtBody = bdtBody(:);

bdt = [bdtHeader; bdtBody; {'EOT'}];