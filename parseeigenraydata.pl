#! perl -w
#
# parseeigenraydata.pl file
#
# Retrieves table from a PRINT EIGENRAYS command and saves it to the 
# temporary file eigenrays.temp.  Assumes there is  only one table in the 
# file.
#
# Copyright 2005 Kelly Kearney

use strict;

#--------------------------
# Read table and save to
# file
#--------------------------

open (RAY, "> eigenrays.temp");

my $data = 0;
my ($ncols);
LOOP: while (<>) {
    if (/ACOUSTIC EIGENRAYS/) {
        <>;<>;

        # Determine type of table

        my $topHeaderLine = <>;
        my @columnNames = split ' ', $topHeaderLine;
        $ncols = @columnNames;
        my $haveR = ($topHeaderLine =~ /RANGE/);
        my $haveD = ($topHeaderLine =~ /DEPTH/);
        my $haveF = ($topHeaderLine =~ /FREQUENCY/);

        my $type;
        if ($haveR && (! $haveD) && (! $haveF)) {
            $type = 1;
        } elsif ($haveR && (! $haveD) && $haveF) {
            $type = 2;
        } elsif ($haveR && $haveD && (! $haveF)) {
            $type = 3;
        } elsif ((! $haveR) && $haveD && $haveF) {
            $type = 4;
        }
        print RAY "Type $type\n";

        <>;<>;<>;
        $data = 1;
        next LOOP;

    } elsif (/^\s*$/) {
        $data = 0;
    }
    if ($data == 1) {
        chomp;
        my @rayData = split;
        if (@rayData == $ncols) {
            print RAY "@rayData\n";
        } elsif (@rayData == ($ncols - 1)) {
            print RAY "@rayData -\n";
        }
    }
}

        