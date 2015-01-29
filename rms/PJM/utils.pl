#!/usr/bin/perl -w
#*******************************************************************************
#* Copyright (c) 2015 RIKEN AICS 
#* All rights reserved. This program and the accompanying materials
#* are made available under the terms of the Eclipse Public License v1.0
#* which accompanies this distribution, and is available at
#* http://www.eclipse.org/legal/epl-v10.html
#*
#* Contributors:
#*    Peter Bryzgalov 
#*******************************************************************************/ 

# Convers a few last characters of node names so,
# that it is possible to tell which hierarchy units the nodes belong to.

use strict;
use Data::Dumper;
my $debug=0;
my %mapping = &prepare_mapping();
print "Prepared hash of size ". scalar keys %mapping;
print "\n";
print Dumper(\%mapping) if ($debug > 1);

sub modify_nodenames {
    my ($orig_name) = @_;    
    if (! defined $orig_name) {
        return "";
    }
    my $new_name = $mapping{$orig_name};
    if (! defined $new_name) {
        $new_name = $orig_name;
        print "No mapping for node $orig_name\n" if ($debug>0);
    }
    print "[ NODE: $orig_name ] \t\t\t$new_name\n" if ($debug>1);
    return $new_name;    
}

sub prepare_mapping {

    # Node number (key): 0x 01 01 00 10
    #                       ^  ^     ^ loop3 hex
    #                       |  | loop2 hex
    #                       | loop1 hex

    # Map to (value): 0x 0001 00 01
    #                    ^       ^ 01-96 dec
    #                    | 0001 - 09000 dec

    my %mapping = ();
    my $node_count=1;
    my $rack_count=1;
    my $n_start = 16;
    my $n_end = 111;
    my $r1_start = 1;
    my $r1_end = 24;
    my $r2_start = 1;
    my $r2_end = 36;

    for (my $i=$r2_start; $i<=$r2_end; $i++) {  # loop 1
        for (my $j=$r1_start; $j<=$r1_end; $j++) {  # loop 2
            $node_count=1;
            for (my $k=$n_start; $k<=$n_end; $k++) {  # loop 3
                my $key = "0x".uc(sprintf("%02x%02x00%02x",$i,$j,$k));
                my $value = sprintf("0x%04d00%02d",$rack_count,$node_count); 
                $mapping{$key} = $value;
                print "\t\"$key\"\t=>  \"$value\",\n" if ($debug>0);
                $node_count++;
            }
            $rack_count++;
        }
    }
    return %mapping;
}

1;
