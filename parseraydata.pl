#! perl -w
#
# parseraydata.pl file
#
# Retrieves table from a PRINT RAYS command and saves it to the temporary 
# file rays#.temp.  This program is called by cassrayread.m.
#
# Copyright 2005 Kelly Kearney

use strict;

#---------------------------
# Get ray table
#---------------------------

my $cassoutFile = $ARGV[0];
open (CASSOUT, "$cassoutFile") or die "Cannot open cassout file: $!";

my $tableCount = 0;

FILELOOP: while (1) { # (<CASSOUT>) {

    my $fileLine = <CASSOUT>;
    last FILELOOP if (! defined($fileLine));

    if ($fileLine =~ /RANGE     DEPTH     ANGLE     TIME/) {
        
        $tableCount++;

        <CASSOUT>;<CASSOUT>;<CASSOUT>;
        open(RAY, "> rays${tableCount}.temp") or die "Cannot open ray table file: $!";

        TABLELOOP: while (1) {
            
            chomp(my $tableLine = <CASSOUT>);
            if (($tableLine =~ /Elapsed time =/) || ($tableLine =~ /^\s*$/)) {
                close(RAY);
                next FILELOOP;
            } else {
                my @rayData = split ' ', $tableLine;
                if (@rayData == 11) {
                    if ($rayData[10] eq 'SRC') {
                        pop @rayData;
                        print RAY "@rayData 1\n";
                    } elsif ($rayData[10] eq 'MAX') {
                        pop @rayData;
                        print RAY "@rayData 2\n";
                    } elsif ($rayData[10] eq 'BTM') {
                        pop @rayData;
                        print RAY "@rayData 3\n";
                    } elsif ($rayData[10] eq 'SRF') {
                        pop @rayData;
                        print RAY "@rayData 4\n";
                    }
                } elsif (@rayData == 10) {
                    print RAY "@rayData 0\n";
                } else {
                    die "Wrong number of columns found in table\n";
                }
            }
        }
    }
}
        
    