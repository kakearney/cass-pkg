function EigData = casseigrayread(file)
%CASSEIGRAYREAD Reads eigenray table from a CASS ascii output file
%
% EigData = casseigrayread(file)
%
% Reads an eigenray table (from a CASS PRINT EIGENRAYS command) from a CASS
% ascii output file.  This function will only work on files that hold only
% one eigenray table (i.e. only one PRINT EIGENRAYS command was used in the
% CASS input file).
%
% There are four types of eigenray tables, resulting from differnet
% combinations of inputs to the CASS model:
%
%   Format 1: There is a target depth entry and one frequency
%   Format 2: There is a target depth entry and more than one frequency
%   Format 3: There is a depth table entry and one frequency
%   Format 4: There is a depth table entry and more than one frequency
%
% Input variables:
%
%   file:   CASS ascii output file containing an eigenray table
%
% Output variables:
%
%   EigData:    1 x 1 structure, with fields described below.  Each field
%               holds an n x 1 array, where n is the number of time steps
%               used in the CASS run.
%
%               range:          range (not present in Format 4 tables) 
%   
%               depth:          depth (not present in Format 1 and 2 tables)
%
%               frequency:      frequency (not present in Format 1 and 3
%                               tables)
%
%               time:           time
%
%               sourceAngle:    source angle
%
%               targetAngle:    target angle
%
%               level:          decibel level
%
%               phase:          phase compared to initial phase
%
%               srf:            number of surface reflections to this point
%
%               btm:            number of bottom reflections to this point
%
%               upr:            ??
%
%               lwr:            ??
%
%               ima:            ??

% Copyright 2005 Kelly Kearney

perl('parseeigenraydata.pl', file);

fid = fopen('eigenrays.temp');

tableType = cell2mat(textscan(fid, 'Type %d', 1));

switch tableType
    case 1
        allData = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %s');
        EigData.range       = allData{1};
        EigData.time        = allData{2};
        EigData.sourceAngle = allData{3};
        EigData.targetAngle = allData{4};
        EigData.level       = allData{5};
        EigData.phase       = allData{6};
        EigData.srf         = allData{7};
        EigData.btm         = allData{8};
        EigData.upr         = allData{9};
        EigData.lwr         = allData{10};
        EigData.ima         = allData{11};
    case 2
        allData = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %s');
        EigData.range       = allData{1};
        EigData.frequency   = allData{2};
        EigData.time        = allData{3};
        EigData.sourceAngle = allData{4};
        EigData.targetAngle = allData{5};
        EigData.level       = allData{6};
        EigData.phase       = allData{7};
        EigData.srf         = allData{8};
        EigData.btm         = allData{9};
        EigData.upr         = allData{10};
        EigData.lwr         = allData{11};
        EigData.ima         = allData{12};
    case 3
        allData = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %s');
        EigData.range       = allData{1};
        EigData.depth       = allData{2};
        EigData.time        = allData{3};
        EigData.sourceAngle = allData{4};
        EigData.targetAngle = allData{5};
        EigData.level       = allData{6};
        EigData.phase       = allData{7};
        EigData.srf         = allData{8};
        EigData.btm         = allData{9};
        EigData.upr         = allData{10};
        EigData.lwr         = allData{11};
        EigData.ima         = allData{12};
    case 4
        allData = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %s');
        EigData.depth       = allData{1};
        EigData.frequency   = allData{2};
        EigData.time        = allData{3};
        EigData.sourceAngle = allData{4};
        EigData.targetAngle = allData{5};
        EigData.level       = allData{6};
        EigData.phase       = allData{7};
        EigData.srf         = allData{8};
        EigData.btm         = allData{9};
        EigData.upr         = allData{10};
        EigData.lwr         = allData{11};
        EigData.ima         = allData{12};
end

fclose(fid);