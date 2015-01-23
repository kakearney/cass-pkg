function runcass(varargin)
%RUNCASS Runs CASS model executable
%
% runcass
% runcass(filename)
%
% If run with no inputs, this function simply calls the CASS executable.
% If a file is provided, runcass copies that file to INPUT.DAT and makes
% sure a BATCH.DAT file exists brforing running CASS.  
%
% In order to be more user friendly, the location of the CASS executable is
% hardcoded into this function (first line of code).  It will need to be
% updated to agree with each computer on which this function is used.
%
% Input variables:
%
%   filename: file to used as INPUT.DAT for CASS run

% Copyright 2005 Kelly Kearney

cassExecutable = 'D:\Models\CASS32\CASS_V3.exe';

if nargin == 0
    system(cassExecutable);
elseif nargin == 1
    filename = varargin{1};
    copyfile(filename, 'INPUT.DAT');
    if ~exist('BATCH.DAT', 'file')
        fid = fopen('BATCH.DAT', 'wt');
        fprintf(fid, 'BATCH MODE = ON');
        fclose(fid);
    end
    system(cassExecutable);
end

% if ~exist('CASS.OK', 'file')
%     disp('Warning: No CASS.OK file found');
% end