#!/usr/bin/perl -w

use strict;

use Term::ANSIColor;
my $debug=0;

print colored ['blue'], "Running PJM/da_nodes_info_LML.pl\n";

require "utils.pl";

my $cmd="/usr/bin/pjshowrsc";
open(IN,"$cmd -v 1 | grep NODE |");
my ($line,$nodeid,%nodes);
while($line=<IN>) {
    chomp($line);
    # printf "$line\n";
    if ($line=~/^\[\s*NODE:\s*([^\s]+)/) {
        $nodeid=&modify_nodenames($1);
        print colored ['green'],"$nodeid\n" if ($debug>0);
        $nodes{$nodeid}{id}=$nodeid;                
    } 
}
close(IN);
