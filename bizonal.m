function beampat = bizonal(verbw, horbw, tilt, freq, bw)
%BIZONAL Computes a bizonal beam pattern based on the given parameters.
%
% beampat = bizonal(verbw, horbw, tilt, freq, bw)
%
% This program creates a bizonal beam pattern based on the given sonar
% parameters. It is based on the program compute_bizonal_pattern.f, which
% references an NCSC document by Tuovilla.  Angles are measured 90 deg down
% and -90 deg up.   
%
% Input variables:
%
%   verbw:  projected or received vertical beamwidth (degrees)
%
%   horbw:  projected or received horizontal beamwidth (degrees)
%
%   tilt:   sonar tilt from horizontal (degrees)
%
%   freq:   center frequency of sonar (Hz)
%
%   bw:     Bandwidth of sonar (Hz)
%
% Output variables
%
%   beampat:    181 x 2 array [angle, decibel level]

% Copyright 2004-2005 Kelly Kearney

horang = 0.0; 
cref   = 1500.0;

verbw = verbw .* pi/180;
horbw = horbw .* pi/180;
horang = horang .* pi/180;

fc = (freq - bw/2):(freq + bw/2 - 1);
verang = (-90:90) - tilt;

[fc, verang] = meshgrid(fc, verang);
k = 2.0 .* pi .* fc ./ cref;
lh = 2.0 .* 1.51949 ./ (k .* sin(0.5 * horbw));
lv = 2.0 .* 1.51949 ./ (k .* sin(0.5 * verbw));
x = 0.5 .* k .* lh .* sin(horang);
a = sinc(x);
c = sinc(0.5 * x);

y = 0.5 .* k .* lv .* sin(verang .* pi/180);
b = sinc(y);
d = sinc(0.5 * y);
dc = (1.6 .* (a.*b./2.0 + c.*d./8.0)).^2;
dc(verang == -90 | verang == 90) = 0;

thingToAdd = dc;
thingToAdd(dc > 1.0) = 0;
thingToAdd(dc <= 0) = 1e-30;
bpat = sum(thingToAdd, 2);

beampat(:,1) = (-90:90)';
beampat(:,2) = 10 .* log10(bpat ./ bw);

function a = sinc(x)

a = ones(size(x));
a(x~=0) = (sin(x(x~=0))) ./ (x(x~=0));