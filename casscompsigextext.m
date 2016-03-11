function secommands = casscompsigextext(recTilt, transTilt, eigFile)
%CASSCOMPSIGEXTEXT Creates CASS compute signal excess commands
%
% Creates CASS compute signal excess commands for specified receiver
% and tranmitter angles and a previously generated eigenray file.  The
% commands will direct signal excess output to sequentially named
% reverberation files (SE#.DAT), with one file per tilt angle combination.
% This program assumes reverberation files have already been created for
% each tilt angle, and that the reverb files are named REV1.DAT, REV2.DAT,
% etc (as can be created using casscomprevtext.m).     
%
% Input variables:
%
%   recTilt:    receiver tilt angles (deg, positive down), vector
%
%   transTilt:  tranmitter tilt angles corresponding to receiver angles
%
%   eigFile:    target depth eigenray file
%
% Output variables:
%
%   secommands: n x 1 cell array of strings holding properly formatted CASS
%               signal excess commands
%
% Example:
%
% a = casscompsigextext([0 4], [4 4], 'TRG')
% 
% a = 
% 
%     'REVERBERATION FILE                    = REV1'
%     'SIGNAL EXCESS FILE                    = SE1'
%     'RECEIVER TILT ANGLE                   = 0 DEG'
%     'TRANSMITTER TILT ANGLE                = 4 DEG'
%     'EIGENRAY FILE                         = TRG'
%     'COMPUTE ACTIVE SIGNAL EXCESS'
%     'REVERBERATION FILE                    = REV2'
%     'SIGNAL EXCESS FILE                    = SE2'
%     'RECEIVER TILT ANGLE                   = 4 DEG'
%     'TRANSMITTER TILT ANGLE                = 4 DEG'
%     'EIGENRAY FILE                         = TRG'
%     'COMPUTE ACTIVE SIGNAL EXCESS'

% Copyright 2005 Kelly Kearney

%-----------------------------
% Check input
%-----------------------------

if ~isvector(recTilt) || ~isvector(transTilt) || length(recTilt) ~= length(transTilt)
    error('recTilt and transTilt must be vectors of the same length');
end

if ~ischar(eigFile)
    error('eigFile must be a string');
end

%-----------------------------
% Create commands
%-----------------------------

secommands = cell(0);
for itilt = 1:length(recTilt)
    newSe = {...
    sprintf('REVERBERATION FILE                    = REV%d', itilt)
    sprintf('SIGNAL EXCESS FILE                    = SE%d', itilt)
    sprintf('RECEIVER TILT ANGLE                   = %d DEG', recTilt(itilt));
    sprintf('TRANSMITTER TILT ANGLE                = %d DEG', transTilt(itilt));
    sprintf('EIGENRAY FILE                         = %s', eigFile)
    'COMPUTE ACTIVE SIGNAL EXCESS'
    };
    secommands = [secommands; newSe];
end