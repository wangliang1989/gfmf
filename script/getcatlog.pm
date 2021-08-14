#!/usr/bin/env perl
use strict;
use warnings;
use Time::Local;

sub input {
    my ($file, $yuzhi) = @_;
    my @out;
    open (IN, "< $file") or die "cannot open $file";
    foreach (<IN>) {
        #2018/08/15 00:00:00.000 2934.04 -116.7 33.6 10.5 0 90 -60 \
        #7.9883828759E-02 5.9018656611E-03 4.7214925289E-02
        my ($kzdate, $kztime, $o, $evlo, $evla, $evdp, $strike, $dip, $rake,
                                              $cc, $mad, $mad8) = split m/\s+/;
        next if ($cc / $mad < $yuzhi);
        my ($year, $mon, $day) = split m/\//, $kzdate;
        my ($hour, $min, $sec) = split ":", $kztime;
        $mon -= 1;
        #my $time = timegm($sec, $min, $hour, $day, $mon, $year);
        my $time = timegm(0, 0, 0, $day, $mon, $year);
        $time = $time + 60 * ($hour * 60 + $min) + $sec + $o;
        push @out, "$time $evla $evlo $evdp $mad $mad8 $strike $dip $rake $cc";
    }
    return (@out);
}
sub sort_cc {
    my @events = @_;
    my %hash;
    foreach (@events) {
        my ($time, $evla, $evlo, $evdp, $mad, $mad8, $strike, $dip, $rake, $cc)
                                                                = split m/\s+/;
        $hash{"$time $evla $evlo $evdp $mad $mad8 $strike $dip $rake"} = $cc;
    }
    my @out;
    foreach my $key (sort {$hash{$b} <=> $hash{$a}} keys %hash) {
        push @out, "$key $hash{$key}";
    }
    return @out;
}
sub check {
    my @events = @_;
    my $th =  shift @events;
    my $window = shift @events;
    my @out;
    foreach my $info (@events) {
        my ($time, $evla, $evlo, $evdp, $mad, $mad8, $strike, $dip, $rake, $cc)
                                                         = split m/\s+/, $info;
        next if ($th > $cc / $mad);
        my $i = 0;
        foreach my $info_i (@out) {
            my ($time_i, $evla_i, $evlo_i, $evdp_i, $mad_i, $mad8_i, $strike_i,
                               $dip_i, $rake_i, $cc_i) = split m/\s+/, $info_i;
            $i = 1 if (abs ($time - $time_i) < $window);
            last if ($i == 1);
        }
        push @out, "$time $evla $evlo $evdp $mad $mad8 $strike $dip $rake $cc" if ($i == 0);
        #$hash{"$time $evla $evlo $evdp $mad $mad8 $strike $dip $rake"} = $cc;
        #push @out, "$key $hash{$key}" if ($judge == 0);
    }
    return @out;
}
sub check_meca {
    my @events = @_;
    my $th =  shift @events;
    my $window = shift @events;
    my $s = shift @events;
    my $d = shift @events;
    my $r = shift @events;
    my @out;
    foreach my $info (@events) {
        my ($time, $evla, $evlo, $evdp, $mad, $mad8, $strike, $dip, $rake, $cc)
                                                         = split m/\s+/, $info;
        last if ($th > $cc / $mad);
        next unless (($strike == $s) and ($dip == $d) and ($rake == $r));
        my $i = 0;
        foreach my $info_i (@out) {
            my ($time_i, $evla_i, $evlo_i, $evdp_i, $mad_i, $mad8_i, $strike_i,
                               $dip_i, $rake_i, $cc_i) = split m/\s+/, $info_i;
            $i = 1 if (abs ($time - $time_i) < $window);
            last if ($i == 1);
        }
        push @out, "$time $evla $evlo $evdp $mad $mad8 $strike $dip $rake $cc"
                                                                  if ($i == 0);
        #$hash{"$time $evla $evlo $evdp $mad $mad8 $strike $dip $rake"} = $cc;
        #push @out, "$key $hash{$key}" if ($judge == 0);
    }
    return @out;
}
sub sort_time { 
    my @in = @_;
    my %out;
    foreach (@in){
        my ($time, $evla, $evlo, $evdp, $mad, $mad8, $strike, $dip, $rake, $cc)
                                                                = split m/\s+/;
        my ($sec ,$min, $hour, $mday, $mon, $year) = gmtime($time);
        $out{$time} = "$evla $evlo $evdp $mad $mad8 $strike $dip $rake $cc";
    }
    my @result;
    foreach my $time (sort {$a <=> $b} keys %out) {
        my (undef, $msec) = split m/\./, $time;
        my ($sec ,$min, $hour, $mday, $mon, $year) = gmtime($time);
        $year += 1900;
        $mon += 1;
        ($mon, $mday, $hour, $min, $sec) = &add_zero ($mon, $mday, $hour, $min,
                                                                         $sec);
        $sec = "${sec}.${msec}" if (defined($msec));
        my $origin = "${year}-${mon}-${mday}T${hour}:${min}:${sec}";
        push @result, "$origin $out{$time}";
    }
    return(@result);
}
sub add_zero(){
    my @in = @_;
    my @out;
    foreach (@in) {
        if (length($_) < 2) {
            push @out, "0$_";
        }else{
            push @out, "$_";
        }
    }
    return @out;
}
1;
