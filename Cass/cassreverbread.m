function Data = cassreverbread(file)
%CASSREVERBREAD Reads a CASS reverberation file
%
% Data = cassreverbread(file)
%
% This program reads the data from a CASS reverberation file (an 
% unformatted sequential binary file).
%
% Input variables:
%
%   file:   CASS reverb file name
%
% Output variables:
%
%   Data:   1 x 1 structure with the following fields:
%
%           header:         21 x 1 cell array, see cassHeaders.xls for
%                           details 
%
%           times:          times (s) 
%
%           components:     This refers to the 5 reverberation components,
%                           corresponding to surface, bottom, volumne,
%                           fathometer, and total.  Note: Reverberation
%                           files may hold Doppler spectra instead of
%                           reverberation components; this program should
%                           be able to read files such as these as well,
%                           but I haven't tried.       
%            
%           bearingAngles:  bearing angles (rad)
%
%           frequencies:    frequencies (Hz)
%
%           reverberation:  n x m cell array of reverberation values (dB),
%                           where n is the number of bearing angles and m
%                           is the number of  frequencies.  Each element is
%                           a k x p array, where k is the number of times
%                           and p is the number of components.

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

if ~strcmp(header{1}, 'REVERBER')
    error('This is not a CASS reverberation file');
end

%---------------------------
% Read times, components,
% bearing angles, and 
% frequencies
%---------------------------

% Times (s)

if header{18} > 0
    recordSize = fread(fid, 1, 'int');
    if recordSize/8 ~= header{18}
        error('Record indicator mismatch (times)');
    end
    times = fread(fid, header{18}, 'double');
    recordEnd = fread(fid, 1, 'int');
    if recordSize ~= recordEnd
        error('Record indicator mismatch (times)');
    end
else
    times = [];
end

% Componenets (bottom, surface, volume, fathometer, total)

if header{19} > 0
    recordSize = fread(fid, 1, 'int');
    if recordSize/8 ~= header{19}
        error('Record indicator mismatch (components)');
    end
    components = fread(fid, header{19}, 'double');
    recordEnd = fread(fid, 1, 'int');
    if recordSize ~= recordEnd
        error('Record indicator mismatch (components)');
    end
else
    components = [];
end

% Bearing angles (rad)

if header{20} > 0
    recordSize = fread(fid, 1, 'int');
    if recordSize/8 ~= header{20}
        error('Record indicator mismatch (bearing angles)');
    end
    bearingAngles = fread(fid, header{20}, 'double');
    recordEnd = fread(fid, 1, 'int');
    if recordSize ~= recordEnd
        error('Record indicator mismatch (bearing angles)');
    end
else
    bearingAngles = [];
end

% Frequencies (Hz)

if header{21} > 0
    recordSize = fread(fid, 1, 'int');
    if recordSize/8 ~= header{21}
        error('Record indicator mismatch (frequencies)');
    end
    frequencies = fread(fid, header{21}, 'double');
    recordEnd = fread(fid, 1, 'int');
    if recordSize ~= recordEnd
        error('Record indicator mismatch (frequencies)');
    end
else
    frequencies = [];
end

%---------------------------
% Read reverberation
%---------------------------

reverb = cell(header{20}, header{21});
for ibrn = 1:header{20}
    for ifrq = 1:header{21}
        reverbMp = zeros(header{18}, header{19});
        for icmp = 1:header{19}
            recordSize = fread(fid, 1, 'int');
            reverbMp(:,icmp) = fread(fid, header{18}, 'double');
            recordEnd = fread(fid, 1, 'int');
            if recordSize ~= recordEnd
                error('Record indicator mismatch (reverberation)');
            end
        end
        
        % Convert from microPascals to dB (RVBr to RVBo)
        
        reverbDb = repmat(-1000, size(reverbMp));
        reverbDb(reverbMp ~= 0) = 20 .* log10(reverbMp(reverbMp ~= 0));
        reverb{ibrn, ifrq} = reverbDb;
        
    end
end
    
fclose(fid);

%---------------------------
% Save to structure
%---------------------------

Data.header        = header;
Data.times         = times;
Data.components    = components;
Data.bearingAngles = bearingAngles;
Data.frequencies   = frequencies;
Data.reverberation = reverb;

