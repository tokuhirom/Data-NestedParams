package Data::NestedParams;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.02";

use parent qw(Exporter);

our @EXPORT = qw(convert_nested_query);

# https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L90

sub parse {
    my $k = shift;

    my @keys;
    while (1) {
        if ($k =~ s/\[(\w+)\]\z//) {
            unshift @keys, ['%', $1];
        } elsif ($k =~ s/\[\]\z//) {
            unshift @keys, ['@'];
        } else {
            unshift @keys, ['$', $k];
            last;
        }
    }
    return @keys;
}

sub set_value {
    my ($ret, $k, $v) = @_;

    my @keys = parse($k);

    my $r = \$ret;
    while (@keys) {
        my $key = shift @keys;
        if ($key->[0] eq '%') {
            if (@keys) {
                $r = \(${$r}->{$key->[1]});
            } else { # last
                ${$r}->{$key->[1]} = $v;
            }
        } elsif ($key->[0] eq '@') {
            if (@keys) {
                $r = \(${$r}->[$key->[1]]);
            } else { # last
                push @{$$r}, $v;
            }
        } elsif ($key->[0] eq '$') {
            if (@keys) {
                $r = \(${$r}->{$key->[1]});
            } else {
                ${$r}->{$key->[1]} = $v;
            }
        } else {
            die "ABORT: $key->[0]";
        }
    }
}

sub convert_nested_query {
    my $ary = shift;
    my $ret = +{};
    while (my ($k, $v) = splice @$ary, 0, 2) {
        set_value($ret, $k, $v);
    }
    return $ret;
}

1;
__END__

=encoding utf-8

=head1 NAME

Data::NestedParams - It's new $module

=head1 SYNOPSIS

    use Data::NestedParams;

=head1 DESCRIPTION

Data::NestedParams is ...

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=cut

