#!/usr/bin/perl -w
#*******************************************************************************
#* Copyright (c) 2014 RIKEN AICS.
#* All rights reserved. This program and the accompanying materials
#* are made available under the terms of the Eclipse Public License v1.0
#* which accompanies this distribution, and is available at
#* http://www.eclipse.org/legal/epl-v10.html
#*
#* Contributors:
#*    Peter Bryzgalov (RIKEN AICS)
#*******************************************************************************/ 
use strict;

#say 'Run PJM/da_check_info_LML.pl'

sub check_rms_PJM {
    my($rmsref,$cmdsref,$verbose)=@_;
    my($key, $cmd);
    my $rc=1;
    
    my %cmdname=(
        "job"  => "pjstat",
        "node" => "pjshowrsc",
    );
    
    my %cmdpath=(
        "job" => "/usr/bin/pjstat",
        "node" => "/usr/bin/pjshowrsc",
    );
    
    foreach $key (keys(%cmdname)) {
        # check for job query cmd
        if (exists($cmdsref->{"cmd_${key}info"})) {
            $cmd=$cmdsref->{"cmd_${key}info"};
        } else {
            $cmd=$cmdpath{$key};
        }
        if (! -f $cmd) {
            my $cmdpath=`which $cmdname{$key} 2>/dev/null`;     # last try: which 
            if (!$?) {
                chomp($cmdpath);
                $cmd=$cmdpath;
                &report_if_verbose("%s","$0: check_rms_PJM: found $cmdname{$key} by which ($cmd)\n");
            }
        }
        if (-f $cmd) {
            $cmdsref->{"cmd_${key}info"}=$cmd;
        } else {
            &report_if_verbose("%s","$0: check_rms_PJM: no cmd found for $cmdname{$key}\n");
            $rc=0;
        }
    }
    
    if ($rc==1)  {
        $$rmsref = "PJM";
        &report_if_verbose("%s%s%s", "$0: check_rms_PJM: found PJM commands (",
               join(",",(values(%{$cmdsref}))),
               ")\n");
    } else {
    &report_if_verbose("%s","$0: check_rms_PJM: seems not to be a PJM system\n");
    }
    
    return($rc);
}

sub generate_step_rms_PJM {
    my($workflowxml, $laststep, $cmdsref)=@_;
    my($step,$envs,$key,$ukey);

    $envs="";
    foreach $key (keys(%{$cmdsref})) {
        $ukey=uc($key);
        $envs.="$ukey=$cmdsref->{$key} ";
    }
    $step="getdata";
    &add_exec_step_to_workflow($workflowxml,$step, $laststep, 
                   "$envs $^X rms/PJM/da_system_info_LML.pl               \$tmpdir/sysinfo_LML.xml",
                   "$envs $^X rms/PJM/da_nodes_info_LML.pl                \$tmpdir/nodes_LML.xml",
                   "$envs $^X rms/PJM/da_jobs_info_LML.pl                 \$tmpdir/jobs_LML.xml");
    $laststep=$step;

    $step="combineLML";
    &add_exec_step_to_workflow($workflowxml,$step, $laststep, 
                   "$^X \$instdir/LML_combiner/LML_combine_obj.pl  -v -o \$stepoutfile ".
                   "\$tmpdir/sysinfo_LML.xml \$tmpdir/jobs_LML.xml \$tmpdir/nodes_LML.xml");
    $laststep=$step;

    return($laststep);
}

$main::check_functions->{PJM}   =\&check_rms_PJM;
$main::generate_functions->{PJM}=\&generate_step_rms_PJM;

1;
