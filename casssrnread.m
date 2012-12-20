function DATA = casssrnread(filebasename)
%CASSSRNREAD Reads CASS signal-reverberation-noise files
%
% DATA = casssrnread(filebasename)
%
% This program reads the data from CASS srn files (unformatted sequential
% binary files).
%
% Input variables:
%
%   filebasename:   base name of CASS signal-reverberation-noise filenames
%                   (without the #.DAT extensions, where # is 1, 2, or 3)  
%
% Output variables:
%
%   Data:   1 x 1 structure with the following fields: 
%
%           header:         21 x 1 cell array, see cassHeaders.xls for details
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
%           signal:         n x m cell array of signal values (dB), where n
%                           is the number of bearing angles and m is the
%                           number of frequencies. Each element is a k x p
%                           array, where k is the number of depths and p is
%                           the number of ranges.
%
%           reverberation:  n x m cell array of reverberation values (dB),
%                           where n is the number of bearing angles and m
%                           is the number of frequencies. Each element is a
%                           k x p array, where k is the number of depths
%                           and p is the number of ranges.  
%
%           noise:          n x m cell array of noise values (dB), where n
%                           is the number of bearing angles and m is the
%                           number of frequencies. Each element is a k x p
%                           array, where k is the number of depths and p is
%                           the number of ranges.

% Copyright 2005 Kelly Kearney

file1 = [filebasename '1.DAT'];
file2 = [filebasename '2.DAT'];
file3 = [filebasename '3.DAT'];

fid = fopen(file1);

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

if ~strcmp(header{1}, 'SRN')
    error('This is not a CASS srn file');
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
% Read signal
%---------------------------

dataDims = [header{20} header{21} header{19} header{18}];
if dataDims(3) == 0
    if ~isempty(header{5})
        dataDims(3) = 1;
    end
end

[blah, dataOrder] = ismember(header{2}, 'BFDR');
dataDims = dataDims(dataOrder);

startDataPosition = ftell(fid);

% Read all data into 4-D array

allSignal = zeros(dataDims);

for ione = 1:dataDims(1)
    for itwo = 1:dataDims(2)
        for ithree = 1:dataDims(3)
            recordSize = fread(fid, 1, 'int');
            if recordSize/8 ~= dataDims(4)
                error('Record indicator does not match header (signal)');
            end
            allSignal(ione, itwo, ithree, :) = fread(fid, dataDims(4), 'double');
            recordEnd = fread(fid, 1, 'int');
            if recordSize ~= recordEnd
                error('Record indicator start/end mismatch (signal)');
            end
        end
    end
end
        
% Permute into bearAng x freq x depth x range

allSignalReordered = permute(allSignal, dataOrder);

% Break into cell array and convert from micropascals to dB

signal = cell(header{20}, header{21});
for ibearAng = 1:header{20}
    for ifreq = 1:header{21}
        signalMpa = squeeze(allSignalReordered(ibearAng, ifreq, :, :));
        if size(signalMpa,2) == 1  % If only one depth, dimension squeezed out
            signalMpa = signalMpa';
        end
        signalDb = repmat(-1000, size(signalMpa));
        signalDb(signalMpa ~= 0) = 20 * log10(signalMpa(signalMpa ~= 0));
        signal{ibearAng, ifreq} = signalDb;
    end
end

fclose(fid);

%---------------------------
% Read reverberation
%---------------------------

fid = fopen(file2);
fseek(fid, startDataPosition, 'bof');

% Read all data into 4-D array

allReverb = zeros(dataDims);

for ione = 1:dataDims(1)
    for itwo = 1:dataDims(2)
        for ithree = 1:dataDims(3)
            recordSize = fread(fid, 1, 'int');
            if recordSize/8 ~= dataDims(4)
                error('Record indicator does not match header (reverb)');
            end
            allReverb(ione, itwo, ithree, :) = fread(fid, dataDims(4), 'double');
            recordEnd = fread(fid, 1, 'int');
            if recordSize ~= recordEnd
                error('Record indicator start/end mismatch (reverb)');
            end
        end
    end
end
        
% Permute into bearAng x freq x depth x range

allReverbReordered = permute(allReverb, dataOrder);

% Break into cell array and convert from micropascals to dB

reverberation = cell(header{20}, header{21});
for ibearAng = 1:header{20}
    for ifreq = 1:header{21}
        reverbMpa = squeeze(allReverbReordered(ibearAng, ifreq, :, :));
        if size(reverbMpa,2) == 1  % If only one depth, dimension squeezed out
            reverbMpa = reverbMpa';
        end
        reverbDb = repmat(-1000, size(reverbMpa));
        reverbDb(reverbMpa ~= 0) = 20 * log10(reverbMpa(reverbMpa ~= 0));
        reverberation{ibearAng, ifreq} = reverbDb;
    end
end

fclose(fid);

%---------------------------
% Read noise
%---------------------------

fid = fopen(file3);
fseek(fid, startDataPosition, 'bof');

% Read all data into 4-D array

allNoise = zeros(dataDims);

for ione = 1:dataDims(1)
    for itwo = 1:dataDims(2)
        for ithree = 1:dataDims(3)
            recordSize = fread(fid, 1, 'int');
            if recordSize/8 ~= dataDims(4)
                error('Record indicator does not match header (noise)');
            end
            allNoise(ione, itwo, ithree, :) = fread(fid, dataDims(4), 'double');
            recordEnd = fread(fid, 1, 'int');
            if recordSize ~= recordEnd
                error('Record indicator start/end mismatch (noise)');
            end
        end
    end
end
        
% Permute into bearAng x freq x depth x range

allNoiseReordered = permute(allNoise, dataOrder);

% Break into cell array and convert from micropascals to dB

noise = cell(header{20}, header{21});
for ibearAng = 1:header{20}
    for ifreq = 1:header{21}
        noiseMpa = squeeze(allNoiseReordered(ibearAng, ifreq, :, :));
        if size(noiseMpa,2) == 1  % If only one depth, dimension squeezed out
            noiseMpa = noiseMpa';
        end
        noiseDb = repmat(-1000, size(noiseMpa));
        noiseDb(noiseMpa ~= 0) = 20 * log10(noiseMpa(noiseMpa ~= 0));
        noise{ibearAng, ifreq} = noiseDb;
    end
end

fclose(fid);

%---------------------------
% Save to structure
%---------------------------

DATA.header        = header;
DATA.ranges        = ranges;
DATA.depths        = depths;
DATA.bearingAngles = bearingAngles;
DATA.frequencies   = frequencies;
DATA.signal        = signal;
DATA.reverberation = reverberation;
DATA.noise         = noise;