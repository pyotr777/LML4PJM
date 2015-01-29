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
package LML_gen_nodedisplay;
my($debug)=0;
my($generateusage)=1;
use strict;
use Time::Local;
use Time::HiRes qw ( time );
use Data::Dumper;

###############################################
# BG/P related functions
############################################### 
sub _adjust_layout_bgp  {
    my($self) = shift;
    my($root_layout,$root_scheme,$treenode,$ltreenode,$streenode,$num,$min,$max,$lmin,$lmax);
    my $rc=1;
    my $maxlevel=4;
  
    $root_layout=$self->{LAYOUT}->{tree};
    $root_scheme=$self->{SCHEMEROOT};

    # ROWS
    ######
    $streenode=$root_scheme->get_child({_name => "el1" });
    $ltreenode=$root_layout->get_child({_name => "el0" });

    # get number of rows (in el1 of scheme)
    if($streenode) {
	$min=$streenode->{ATTR}->{min};
	$max=$streenode->{ATTR}->{max};
	$num=$max-$min+1;
	
    } else {
	print STDERR "$0: ERROR: inconsistent scheme tree for BG system (rows) ...\n";return(0);
    }
    
    if(!$ltreenode) {
	$ltreenode=$root_layout->new_child();
    }
    # set size attributes
    $ltreenode->{ATTR}->{rows}=$num;
    $ltreenode->{ATTR}->{cols}=1;

    # set some default layout attributes
    $ltreenode->{ATTR}->{maxlevel} = $maxlevel      if(!exists($ltreenode->{ATTR}->{maxlevel}));
    $ltreenode->{ATTR}->{vgap} = 5                  if(!exists($ltreenode->{ATTR}->{vgap}));
    $ltreenode->{ATTR}->{hgap} = 0                  if(!exists($ltreenode->{ATTR}->{hgap}));       
    $ltreenode->{ATTR}->{fontsize} = 10             if(!exists($ltreenode->{ATTR}->{fontsize}));   
    $ltreenode->{ATTR}->{border}   = 0              if(!exists($ltreenode->{ATTR}->{border}));     
    $ltreenode->{ATTR}->{fontfamily} = "Monospaced" if(!exists($ltreenode->{ATTR}->{fontfamily})); 
    $ltreenode->{ATTR}->{showtitle}  = "false"      if(!exists($ltreenode->{ATTR}->{showtitle}));  
    $ltreenode->{ATTR}->{background} = "#777"       if(!exists($ltreenode->{ATTR}->{background})); 
    $ltreenode->{ATTR}->{mouseborder}= 0            if(!exists($ltreenode->{ATTR}->{mouseborder})); 
    $ltreenode->{ATTR}->{transparent}= "false"      if(!exists($ltreenode->{ATTR}->{transparent}));
    $lmin=$min;$lmax=$max;

    # RACKS
    #######
    $streenode=$streenode->get_child({_name => "el2" });

    # get number of rack (in el2 of scheme)
    if($streenode) {
	$min=$streenode->{ATTR}->{min};
	$max=$streenode->{ATTR}->{max};
	$num=$max-$min+1;
    } else {
	print STDERR "$0: ERROR: inconsistent scheme tree for BG system (racks) ...\n";return(0);
    }
    
    $treenode=$ltreenode->get_child({_name => "el1" });
    if(!$treenode) {
	$treenode=$ltreenode->new_child();
    } 
    $ltreenode=$treenode;

    # set size attributes
    $ltreenode->{ATTR}->{rows}=1;       $ltreenode->{ATTR}->{cols}=$num;
    $ltreenode->{ATTR}->{min}=$lmin;    $ltreenode->{ATTR}->{max}=$lmax;

    # set some default layout attributes
    $ltreenode->{ATTR}->{maxlevel} = $maxlevel     if(!exists($ltreenode->{ATTR}->{maxlevel}));
    $ltreenode->{ATTR}->{showtitle}  = "true"      if(!exists($ltreenode->{ATTR}->{showtitle}));  
    $lmin=$min;$lmax=$max;

    # midplanes
    ###########
    $streenode=$streenode->get_child({_name => "el3" });

    # get number of midplanes (in el3 of scheme)
    if($streenode) {
	$min=$streenode->{ATTR}->{min};
	$max=$streenode->{ATTR}->{max};
	$num=$max-$min+1;
    } else {
	print STDERR "$0: ERROR: inconsistent scheme tree for BG system (midplanes) ...\n";return(0);
    }
    
    $treenode=$ltreenode->get_child({_name => "el2" });
    if(!$treenode) {
	$treenode=$ltreenode->new_child();
    } 
    $ltreenode=$treenode;

    # set size attributes
    $ltreenode->{ATTR}->{rows}=$num;    $ltreenode->{ATTR}->{cols}=1;
    $ltreenode->{ATTR}->{min}=$lmin;    $ltreenode->{ATTR}->{max}=$lmax;

    # set some default layout attributes
    $ltreenode->{ATTR}->{maxlevel}         = $maxlevel     if(!exists($ltreenode->{ATTR}->{maxlevel}));
    $ltreenode->{ATTR}->{showtitle}        = "true"        if(!exists($ltreenode->{ATTR}->{showtitle}));  
    $ltreenode->{ATTR}->{highestrowfirst}  = "true"        if(!exists($ltreenode->{ATTR}->{highestrowfirst}));  
    $ltreenode->{ATTR}->{showfulltitle}    = "true"        if(!exists($ltreenode->{ATTR}->{showfulltitle}));  
    $lmin=$min;$lmax=$max;


    # nodeboards
    ############
    $streenode=$streenode->get_child({_name => "el4" });

    # get number of midplanes (in el4 of scheme)
    if($streenode) {
	$min=$streenode->{ATTR}->{min};
	$max=$streenode->{ATTR}->{max};
	$num=$max-$min+1;
    } else {
	print STDERR "$0: ERROR: inconsistent scheme tree for BG system (nodeboards) ...\n";return(0);
    }
    
    $treenode=$ltreenode->get_child({_name => "el3" });
    if(!$treenode) {
	$treenode=$ltreenode->new_child();
    } 
    $ltreenode=$treenode;

    # set size attributes
    $ltreenode->{ATTR}->{rows}=4;       $ltreenode->{ATTR}->{cols}=4;
    $ltreenode->{ATTR}->{min}=$lmin;    $ltreenode->{ATTR}->{max}=$lmax;

    # set some default layout attributes
    $ltreenode->{ATTR}->{maxlevel}         = $maxlevel     if(!exists($ltreenode->{ATTR}->{maxlevel}));
    $ltreenode->{ATTR}->{showtitle}        = "true"        if(!exists($ltreenode->{ATTR}->{showtitle}));  
    $ltreenode->{ATTR}->{fontsize}         = 8             if(!exists($ltreenode->{ATTR}->{fontsize}));   
    $ltreenode->{ATTR}->{vgap}             = 0             if(!exists($ltreenode->{ATTR}->{vgap}));
    $ltreenode->{ATTR}->{hgap}             = 0             if(!exists($ltreenode->{ATTR}->{hgap}));       
    $ltreenode->{ATTR}->{highestrowfirst}  = "true"        if(!exists($ltreenode->{ATTR}->{highestrowfirst}));  
    $ltreenode->{ATTR}->{showfulltitle}    = "true"        if(!exists($ltreenode->{ATTR}->{showfulltitle}));  
    $lmin=$min;$lmax=$max;

    # cpu-nodes
    ############
    $streenode=$streenode->get_child({_name => "el5" });

    # get number of midplanes (in el5 of scheme)
    if($streenode) {
	$min=$streenode->{ATTR}->{min};
	$max=$streenode->{ATTR}->{max};
	$num=$max-$min+1;
    } else {
	print STDERR "$0: ERROR: inconsistent scheme tree for BG system (cpu-nodes) ...\n";return(0);
    }
    
    $treenode=$ltreenode->get_child({_name => "el4" });
    if(!$treenode) {
	$treenode=$ltreenode->new_child();
    } 
    $ltreenode=$treenode;

    # set size attributes
    if($num%8==0) {
	$ltreenode->{ATTR}->{rows}=$num/8;
    } else {
	$ltreenode->{ATTR}->{rows}=int($num/8)+1;
    }
    $ltreenode->{ATTR}->{cols}=8;
    $ltreenode->{ATTR}->{min}=$lmin;    $ltreenode->{ATTR}->{max}=$lmax;

    # set some default layout attributes
    $ltreenode->{ATTR}->{maxlevel}         = $maxlevel     if(!exists($ltreenode->{ATTR}->{maxlevel}));
    $lmin=$min;$lmax=$max;

    # cores
    #######
    $streenode=$streenode->get_child({_name => "el6" });

    # get number of midplanes (in el6 of scheme)
    if($streenode) {
	$min=$streenode->{ATTR}->{min};
	$max=$streenode->{ATTR}->{max};
	$num=$max-$min+1;
    } else {
	print STDERR "$0: ERROR: inconsistent scheme tree for BG system (cores) ...\n";return(0);
    }
    
    $treenode=$ltreenode->get_child({_name => "el5" });
    if(!$treenode) {
	$treenode=$ltreenode->new_child();
    } 
    $ltreenode=$treenode;

    # set size attributes
    $ltreenode->{ATTR}->{rows}=1;       $ltreenode->{ATTR}->{cols}=4;
    $ltreenode->{ATTR}->{min}=$lmin;    $ltreenode->{ATTR}->{max}=$lmax;

    # set some default layout attributes
    $ltreenode->{ATTR}->{maxlevel}         = $maxlevel     if(!exists($ltreenode->{ATTR}->{maxlevel}));
    $lmin=$min;$lmax=$max;


#    print "$0: LAYOUT: ",Dumper($root_layout);
#    print "$0: SCHEME: ",Dumper($root_scheme);

    return($rc);
}


sub _get_system_size_bgp  {
    my($self) = shift;
    my($indataref) = $self->{INDATA};
    my($partref,$part,$lx,$ly,$lz,$px,$py,$pz);
    my($maxlx,$maxly,$maxlz,$maxpx,$maxpy,$maxpz);

    my ($key,$ref);
    
    $maxlx=$maxly=$maxlz=0;
    $maxpx=$maxpy=$maxpz=0;
    keys(%{$self->{LMLFH}->{DATA}->{OBJECT}}); # reset iterator
    while(($key,$ref)=each(%{$self->{LMLFH}->{DATA}->{OBJECT}})) {
	next if($ref->{type} ne 'partition');
	next if($ref->{id}!~/^bgbp/s);
	$partref=$self->{LMLFH}->{DATA}->{INFODATA}->{$key};
	$part=$partref->{bgp_partitionid};
	$px=$partref->{x_loc};
	$py=$partref->{y_loc};
	$pz=$partref->{z_loc};
	$maxpx=$px if($px>$maxpx);
	$maxpy=$py if($py>$maxpy);
	$maxpz=$pz if($pz>$maxpz);
        # currently not supported for BG/P
	# data could only get from LL over LL C-API
	$lx=$ly=$lz=0; 
	$maxlx=$lx if($lx>$maxlx);
	$maxly=$ly if($ly>$maxly);
	$maxlz=$lz if($lz>$maxlz);
    }

    printf("_get_system_size_bg: Blue Gene/P System found of size: %dx%dx%d (logical: %dx%dx%d)\n",
	   $maxpx+1,$maxpy+1,$maxpz+1,
	   $maxlx+1,$maxly+1,$maxlz+1,
	) if($self->{VERBOSE});
    
    return($maxlx,$maxly,$maxlz,$maxpx,$maxpy,$maxpz);
}


sub _init_trees_bgp  {
    my($self) = shift;
    my($maxlx,$maxly,$maxlz,$maxpx,$maxpy,$maxpz)=@_;
    my($id,$subid,$treenode,$schemeroot,$bgsystem);

    $schemeroot=$self->{SCHEMEROOT};
    $treenode=$schemeroot;
    $bgsystem=$treenode=$treenode->new_child();
    $treenode->add_attr({ tagname => 'row',
			  min     => 0,
			  max     => $maxpx,
			  mask    => 'R%02d' });

    $treenode=$treenode->new_child();
    $treenode->add_attr({ tagname => 'rack',
			  min     => 0,
			  max     => $maxpy,
			  mask    => '%02d' });

    $treenode=$treenode->new_child();
    $treenode->add_attr({ tagname => 'midplane',
			  min     => 0,
			  max     => $maxpz,
			  mask    => '-M%01d' });

    $treenode=$treenode->new_child();
    $treenode->add_attr({ tagname => 'nodecard',
			  min     => 0,
			  max     => 15,
			  mask    => '-N%02d' });

    $treenode=$treenode->new_child();
    $treenode->add_attr({ tagname => 'computecard',
			  min     => 4,
			  max     => 35,
			  mask    => '-C%02d' });

    $treenode=$treenode->new_child();
    $treenode->add_attr({ tagname => 'core',
			  min     => 0,
			  max     => 3,
			  mask    => '-%01d' });

    return(1);
}

1;
