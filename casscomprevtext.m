function revcommands = casscomprevtext(recTilt, transTilt, surfEigFile, botEigFile)
%CASSCOMPREVTEXT Creates CASS compute reverb commands
%
% Creates CASS compute reverberation commands for specified receiver
% and tranmitter angles and previously generated eigenray files.  The
% commands will direct reverberation output to sequentially named
% reverberation files (REV#.DAT), with one file per tilt angle combination.
%
% Input variables:
%
%   recTilt:        receiver tilt angles (deg, positive down), vector
%
%   transTilt:      tranmitter tilt angles corresponding to receiver angles
%
%   surfEigFile:    name of surface target eigenray file (without .DAT
%                   extension)  
%
%   botEigFile:     name of bottom target eigenray file (without .DAT
%                   extension) 
%
% Output variables:
%
%   revcommands:    n x 1 cell array of strings holding properly formatted
%                   CASS reverberation commands 
%
% Example: 
%
% a = casscomprevtext([0 4], [4 4], 'SRF', 'BOT')
% 
% a = 
% 
%     'REVERBERATION FILE                    = REV1'
%     'RESET REVERBERATION'
%     'TRANSMITTER TILT ANGLE                = 4 DEG'
%     'RECEIVER TILT ANGLE                   = 0 DEG'
%     'TARGET DEPTH                          = SURFACE'
%     'EIGENRAY FILE                         = SRF'
%     'COMPUTE SURFACE REVERBERATION'
%     'TARGET DEPTH                          = BOTTOM'
%     'EIGENRAY FILE                         = BOT'
%     'COMPUTE BOTTOM REVERBERATION'
%     'REVERBERATION FILE                    = REV2'
%     'RESET REVERBERATION'
%     'TRANSMITTER TILT ANGLE                = 4 DEG'
%     'RECEIVER TILT ANGLE                   = 4 DEG'
%     'TARGET DEPTH                          = SURFACE'
%     'EIGENRAY FILE                         = SRF'
%     'COMPUTE SURFACE REVERBERATION'
%     'TARGET DEPTH                          = BOTTOM'
%     'EIGENRAY FILE                         = BOT'
%     'COMPUTE BOTTOM REVERBERATION'   

% Copyright 2005 Kelly Kearney

%-----------------------------
% Check input
%-----------------------------

if ~isvector(recTilt) || ~isvector(transTilt) || length(recTilt) ~= length(transTilt)
    error('recTilt and transTilt must be vectors of the same length');
end

if ~ischar(surfEigFile) || ~ischar(botEigFile)
    error('surfEigFile and botEigFile must be strings');
end

%-----------------------------
% Create commands
%-----------------------------

revcommands = cell(0);
for itilt = 1:length(recTilt)
    newReverb = {...
    sprintf('REVERBERATION FILE                    = REV%d', itilt)
    'RESET REVERBERATION'
    sprintf('TRANSMITTER TILT ANGLE                = %d DEG', transTilt(itilt))
    sprintf('RECEIVER TILT ANGLE                   = %d DEG', recTilt(itilt))
    'TARGET DEPTH                          = SURFACE'
    sprintf('EIGENRAY FILE                         = %s', surfEigFile)
    'COMPUTE SURFACE REVERBERATION'
    'TARGET DEPTH                          = BOTTOM'
    sprintf('EIGENRAY FILE                         = %s', botEigFile)
    'COMPUTE BOTTOM REVERBERATION'
    };
    revcommands = [revcommands; newReverb];
end