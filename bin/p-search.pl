#!/usr/bin/env perl
use strict;
use warnings;
use Parallel::ForkManager;
use List::Util qw(min max);
use Time::HiRes qw(gettimeofday tv_interval);
use FindBin;
use lib $FindBin::Bin;
require config;
$ENV{SAC_DISPLAY_COPYRIGHT}=0;

my ($config, $workdir, $ram) = @ARGV;
die "no $config" unless (-e $config);
die "no $workdir" unless (-d $workdir);
die unless defined $ram and -d $ram;
$ram = `realpath $ram`;
chomp $ram;
my %pars = read_config($config);
my $threshold = $pars{THRESHOLD};
$threshold = 8 unless (defined($threshold));
my $step = $pars{STEP};
$step = 30 unless (defined($step));
$step = int ($step + 0.5);
print "THRESHOLD: $threshold STEP: $step\n";
$pars{MODEL} = "$ENV{GFMF}/$pars{MODEL}" unless (-d $pars{MODEL});# 同时兼容GFMF项目路径和工作路径
$pars{MODEL} = `realpath $pars{MODEL}`;
chomp $pars{MODEL};
my $model = (split m/\//, $pars{MODEL})[-1];
$pars{GRIDS} = "$ENV{GFMF}/$pars{GRIDS}" unless (-e $pars{GRIDS});
$pars{GRIDS} = `realpath $pars{GRIDS}`;
chomp $pars{GRIDS};
my $pwd = `pwd`;
chomp($pwd);
my @evdp = split m/\s+/, $pars{'DEPTH'};
my @eqs = getgrids ("$pars{GRIDS}");
my @station = getstations("$pars{STATION}", $workdir);
my ($kztime, $kzdate) = check_stations ($workdir, @station);
my ($MAX_PROCESSES) = getprocess ("Linux");

# 复制数据
system "rm -rf $ram/*";
system "rsync -ah --partial --exclude=\"*.[abc2]\" --delete $pars{MODEL} $ram";
cpdata($workdir, $ram, @station);

# 建立路径
mkdir "$ram/ss" or die "cannot mkdir $ram/ss";
chdir $ram or die "cannot get in $ram";

# 计算开始
print "begin $workdir $config\n";
build_grids_file ($MAX_PROCESSES, @eqs);#为每一个核建立网格文件

my $pm = Parallel::ForkManager -> new($MAX_PROCESSES);
for (my $i = 1; $i <= $MAX_PROCESSES; $i++) {
    my $pid = $pm -> start and next;

    my $diskcoast = 0;
    open (IN, "< $ram/$i.txt") or die;
    my @eq = <IN>;
    close(IN);
    my $all_work_num = @eq;
    print "CPU$i $all_work_num\n";
    open (OUT,"> $ram/result_$i") or die;
    my $now_work_num = 1;
    foreach (@eq) {
        last if (-e "$pwd/STOP");
        my $t = [gettimeofday];
        my $tt = $t;
        my $rottime = 0;
        my $cortime = 0;
        my $fiztime = 0;
        my $sumtime = 0;

        my ($evlo, $evla) = split m/\s+/;
        mkdir "$ram/ss/${evlo}_${evla}" or die;
        chdir "$ram/ss/${evlo}_${evla}" or die;
        # 以虚拟地震的位置来旋转分量，并删除 e n 分量
        open(SAC, "| sac") or die "Error in opening sac\n";
        print SAC "wild echo off \n";
        foreach my $sta (@station) {
            print SAC "r $ram/${sta}.n $ram/${sta}.e\n";
            print SAC "ch evlo $evlo evla $evla\n";
            print SAC "rotate to gcp\n";
            print SAC "w ${sta}.r ${sta}.t\n";
        }
        print SAC "q\n";
        close(SAC);
        my %distaz;
        my $num = 0;
        my @station_work;
        foreach my $sta (@station) {
            my ($dist) = (split m/\s+/, `saclst dist f ${sta}.r`)[1];
            $dist = 0.1 * int($dist / 0.1 + 0.5);
            next unless (-e "$ram/$model/${model}_$evdp[0]/${dist}.grn.0");
            $distaz{$sta} = $dist;
            push @station_work, $sta;
            $num = $num + 3;
        }
        $rottime = tv_interval($t, [gettimeofday]);

        # 准备互相关格林函数
        foreach my $evdp (@evdp) {
            $t = [gettimeofday];
            system "rm -rf glib" if (-d "glib");
            mkdir "glib" or die;
            chdir "glib" or die;
            my $b = 12345678.9;
            my $e = -1234567.8;
            foreach my $sta (@station_work) {
                my $dist = $distaz{$sta};
                # 实际数据和格林函数做互相关
                my $file;
                my @corcmdz;
                my @corcmdr;
                my @corcmdt;
                my $corcmd;
                #  z
                $file = "$ram/${sta}.z";
                die "$file NOT EXIST\n" unless (-e $file);
                push @corcmdz, $file;
                foreach my $q (0, 3, 6) {
                    my $glib = "$ram/$model/${model}_$evdp/${dist}.grn.$q";
                    die "$glib NOT EXIST\n" unless (-e $glib);
                    push @corcmdz, "$glib ${sta}.${evdp}.$q";
                }
                $corcmd = join(" ", @corcmdz);
                my (undef, $bi, $ei) = split m/\s+/, `fastcor $corcmd`;
                $b = min($b, $bi);
                $e = max($e, $ei);
                #  r
                $file = "$ram/ss/${evlo}_${evla}/${sta}.r";
                push @corcmdr, $file;
                die "$file NOT EXIST\n" unless (-e $file);
                foreach my $q (1, 4, 7) {
                    my $glib = "$ram/$model/${model}_$evdp/${dist}.grn.$q";
                    die "$glib NOT EXIST\n" unless (-e $glib);
                    push @corcmdr, "$glib ${sta}.${evdp}.$q";
                }
                $corcmd = join(" ", @corcmdr);
                (undef, $bi, $ei) = split m/\s+/, `fastcor $corcmd`;
                $b = min($b, $bi);
                $e = max($e, $ei);
                #  t
                $file = "$ram/ss/${evlo}_${evla}/${sta}.t";
                push @corcmdt, $file;
                die "$file NOT EXIST\n" unless (-e $file);
                foreach my $q (5, 8) {
                    my $glib = "$ram/$model/${model}_$evdp/${dist}.grn.$q";
                    die "$glib NOT EXIST\n" unless (-e $glib);
                    push @corcmdt, "$glib ${sta}.${evdp}.$q";
                }
                $corcmd = join(" ", @corcmdt);
                (undef, $bi, $ei) = split m/\s+/, `fastcor $corcmd`;
                $b = min($b, $bi);
                $e = max($e, $ei);
            }
            $cortime = $cortime + tv_interval($t, [gettimeofday]);
            $t = [gettimeofday];
            open(SAC, "| sac") or die "Error in opening sac\n";
            print SAC "wild echo off \n";
            print SAC "cuterr fillz\n";
            print SAC "cut $b $e\n";
            print SAC "r *.[01345678]\n";
            print SAC "ch evlo $evlo evla $evla evdp $evdp\n";
            print SAC "write over\n";
            print SAC "q\n";
            close(SAC);
            chdir "../" or die;
            $fiztime = $fiztime + tv_interval($t, [gettimeofday]);
            # 遍历机制解
            $t = [gettimeofday];
            my @fastsum;
            foreach my $sta (@station_work) {
                foreach my $grnnum (0, 1, 3, 4, 5, 6, 7, 8) {
                    push @fastsum, "$ram/ss/${evlo}_${evla}/glib/${sta}.${evdp}.$grnnum";
                }
            }
            my $sumcmd = join(" ", @fastsum);
            my @info = split m/\n/, `fastsum $threshold $step $num $sumcmd`;
            foreach (@info) {
                my ($strike, $dip, $rake, $time, $am, $mad, $mad8) = (split m/\s+/)[1..7];
                print OUT "$time $evlo $evla $evdp $strike $dip $rake $am $mad $mad8\n";
            }
            $sumtime = $sumtime + tv_interval($t, [gettimeofday]);
        }
        $t = [gettimeofday];
        my $cktime = tv_interval($t, [gettimeofday]);

        system "rm -rf $ram/ss/${evlo}_${evla}";
        my $alltime = tv_interval($tt, [gettimeofday]);
        print "CPU$i $now_work_num/$all_work_num ${evlo}_${evla} rot: $rottime cor: $cortime fiz: $fiztime sum: $sumtime ck: $cktime all: $alltime\n";
        $now_work_num++;
    }
    close (OUT);
    print "CPU$i FINISH\n";
    $pm -> finish;
}
$pm -> wait_all_children;

my ($result_name) = split m/\./, $config;
my $best_info;
my $best_cc = 0;
open (OUT," > $pwd/$workdir/result_${result_name}.txt") or die;
for (my $i = 1; $i <= $MAX_PROCESSES; $i++) {
    open (IN, "< $ram/result_$i") or die;
    foreach (<IN>) {
        chomp;
        my $cc = (split m/\s+/)[7];
        print OUT "$kzdate $kztime $_\n" if ($threshold > 0);
        next unless (($threshold == 0) and ($cc > $best_cc));
        $best_info = "$kzdate $kztime $_";
        $best_cc = $cc;
    }
    close(IN);
}
print OUT "$best_info\n"if ($threshold == 0);
close(OUT);

sub getstations {
    my ($in, $dir) = @_;
    my @files = split m/\s+/, $in;
    my @out;
    foreach my $file (@files) {
        open (IN, "< $file") or die "cannot open $file";
        foreach (<IN>) {
            #AZ|BZN|33.491501|-116.667|1301.0|Buzz Northerns Place, Anza, CA, USA|1983-01-20T00:00:00|
            next if ($_ =~ "#");
            my ($net, $sta, $stla, $stlo) = split m/\|/;
            push @out, "${net}_${sta}" if ((-e "$dir/${net}_${sta}.e") and (-e "$dir/${net}_${sta}.n") and (-e "$dir/${net}_${sta}.z"));
        }
        close (IN);
    }
    return @out;
}

sub check_stations {
    my @in = @_;
    my $dir = shift @in;
    my ($kztime, $kzdate);
    foreach my $sta (@in) {
        die "$sta" unless ((-e "$dir/$sta.e") and (-e "$dir/$sta.n") and (-e "$dir/$sta.z"));
        ($kzdate, $kztime) = (split m/\s+/, `saclst kzdate kztime f $dir/$sta.z`)[1,2];
    }
    return ($kztime, $kzdate);
}

sub getprocess {
    my ($in) = @_;
    my $MAX_PROCESSES;
    ($MAX_PROCESSES) = split m/\n/, `cat /proc/cpuinfo |grep "processor"|wc -l` if ($in eq "Linux");
    $MAX_PROCESSES = 1 if ($MAX_PROCESSES < 1);
    return ($MAX_PROCESSES);
}

sub getgrids {
    my ($file) = @_;
    my @out;
    open(IN, "< $file") or die "cannot open $file";
    foreach (<IN>) {
        my ($evlo, $evla) = split m/\s+/;
        push @out, "$evlo $evla";
    }
    close(IN);
    return @out;
}

sub cpdata {
    my @in = @_;
    my $source = shift @in;
    my $target = shift @in;
    foreach my $sta (@in) {
        system "cp $source/${sta}.[enz] $target";
    }
}

sub build_grids_file {
    my @in = @_;
    my $MAX_PROCESSE = shift @in;
    for (my $i = 1; $i <= $MAX_PROCESSES; $i++) {
        system "touch $i.txt";
    }
    my $j = 1;
    foreach (@in) {
        open(OUT, ">> $j.txt") or die;
        print OUT "$_\n";
        close(OUT);
        if ($j < $MAX_PROCESSES) {
            $j++;
        }else{
            $j=1;
        }
    }
}
