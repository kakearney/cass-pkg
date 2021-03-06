function Data = casspressureread(file)
%CASSPRESSUREREAD Reads a CASS pressure file
%
% Data = casspressureread(file)
%
% This program reads the data from a CASS pressure file (an 
% unformatted sequential binary file) into a Matlab structure Data.
%
% Input variables:
%
%   file:   name of CASS pressure file
%
% Output variables:
%
%   Data:   1 x 1 structure with the following fields:
%
%           header:         21 x 1 cell array, see cassHeaders.xls for 
%                           details
%
%           ranges:         ranges (km)
%
%           depths:         If specific target depths are used, this will
%                           contain an array of depths (km).  If the target
%                           depth was 'BOTTOM' or 'SURFACE' (the fifth
%                           header element shows if either was used), this
%                           will be empty.          
%        
%           bearingAngles:  bearing angles (rad)
%
%           frequencies:    frequencies (Hz)
%
%           pressure:       n x m cell array of signal excess values (dB),
%                           where n is the number of bearing angles and m
%                           is the number of frequencies. Each element is a
%                           k x p array, where k is the number of depths
%                           and p is the number of ranges.      

% Copyright 2005 Kelly Kearney

fid = fopen(file);

%---------------------------
% Read header
%---------------------------

recordSize = fread(fid, 1, 'int');
header = cell(21,1);
header(1:5) = cellstr((char(reshape(fread(fid, 5*8, 'char'), 8, 5)'))); 
header(6:13) = num2cell(fread(fid, 8, 'double')); 
header(14:21) = num2cell(fread(fid, 8, 'int')); 
recordEnd = fread(fid, 1, 'int');
if recordSize ~= recordEnd
    error('Record indicator mismatch (header)');
end

if ~strcmp(header{1}, 'PRESSURE')
    error('This is not a CASS pressure file');
end

%---------------------------
% Read ranges, depths, 
% bearing angles, and 
% frequencies
%---------------------------

% Ranges (km)

if header{18} > 0
    recordSize = fread(fid, 1, 'int');
    if recordSize/8 ~= header{18}
        error('Record indicator does not match header (ranges)');
    end
    ranges = fread(fid, header{18}, 'double');
    recordEnd = fread(fid, 1, 'int');
    if recordSize ~= recordEnd
        error('Record indicator start/end mismatch (ranges)');
    end
else
    ranges = [];
end

% Depths (km)

if header{19} > 0
    recordSize = fread(fid, 1, 'int');
    if recordSize/8 ~= header{19}
        error('Record indicator does not match header (depths)');
    end
    depths = fread(fid, header{19}, 'double');
    recordEnd = fread(fid, 1, 'int');
    if recordSize ~= recordEnd
        error('Record indicator start/end mismatch (depths)');
    end
else
    if isempty(header{5})
        error('Did not find either target depth or target depth flag');
    end
    depths = [];
end

% Bearing angles (rad)

if header{20} > 0
    recordSize = fread(fid, 1, 'int');
    if recordSize/8 ~= header{20}
        error('Record indicator does not match header (bearing angles)');
    end
    bearingAngles = fread(fid, header{20}, 'double');
    recordEnd = fread(fid, 1, 'int');
    if recordSize ~= recordEnd
        error('Record indicator start/end mismatch (bearing angles)');
    end
else
    bearingAngles = [];
end

% Frequencies (Hz)

if header{21} > 0
    recordSize = fread(fid, 1, 'int');
    if recordSize/8 ~= header{21}
        error('Record indicator does not match header (frequencies)');
    end
    frequencies = fread(fid, header{21}, 'double');
    recordEnd = fread(fid, 1, 'int');
    if recordSize ~= recordEnd
        error('Record indicator start/end mismatch (frequencies)');
    end
else
    frequencies = [];
end

%---------------------------
% Read pressure
%---------------------------

dataDims = [header{20} header{21} header{19} header{18}];
if dataDims(3) == 0
    if ~isempty(header{5})
        dataDims(3) = 1;
    end
end

[blah, dataOrder] = ismember(header{2}, 'BFDR');
dataDims = dataDims(dataOrder);

% Read all data into 4-D array

allPressure = zeros(dataDims);

for ione = 1:dataDims(1)
    for itwo = 1:dataDims(2)
        for ithree = 1:dataDims(3)
            recordSize = fread(fid, 1, 'int');
            if recordSize/8 ~= dataDims(4)
                error('Record indicator does not match header (signal excess)');
            end
            allPressure(ione, itwo, ithree, :) = fread(fid, dataDims(4), 'double');
            recordEnd = fread(fid, 1, 'int');
            if recordSize ~= recordEnd
                error('Record indicator start/end mismatch (signal excess)');
            end
        end
    end
end
        
% Permute into bearAng x freq x depth x range

allPressureReordered = permute(allPressure, dataOrder);

% Break into cell array and convert from micropascals to dB (PRSp to
% PRSo)

pressure = cell(header{20}, header{21});
for ibearAng = 1:header{20}
    for ifreq = 1:header{21}
        pressureMpa = squeeze(allPressureReordered(ibearAng, ifreq, :, :));
        if size(pressureMpa,2) == 1  % If only one depth, dimension squeezed out
            pressureMpa = pressureMpa';
        end
        pressureDb = repmat(-1000, size(pressureMpa));
        pressureDb(pressureMpa ~= 0) = 20 * log10(pressureMpa(pressureMpa ~= 0));
        pressure{ibearAng, ifreq} = pressureDb;
    end
end

fclose(fid);

%---------------------------
% Save to structure
%---------------------------

Data.header        = header;
Data.ranges        = ranges;
Data.depths        = depths;
Data.bearingAngles = bearingAngles;
Data.frequencies   = frequencies;
Data.pressure      = pressure;