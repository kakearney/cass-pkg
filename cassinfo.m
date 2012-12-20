function header = cassinfo(file)
%CASSINFO Reads header of binary CASS file
%
% This program reads the header of a CASS binary output file.  
%
% Input variables:
%
%   file:   name of file
%
% Output variables:
%
%   header: 21 x 1 cell array; the elements of this array vary depending on
%           the type of file.  See cassHeaders.xls for details.

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

fclose(fid);