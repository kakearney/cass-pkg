function plotrays(varargin)
%PLOTRAYS Plots a CASS raytrace
%
% plotrays(Rays)
% plotrays(Rays, colormethod)
% plotrays(Rays, 'index', indices1, color1, indices2, color2, ...);
%
% Plots a ray structure from a CASS simulation.
%
% Input variables:
%
%   Rays:           1 x n structure with fields range, depth, angle,
%                   startAngle, time, level, phase, srf, btm, upr, lwr, and
%                   comment.  This type of structure is returned by
%                   cassrayread.m   
%
%   colormethod:    'angle', 'time', 'level', 'phase', 'srf', 'btm', 'upr',
%                   'lwr', or 'index'.  If 'index' is used, you must also
%                   provide the ray indices to associate with each color.
%
%   color#:         1 x 3 color vector
%
%   indices#:       vector of ray indices


% Copyright 2005 Kelly Kearney


%--------------------------
% Gather and check input
%--------------------------

if nargin > 2
    if ~strcmp(varargin{2}, 'index')
        error('Too many input arguments');
    end
    Rays = varargin{1};
    colorMethod = varargin{2};
    indexColorGroups = varargin(3:end);
    indexColorGroups = reshape(indexColorGroups, 2, [])';
elseif nargin == 2
    Rays = varargin{1};
    colorMethod = varargin{2};
elseif nargin == 1
    Rays = varargin{1};
    colorMethod = 'none';
else
    error('Wrong number of input arguments');
end

rayFields = {'range', 'depth', 'angle', 'time', 'level', 'phase', 'srf', ...
             'btm', 'upr', 'lwr'};
if ~all(ismember(rayFields, fieldnames(Rays)))
    error('First argument must be a CASS ray structure');
end
    
%--------------------------
% Plot data
%--------------------------


switch colorMethod
    
    case 'none'
        x = catwithnan({Rays.range}, 1);
        y = catwithnan({Rays.depth}, 1);
        plot(x, y);
        
    case 'index'
        hold on;
        for igroup = 1:size(indexColorGroups,1)
            x = catwithnan({Rays(indexColorGroups{igroup,2}).range}, 1);
            y = catwithnan({Rays(indexColorGroups{igroup,2}).depth}, 1);
            plot(x, y, 'Color', indexColorGroups{igroup,1});
        end
            
    otherwise
        x = repmat(catwithnan({Rays.range}, 1), 1, 2);
        y = repmat(catwithnan({Rays.depth}, 1), 1, 2);
        c = repmat(catwithnan({Rays.(colorMethod)}, 1), 1, 2);
        surface(x, y, c, 'FaceColor', 'none', 'EdgeColor', 'interp');
end

set(gca, 'YDir', 'reverse');
set(gcf, 'Renderer', 'zbuffer');
