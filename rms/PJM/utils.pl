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
my $debug=1;
my %mapping = &prepare_mapping();

sub modify_nodenames {
    my ($orig_name) = @_;    
    if (! defined $orig_name) {
        return "";
    }

    my $use_digits = 2;  # Use a few last symbols from node names
    my $tail = substr($orig_name,(-1*$use_digits));
    my $l = length($orig_name);
    my $head = substr($orig_name,0,$l - $use_digits);        
    my $new_tail = $mapping{$tail};
    if (! defined $new_tail) {
        $new_tail = $tail;
    }
    print "[ NODE: $head $tail ] \t\t\t$new_tail\n" if ($debug>0);
    my $new_name = $head . $new_tail;
    return $new_name;    
}

sub prepare_mapping {
    my %mapping = ();
    my $start = 16;
    my $end = 111;
    
    my $mod_tf = 3;  # number of boards in 1 tofu unit
    my $mod_bd = 4;   # number of node in 1 board

    my $mod1 = $mod_bd * $mod_tf;
    my $mod2 = $mod_bd;    
    for (my $i=0; $i <= $end-$start; $i++) {
        my $key = uc(sprintf("%x",$i+$start)); # These will be keys for mapping hash
        my $d1 = int ($i/$mod1);
        my $leftover = $i - $mod1*$d1;
        my $d2 = int ($leftover/$mod2);
        $leftover = $leftover - $mod2*$d2;
        my $d3 = $leftover;
        my $value =  $d1 . $d2 . $d3;      
        print "\t\"$key\"\t=>  \"$value\",\n" if ($debug>0);
        $mapping{$key} = $value;
    }
    return %mapping;
}

1;
