#!/usr/bin/env perl
use strict;
use warnings;
$ENV{SAC_DISPLAY_COPYRIGHT}=0;
use List::Util qw(min max);
use FindBin;
use lib $FindBin::Bin;
require config;

my @config = @ARGV;
foreach my $fname (@config) {
    die "$fname not exist" unless (-e $fname);
    my %pars = read_config($fname);
    my ($model) = split m/\./, $fname;
    my @evdp = split m/\s+/, $pars{"DEPTH"};
    my ($b1, $b2) = split m/\s+/, $pars{"BP"};

    chdir $model or die;
    foreach my $dep (@evdp) {
        chdir "${model}_$dep" or die;
        print "${model}_$dep\n";
        foreach (glob "*.grn.0") {
            #110.606.grn.5
            my ($grna, $grnb, $grnc, $grnd) = split m/\./;
            my $dist;
            if (defined($grnd)) {
                $dist = "${grna}.${grnb}";
            } else {
                $dist = $grna;
            }
            foreach my $grn (0, 1, 2, 3, 4, 5, 6, 7, 8) {#2分量也需要写入user6头段以便glibrms统一计算归一化参数
                open(SAC, "|sac ") or die "Error in opening sac\n";
                print SAC "wild echo off\n";
                print SAC "r ${dist}.grn.${grn}\n";
                print SAC "rmean; rtr; taper\n";
                print SAC "bp c $b1 $b2 n 4 p 1\n";# > 2.0
                print SAC "ch user6 $grn\n";
                print SAC "write over\n";
                print SAC "q\n";
                close(SAC);
            }
            my ($start, $end) = &getsactime($pars{"WINDOW"}, "${dist}.grn.0");
            open(SAC, "|sac ") or die "Error in opening sac\n";
            print SAC "wild echo off\n";
            print SAC "cut $start $end\n";
            print SAC "r ${dist}.grn.[012345678]\n";#2分量也需要统一npts以便glibrms统一计算归一化参数
            print SAC "write over\n";
            print SAC "q\n";
            close(SAC);
            system "glibrms ${dist}.grn.0 ${dist}.grn.3 ${dist}.grn.6";
            system "glibrms ${dist}.grn.1 ${dist}.grn.4 ${dist}.grn.7";
            system "glibrms ${dist}.grn.2 ${dist}.grn.5 ${dist}.grn.8";
        }
        chdir ".." or die;
    }
    chdir ".." or die;
}
