function param = sonarparams(varargin)
%SONARPARAMETERS Loads cell array of saved sonar parameters
%
% param = sonarParameters
% param = sonarParameters(sonarname)
% param = sonarParameters(sonarname, paramname)
%
% This function returns various paramters associated with different types
% of sonar.
%
% Input variables:
%
%   sonarname:  name of sonar, must match a fieldname in main structure
%               (listed below)
%
%   paramname:  name of parameter, must match fieldname in
%               sonar substructure (listed below)
%
% Output variable:
%
%   param:      If no input variables are provided, returns entire
%               structure described below.  If a sonar variable is
%               provided, only the substructure associated with that sonar
%               is returned.  If both a sonar name and parameter name are
%               provided, only the individual parameter is returned.
%
%               The main structure is a 1 x 1 struct with fieldnames
%               corresponding to the sonar types stored in this file.
%               These fields are subject to change; call without any input
%               parameters to see currently stored sonars.
%
%               Each sonar field holds a 1 x 1 struct with the following
%               fields.  All dB units are re 1 micropascal.  Unless
%               specified, all parameters can be either scalars or vectors.
%
%               maximumRange:                   meters
%
%               detectionThreshold:             dB
%
%               receiverDeAngles:               degrees
%
%               transmitterDeAngles:            degrees
%
%               nActiveReceivers:               number receivers used at
%                                               one time
%
%               pulseWidth:                     seconds
%
%               frequencies:                    Hz
%
%               receiverVerticalBeamwidth:      degrees 
%
%               receiverHorizontalBeamwidth:    degrees
%
%               transmitterVerticalBeamwidth:   degrees
%
%               transmitterHorizontalBeamwidth: degrees
%
%               receiverBeamPattern:            n x 2 array, [angle level],
%                                               in degrees and dB,
%                                               repectively
%
%               transmitterBeamPattern:         n x 2 array, [angle level],
%                                               in degrees and dB,
%                                               repectively
%
%               bandwidth:                      Hz    
%
%               receiverNoise:                  degrees            
%
%               sourceLevel:                    dB
%
%               maximumTowDepth:                meters 
%
%               hullDepth:                      meters 
%
%               minimumDistanceFromBottom:      meters

% Copyright 2006 Kelly Kearney

%--------------------------
% Sonar parameters, saved
% to a structure
%--------------------------

% Template for future additions
% Sonar.(name).maximumRange                   = 
% Sonar.(name).detectionThreshold             = 
% Sonar.(name).receiverDeAngles               = 
% Sonar.(name).transmitterDeAngles            = 
% Sonar.(name).nActiveReceivers               = 
% Sonar.(name).pulseWidth                     = 
% Sonar.(name).frequencies                    = 
% Sonar.(name).receiverVerticalBeamwidth      = 
% Sonar.(name).receiverHorizontalBeamwidth    = 
% Sonar.(name).transmitterVerticalBeamwidth   = 
% Sonar.(name).transmitterHorizontalBeamwidth = 
% Sonar.(name).receiverBeamPattern            = 
% Sonar.(name).transmitterBeamPattern         = 
% Sonar.(name).bandwidth                      = 
% Sonar.(name).receiverNoise                  = 
% Sonar.(name).sourceLevel                    = 
% Sonar.(name).maximumTowDepth                = 
% Sonar.(name).hullDepth                      = 
% Sonar.(name).minimumDistanceFromBottom      =

name = 'klein3000';
Sonar.(name).maximumRange                   = 75;
Sonar.(name).detectionThreshold             = 0;
Sonar.(name).receiverDeAngles               = 0; % tilt included in beam pattern
Sonar.(name).transmitterDeAngles            = 0;
Sonar.(name).nActiveReceivers               = 1;
Sonar.(name).pulseWidth                     = .0001;
Sonar.(name).frequencies                    = 455000;
Sonar.(name).receiverVerticalBeamwidth      = [];
Sonar.(name).receiverHorizontalBeamwidth    = [];
Sonar.(name).transmitterVerticalBeamwidth   = [];
Sonar.(name).transmitterHorizontalBeamwidth = [];
Sonar.(name).receiverBeamPattern            = [...
                                                -90.0000 -300.0000
                                                -11.0000 -300.0000
                                                -10.0000    0.0000
                                                 30.0000    0.0000
                                                 31.0000 -300.0000
                                                 90.0000 -300.0000];
Sonar.(name).transmitterBeamPattern         = [...
                                                -90.0000 -300.0000
                                                -11.0000 -300.0000
                                                -10.0000    0.0000
                                                 30.0000    0.0000
                                                 31.0000 -300.0000
                                                 90.0000 -300.0000];
Sonar.(name).bandwidth                      = []; %??
Sonar.(name).receiverNoise                  = 0; 
Sonar.(name).sourceLevel                    = 220;
Sonar.(name).maximumTowDepth                = []; %??
Sonar.(name).hullDepth                      = 0;
Sonar.(name).minimumDistanceFromBottom      = 10;

%--------------------------
% Return requested 
% parameter
%-------------------------- 

if nargin == 0
    param = Sonar;
elseif nargin == 1
    sonarname = varargin{1};
    if ~isfield(Sonar, sonarname)
        error('Sonar name not found');
    end
    param = Sonar.(sonarname);
elseif nargin == 2
    sonarname = varargin{1};
    paramname = varargin{2};
    if ~isfield(Sonar, sonarname)
        error('Sonar name not found');
    end
    if ~isfield(Sonar.(sonarname), paramname)
        error('Parameter not found');
    end
    param = Sonar.(sonarname).(paramname);
end
    
        
    


