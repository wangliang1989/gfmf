#!/usr/bin/env perl
use strict;
use warnings;

sub read_config() {
    my ($conf_file) = @_;

    my %pars;

    # configure file
    %pars = config_parser($conf_file, %pars) if -e $conf_file;

    # parse arguments of DEPTH
    $pars{"DEPTH"} = join " ", setup_values(split m/\s+/, $pars{"DEPTH"});

    return %pars;
}

sub setup_values() {# parse arguments of DIST FKDEPTH CAPDEPTH
    my @out;
    foreach (@_) {
        if ($_ =~ m/\//g) {
            my ($start, $end, $delta) = split m/\//;
            for (my $value = $start; $value <= $end; $value = $value + $delta) {
                push @out, $value;
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
        my ($key, $value) = split ":", $line;
        next unless (defined($key) and defined($value));
        $key = trim($key);
        $value = trim($value);
        $pars{$key} = $value;
    }
    return %pars;
}

sub setup_cap_args() {
    my (%pars) = @_;

    my $cap_args;

    my @args = keys %pars;
    foreach my $args (@args) {
        next unless ($args =~ "-");
        $cap_args .= "$args$pars{$args} ";
    }

    return $cap_args;
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

1;
