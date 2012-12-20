function sedcommands = casssedtext(range, rmz, rangeUnit)
%CASSSEDTEXT Creates CASS sediment commands for 2D system
%
% sedcommands = casssedtext(range, rmz, rangeUnit)
%
% Creates CASS sediment commands for a two-dimensional environment, i.e.
% range vs depth simulation.  The commands direct CASS to increment the
% environment variable at each input range and changes the enironment
% sediment type.  When CASS runs, it will assume a linear gradient between
% changes.
%
% Input variables:
%
%   range:          vector of range values
%
%   rmz:            sediment mean grain size (RMZ) values, vector of same
%                   length as range 
%
%   rangeUnit:      'CM', 'IN', 'FT', 'YD', 'M', 'F', 'KFT', 'KYD', 'KM',
%                   'MI', 'N MI', or 'DEG L' 
%
% Output variables:
%
%   sedcommands:    n x 1 cell array of strings holding text of properly
%                   formattted CASS sediment commands
%
% Example:
%
% a = casssedtext([0 10 11 20 21], [1.5 1.5 9.0 9.0 1.0], 'm')
% 
% a = 
% 
%     'ENVIRONMENT X COORDINATE              = 0.00 M'
%     'BOTTOM SEDIMENT GRAIN SIZE INDEX      = 1.5'
%     'INCREMENT ENVIRONMENT NUMBER'
%     'ENVIRONMENT X COORDINATE              = 10.00 M'
%     'BOTTOM SEDIMENT GRAIN SIZE INDEX      = 1.5'
%     'INCREMENT ENVIRONMENT NUMBER'
%     'ENVIRONMENT X COORDINATE              = 11.00 M'
%     'BOTTOM SEDIMENT GRAIN SIZE INDEX      = 9.0'
%     'INCREMENT ENVIRONMENT NUMBER'
%     'ENVIRONMENT X COORDINATE              = 20.00 M'
%     'BOTTOM SEDIMENT GRAIN SIZE INDEX      = 9.0'
%     'INCREMENT ENVIRONMENT NUMBER'
%     'ENVIRONMENT X COORDINATE              = 21.00 M'
%     'BOTTOM SEDIMENT GRAIN SIZE INDEX      = 1.0'

%-----------------------------
% Check input
%-----------------------------

if ~isvector(range) || ~isvector(rmz) || length(range) ~= length(rmz)
    error('range and rmz must be vectors of the same length');
end

rangeUnit = upper(rangeUnit);
unitOptions = {'CM','IN','FT','YD','M','F','KFT','KYD','KM','MI','N MI','DEG L'};
if ~ismember(rangeUnit, unitOptions)
    error('Invalid range unit');
end

%-----------------------------
% Check input
%-----------------------------

nseds = length(range);

if (nseds == 1)
    sedcommands = cell(1,1);
    sedcommands{1} = sprintf('BOTTOM SEDIMENT GRAIN SIZE INDEX      = %.1f', rmz);
else
    sedcommands = cell(3*(nseds-1) + 2,1);
    sedcommands{1} = sprintf('ENVIRONMENT X COORDINATE              = %.2f %s', range(1), rangeUnit);
    sedcommands{2} = sprintf('BOTTOM SEDIMENT GRAIN SIZE INDEX      = %.1f', rmz(1));
    for i = 2:nseds
        sedcommands{3*(i-2)+2+1} = 'INCREMENT ENVIRONMENT NUMBER'; 
        sedcommands{3*(i-2)+2+2} = sprintf('ENVIRONMENT X COORDINATE              = %.2f %s', range(i), rangeUnit);
        sedcommands{3*(i-2)+2+3} = sprintf('BOTTOM SEDIMENT GRAIN SIZE INDEX      = %.1f', rmz(i));
    end
end