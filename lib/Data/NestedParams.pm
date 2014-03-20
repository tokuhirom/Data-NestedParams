package Data::NestedParams;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.04";

use parent qw(Exporter);

our @EXPORT = qw(expand_nested_params);

# https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L90
# 9a74ba3b04f2dabe4741d2d82eae723d440c3aa2

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
                if (defined($$r)) {
                    if (ref($$r->[@$$r-1]) eq 'HASH' && $keys[0]->[0] eq '%' && not exists $$r->[@$$r-1]->{$keys[0]->[1]}) {
                        $r = \(${$r}->[@$$r-1]);
                    } else {
                        $r = \(${$r}->[0+@$$r]);
                    }
                } else {
                    $r = \(${$r}->[0]);
                }
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

sub expand_nested_params {
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

Data::NestedParams - entry[title]=foo&tags[]=art&tags[]=modern

=head1 SYNOPSIS

    use Data::NestedParams;

    my $expanded = expand_nested_params(
        [
            'entry[title]' => 'foo',
            'tags[]' => 'art',
            'tags[]' => 'modern',
        ]
    );
    # $expanded = { entry => {title => 'foo'}, tags => ['art', 'modern'] };

=head1 DESCRIPTION

Ruby on Rails has a nice feature to create nested parameters that help with the organization of data in a form - parameters can be an arbitrarily deep nested structure.

The way this structure is denoted is that when you construct a form the field names have a special syntax which is parsed.

=head1 TODO

Support C<collapse_nested_params()>.

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=head1 SEE ALSO

L<Catalyst::Plugin::Params::Nested>, L<CGI::Expand>
L<https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L90>

=cut

