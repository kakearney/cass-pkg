function RayGroup = cassrayread(file)
%CASSRAYREAD Reads CASS ray data from an ascii output file
%
% Rays = cassrayread(file)
%
% This function reads the text created by a PRINT RAYS command from a CASS
% ascii output file.
%
% Input variables:
%
%   file:   CASS ascii output file
%
% Output variables:
%
%   RayGroup:   1 x n structure, where n is the number of ray tables
%               found in the file, with the field:
%
%               Ray:    1 x m structure, where m is the number of rays in
%                       the table (m may vary for each table), with the
%                       following fields; excepting startingAngle, all are
%                       k x 1 arrays, with data values vs time
%
%                       range:      range
%
%                       depth:      depth
%
%                       angle:      angle
%
%                       startAngle: initial transmit angle of ray
%
%                       level:      decibel level
%
%                       phase:      phase difference from initial phase
%
%                       srf:        number of surface reflections to this
%                                   point
%
%                       btm:        number of bottom reflections to this
%                                   point
%
%                       upr:
%
%                       lwr:
%
%                       comment:    1 - this point is the first for this
%                                       specific ray
%                                   2 - this point is the last for this
%                                       specific ray
%                                   3 - a bottom reflection ocurred between
%                                       this point and one of its neighbors
%                                   4 - a surface reflection ocurred
%                                       between this point and one of its
%                                       neighbors
%                                   0 - none of the above

% Copyright 2006 Kelly Kearney

perl('parseraydata.pl', file);

rayFiles = dir('rays*.temp');
rayFiles = {rayFiles.name};

for ifile = 1:length(rayFiles)
    
    rayTable = load(rayFiles{ifile});

    limits = [find(rayTable(:,11) == 1) find(rayTable(:,11) == 2)];

    for iray = 1:size(limits,1)
        RayGroup(ifile).Rays(iray).range   = rayTable(limits(iray,1):limits(iray,2), 1);
        RayGroup(ifile).Rays(iray).depth   = rayTable(limits(iray,1):limits(iray,2), 2);
        RayGroup(ifile).Rays(iray).angle   = rayTable(limits(iray,1):limits(iray,2), 3);
        RayGroup(ifile).Rays(iray).startAngle = RayGroup(ifile).Rays(iray).angle(1);
        RayGroup(ifile).Rays(iray).time    = rayTable(limits(iray,1):limits(iray,2), 4);
        RayGroup(ifile).Rays(iray).level   = rayTable(limits(iray,1):limits(iray,2), 5);
        RayGroup(ifile).Rays(iray).phase   = rayTable(limits(iray,1):limits(iray,2), 6);
        RayGroup(ifile).Rays(iray).srf     = rayTable(limits(iray,1):limits(iray,2), 7);
        RayGroup(ifile).Rays(iray).btm     = rayTable(limits(iray,1):limits(iray,2), 8);
        RayGroup(ifile).Rays(iray).upr     = rayTable(limits(iray,1):limits(iray,2), 9);
        RayGroup(ifile).Rays(iray).lwr     = rayTable(limits(iray,1):limits(iray,2), 10);
        RayGroup(ifile).Rays(iray).comment = rayTable(limits(iray,1):limits(iray,2), 11);
    end
end

delete rays*.temp;
    