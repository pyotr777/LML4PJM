#*******************************************************************************
#* Copyright (c) 2011 Forschungszentrum Juelich GmbH.
#* All rights reserved. This program and the accompanying materials
#* are made available under the terms of the Eclipse Public License v1.0
#* which accompanies this distribution, and is available at
#* http://www.eclipse.org/legal/epl-v10.html
#*
#* Contributors:
#*    Wolfgang Frings (Forschungszentrum Juelich GmbH) 
#*******************************************************************************/ 
package LML_da_workflow_obj;

my($debug)=0;

use strict;
use Data::Dumper;
use Time::Local;
use Time::HiRes qw ( time );

sub new {
    my $self    = {};
    my $proto   = shift;
    my $class   = ref($proto) || $proto;
    my $verbose = shift;
    my $timings = shift;
    printf("\t LML_da_workflow_obj: new %s\n",ref($proto)) if($debug>=3);
    $self->{DATA}      = {};
    $self->{VERBOSE}   = $verbose; 
    $self->{TIMINGS}   = $timings; 
    $self->{LASTINFOID} = undef;
    bless $self, $class;
    return $self;
}

sub read_xml_fast {
    my($self) = shift;
    my $infile  = shift;
    my($xmlin);
    my $rc=0;

    my $tstart=time;
    if(!open(IN,$infile)) {
	print STDERR "$0: ERROR: could not open $infile, leaving ...\n";return(0);
    }
    while(<IN>) {
	$xmlin.=$_;
    }
    close(IN);
    my $tdiff=time-$tstart;
    printf("LML_da_workflow_obj: read  XML in %6.4f sec\n",$tdiff) if($self->{VERBOSE});

    if(!$xmlin) {
	print STDERR "$0: ERROR: empty file $infile, leaving ...\n";return(0);
    }


    $tstart=time;

    # light-weight self written xml parser, only working for simple XML files  
    $xmlin=~s/\n/ /gs;
    $xmlin=~s/\s\s+/ /gs;
    my ($tag,$tagname,$rest,$ctag,$nrc);
    foreach $tag (split(/\>/,$xmlin)) {
	$ctag.=$tag;
	$nrc=($ctag=~ tr/\"/\"/);
	if($nrc%2==0) {
	    $tag=$ctag;
	    $ctag="";
	} else {
	    $ctag.="\>";
	    next;
	}
	
	$tag=~s/^\s*//gs;$tag=~s/\s*$//gs;

	# comment
	next if($tag =~ /\!\-\-/);

#	print "TAG: '$tag'\n";
	if($tag=~/^<[\/\?](.*[^\s\>])/) {
	    $tagname=$1;
#	    print "TAGE: '$tagname'\n";
	    $self->xml_end($self->{DATA},$tagname,());
	} elsif($tag=~/<([^\s\/]+)\s*$/) {
	    $tagname=$1;
#	    print "TAG0: '$tagname'\n";
	    $self->xml_start($self->{DATA},$tagname,());
	} elsif($tag=~/<([^\s]+)(\s(.*)[^\/])$/) {
	    $tagname=$1;
	    $rest=$2;$rest=~s/^\s*//gs;$rest=~s/\s*$//gs;$rest=~s/\=\s+\"/\=\"/gs;$rest=~s/\s+\=\"/\=\"/gs;
#	    print "TAG1: '$tagname' rest='$rest'\n";
	    $self->xml_start($self->{DATA},$tagname,split(/=?\"\s*/,$rest));
	} elsif($tag=~/<([^\s\/]+)(\s(.*)\s?)\/$/) {
	    $tagname=$1;
	    $rest=$2;$rest=~s/^\s*//gs;$rest=~s/\s*$//gs;$rest=~s/\=\s+\"/\=\"/gs;$rest=~s/\s+\=\"/\=\"/gs;
#	    print "TAG2: '$tagname' rest='$rest' closed\n";
	    $self->xml_start($self->{DATA},$tagname,split(/=?\"\s*/,$rest));
	    $self->xml_end($self->{DATA},$tagname,());
	} elsif($tag=~/<([^\s\/]+)\/$/) {
	    $tagname=$1;
	    $rest="";
#	    print "TAG2e: '$tagname' rest='$rest' closed\n";
	    $self->xml_start($self->{DATA},$tagname,split(/=?\"\s*/,$rest));
	    $self->xml_end($self->{DATA},$tagname,());
	}
    }

    $tdiff=time-$tstart;
    printf("LML_da_workflow_obj: parse XML in %6.4f sec\n",$tdiff) if($self->{VERBOSE});

#    print Dumper($self->{DATA});
    return($rc);

}


sub xml_start {
    my $self=shift; # object reference
    my $o   =shift;
    my $name=shift;
    my($k,$v,$actnodename,$id,$sid,$oid);

#    print "LML_da_workflow_obj: lml_start >$name< \n";

    if($name eq "!--") {
	# a comment
	return(1);
    }
    my %attr=(@_);

#    print Dumper(\%attr);

    if($name eq "LML_da_workflow") {
	foreach $k (sort keys %attr) {
	    $o->{LML_da_workflow}->{$k}=$attr{$k};
	}
	return(1);
    }

    if($name eq "vardefs") {
	return(1);
    }
    if($name eq "var") {
	push(@{$o->{vardefs}->[0]->{var}},\%attr);
	return(1);
    }
    if($name eq "step") {
	$id=$attr{id};
	$o->{LASTSTEPID}=$id;
	foreach $k (sort keys %attr) {
	    $o->{step}->{$id}->{$k}=$attr{$k};
	}
	return(1);
    }
    if($name eq "cmd") {
	$id=$attr{id};
	$sid=$o->{LASTSTEPID};

	push(@{$o->{step}->{$sid}->{cmd}},\%attr);

	return(1);
    }

    # unknown element
    print "LML_da_workflow_obj: WARNING unknown tag >$name< \n";
   
}

sub xml_end {
    my $self=shift; # object reference
    my $o   =shift;
    my $name=shift;
#    print "LML_da_workflow_obj: lml_end >$name< \n";

    if($name=~/vardefs/) {
    }
    if($name=~/step/) {
	$o->{LASTSTEPID}=undef;
    }

#    print Dumper($o->{NODEDISPLAYSTACK});
}


sub write_xml {
    my($self) = shift;
    my($k,$rc,$id,$c,$key,$ref);
    my $outfile  = shift;
    my $tstart=time;
    my $data="";

    $rc=1;

    open(OUT,"> $outfile") || die "cannot open file $outfile";

    printf(OUT "<LML_da_workflow ");
    foreach $k (sort keys %{$self->{DATA}->{LML_da_workflow}}) {
	printf(OUT "%s=\"%s\"\n ",$k,$self->{DATA}->{LMLLGUI}->{$k});
    }
    printf(OUT "     \>\n");

    printf(OUT "<vardefs>\n");
    foreach $ref (@{$self->{DATA}->{vardefs}->[0]->{var}}) {
	printf(OUT "<var");
	foreach $k (sort keys %{$ref}) {
	    printf(OUT " %s=\"%s\"",$k,$ref->{$k});
	}
	printf(OUT "/>\n");
    }
    printf(OUT "</vardefs>\n");

    foreach $id (sort keys %{$self->{DATA}->{step}}) {
	printf(OUT "<step");
	foreach $k (sort keys %{$self->{DATA}->{step}->{$id}}) {
	    next if($k eq "cmd");
	    printf(OUT " %s=\"%s\"",$k,$self->{DATA}->{step}->{$id}->{$k});
	}
	printf(OUT ">\n");
	if(exists($self->{DATA}->{step}->{$id}->{cmd})) {
	    foreach $ref (@{$self->{DATA}->{step}->{$id}->{cmd}}) {
		printf(OUT "<cmd ");
		foreach $k (sort keys %{$ref}) {
		    printf(OUT " %s=\"%s\"",$k,$ref->{$k});
		}
		printf(OUT "/>\n");
	    }
	}
	printf(OUT "</step>\n");
    }
    
    printf(OUT "</LML_da_workflow>\n");
    
    close(OUT);

    my $tdiff=time-$tstart;
    printf("LML_da_workflow_obj: wrote  XML in %6.4f sec to %s\n",$tdiff,$outfile) if($self->{TIMINGS});
    
    return($rc);
    
}

    
1;
