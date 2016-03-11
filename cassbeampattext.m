function bptable = cassbeampattext(rang, rlevel, tang, tlevel)
%CASSBEAMPATTEXT Creates CASS beam pattern tables
%
% bptable = cassbeampattext(rang, rlevel, tang, tlevel)
%
% This function creates beam pattern tables for a CASS input file.
%
% Input variables:
%  
%   rang:       angles for receiver beam pattern, positive down (degrees)
%
%   rlevel:     beam pattern level corresponding to each rang value (dB)
%
%   tang:       angles for transmitter beam pattern, positive down
%               (degrees) 
%
%   tlevel:     beam pattern level corresponding to each tang value (dB)
%
% Output variables:
%
%   bptable:    n x 1 cell array of strings holding text of properly
%               formatted CASS receiver and transmitter beam pattern tables
%
% Example:
%
% a = cassbeampattext([-90:30:90], 1:7,  ...
%                     [-60 -10 0 20 60], [-300 0 0 0 -300])
% 
% a = 
% 
%     'RECEIVER BEAM PATTERN MODEL = TABLE'
%     'RECEIVER BEAM PATTERN TABLE'
%     'DEG       DB'
%     '  -90.0000    1.0000'
%     '  -60.0000    2.0000'
%     '  -30.0000    3.0000'
%     '    0.0000    4.0000'
%     '   30.0000    5.0000'
%     '   60.0000    6.0000'
%     '   90.0000    7.0000'
%     'EOT'
%     'TRANSMITTER BEAM PATTERN MODEL = TABLE'
%     'TRANSMITTER BEAM PATTERN TABLE'
%     'DEG       DB'
%     '  -60.0000 -300.0000'
%     '  -10.0000    0.0000'
%     '    0.0000    0.0000'
%     '   20.0000    0.0000'
%     '   60.0000 -300.0000'
%     'EOT'

% Copyright 2005 Kelly Kearney

%-----------------------------
% Check input
%-----------------------------

if ~isvector(rang) || ~isvector(rlevel) || length(rang) ~= length(rlevel)
    error('rang and rlevel must be vectors of the same length');
end

if ~isvector(tang) || ~isvector(tlevel) || length(tang) ~= length(tlevel)
    error('tang and tlevel must be vectors of the same length');
end

%-----------------------------
% Create table
%-----------------------------

recHeader = {...
'RECEIVER BEAM PATTERN MODEL = TABLE'
'RECEIVER BEAM PATTERN TABLE'
'DEG       DB'
};

transHeader = {...
'TRANSMITTER BEAM PATTERN MODEL = TABLE'
'TRANSMITTER BEAM PATTERN TABLE'
'DEG       DB'
};

recTable = cell(length(rang),1);
for irec = 1:length(rang)
    recTable{irec} = sprintf('%10.4f%10.4f', rang(irec), rlevel(irec));
end

transTable = cell(length(tang),1);
for itrans = 1:length(tang)
    transTable{itrans} = sprintf('%10.4f%10.4f', tang(itrans), tlevel(itrans));
end

bptable = [recHeader; recTable; {'EOT'}; transHeader; transTable; {'EOT'}];
