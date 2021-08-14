#!/usr/bin/env perl
use strict;
use warnings;

sub read_config() {
    my ($conf_file) = @_;

    my %pars;
    $conf_file = "$conf_file";
    %pars = config_parser($conf_file, %pars);

    # parse arguments of DIST DEPTH
    foreach ("DIST", "DEPTH") {
        my @value = split m/\s+/, $pars{$_};
        $pars{$_} = join " ", setup_values(@value);
    }

    return %pars;
}

sub setup_values() {# parse arguments of DIST FKDEPTH CAPDEPTH
    my @out;
    foreach (@_) {
        if ($_ =~ m/\//g) {
            my ($start, $end, $delta) = split m/\//;
            my $value = $start;
            my $i = 1;
            while ($value <= $end) {
                push @out, $value if ($value <= $end);
                $value = $i * $delta + $start;
                $i++;
            }
        } else {
            push @out, $_;
        }
    }
    @out = sort { $a <=> $b } @out;

    return @out;
}

sub config_parser() {
    my ($config_file, %pars) = @_;
    open(IN," < $config_file") or die "can not open configure file $config_file\n";
    my @lines = <IN>;
    close(IN);

    foreach my $line (@lines) {
        $line = substr $line, 0, (pos $line) - 1 if ($line =~ m/#/g);
        chomp($line);
        if ($line =~ m/:/g) {
            my ($key, $value) = split ":", $line;
            next unless (defined($key) and defined($value));
            $key = trim($key);
            $value = trim($value);
            $pars{$key} = $value;
        }else{
            my ($a) = split m/\s+/, $line;
            next unless (defined($a));
            unless (defined($pars{"MODEL"})) {
                $pars{"MODEL"} = $line;
            } else {
                $pars{"MODEL"} = join "\n", ($pars{"MODEL"}, $line);
            }
        }
    }
    return %pars;
}

sub getsactime () {
    my ($method, $file) = @_;
    my $start;
    my $end;
    if ($method == 1) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = $t2;
        $end = $t2 + 4;
    }
    if ($method == 2) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = max ($b, $t1 - 0.5);
        $end = min ($t2 + 15, $t2 + 1.7 * ($t2 - $t1));
        $end = min ($e, $end);
    }
    if ($method == 3) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = max ($b, $t1 - 0.5);
        $end = max ($t2 - 0.5, $start + 10);
        $end = min ($e, $end);
    }
    if ($method == 4) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = max ($b, $t2 - 0.5);
        $end = min ($e, $t2 + 10);
    }
    if ($method == 5) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = max ($b, $t1 - 0.5);
        $end = min ($t2 + 10, $t2 + 1.7 * ($t2 - $t1));
        $end = min ($e, $end);
    }
    if ($method == 6) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = max ($b, $t2 - 0.5);
        $end = min ($t2 + 10, $t2 + 0.8 * ($t2 - $t1));
        $end = min ($e, $end);
    }
    if ($method == 7) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = max ($b, $t2 - 0.2 * ($t2 - $t1));
        $end =  $t2 + 0.9 * ($t2 - $t1);
        $end = min ($e, $end);
    }
    if ($method == 8) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = max ($b, $t1 - 0.2);
        $end =  $t2 + 0.9 * ($t2 - $t1);
        $end = min ($e, $end);
    }
    if ($method == 9) {
        my ($b, $e, $t1, $t2) = (split m/\s+/, `saclst b e t1 t2 f $file`)[1..4];
        $start = max ($b, $t1 - 1);
        $end = min ($e, $t2 + 10);
    }
    return ($start, $end);
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

1;
