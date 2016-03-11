function svp = casssvptext(depth, soundSpeed, depthUnit, soundUnit)
%CASSSVPTEXT Creates a CASS sound speed table
%
% svp = casssvptext(depth, soundSpeed, depthUnit, soundUnit)
%
% Creates a CASS sound speed table.
%
% Input variables:
%
%   depth: depth values, vector
%
%   soundSpeed: sound speed values, vector same size as depth
%
%   depthUnit:  'CM', 'IN', 'FT', 'YD', 'M', 'F', 'KFT', 'KYD', 'KM', 'MI',
%               'N MI', or 'DEG L'
%
%   soundUnit:  'CM/S', 'IN/S', 'FT/S', 'YD/S', 'M/S', 'F/S', 'KFT/S',
%               'KYD/S', 'KM/S', 'MI/S', 'KNOTS'
%
% Output variables:
%
%   svp:        n x 1 cell array of strings holding text of a properly
%               formattted CASS sound speed table
%
% Example:
%
% a = casssvptext([0 100], [1500 1480], 'm', 'm/s')
% 
% a = 
% 
%     'SOUND SPEED TABLE'
%     'M         M/S       '
%     '    0.0000 1500.0000'
%     '  100.0000 1480.0000'
%     'EOT'

% Copyright 2005 Kelly Kearney

%-----------------------------
% Check input
%-----------------------------

if ~isvector(depth) || ~isvector(soundSpeed) || length(depth) ~= length(soundSpeed)
    error('Depth and soundSpeed must be vectors of the same length');
end

depthOptions = {'CM','IN','FT','YD','M','F','KFT','KYD','KM','MI','N MI','DEG L'};
soundOptions = {'CM/S','IN/S','FT/S','YD/S','M/S','F/S','KFT/S','KYD/S','KM/S','MI/S','KNOTS'};
depthUnit = upper(depthUnit);
soundUnit = upper(soundUnit);
if ~ismember(depthUnit, depthOptions)
    error('Invalid unit for depth');
end
if ~ismember(soundUnit, soundOptions)
    error('Invalid unit for sound speed');
end

%-----------------------------
% Table header
%-----------------------------

svpHeader = {...
    'SOUND SPEED TABLE';
    sprintf('%-10s%-10s', depthUnit, soundUnit)
    };

%-----------------------------
% Table body
%-----------------------------

depth = roundn(depth,-4);
isduplicate = diff(depth) == 0;
depth(isduplicate) = [];
soundSpeed(isduplicate) = [];

formatText = @(a) sprintf('%10.4f%10.4f', a);
svpBody = cellfun(formatText, num2cell([depth(:) soundSpeed(:)],2), 'UniformOutput', false);
svpBody = svpBody(:);

svp = [svpHeader; svpBody; {'EOT'}];


