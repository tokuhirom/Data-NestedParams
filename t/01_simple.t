use strict;
use warnings;
use utf8;
use Data::Section::TestBase;
use Test::More;
use Data::NestedQuery;

use Data::Dumper;

sub ddf {
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 0;
    Data::Dumper::Dumper(@_);
}

for (blocks) {
    my $input = eval($_->input);
    die $@ if $@;

    my $expected = eval($_->expected);
    die $@ if $@;

    diag "--- Testing --- ";
    diag ddf($input);
    my $got = convert_nested_query($input);
    diag ddf($got);
    is_deeply( $got, $expected );
}

done_testing;

__DATA__

===
--- input
+[
    'a' => 'x',
],
--- expected
+{
    'a' => 'x',
}

===
--- input
+[
    'a[]' => 'x',
    'a[]' => 'y',
],
--- expected
+{
    'a' => [qw(x y)],
}

===
--- input
+[
    'a[foo]' => 'x',
],
--- expected
+{
    'a' => {
        foo => 'x',
    }
}

===
--- input
+[
    'a[foo][bar]' => 'x',
],
--- expected
+{
    'a' => {
        foo => {
            bar => 'x',
        }
    }
}

===
--- input
+[
    'a[foo][bar][]' => 'x',
],
--- expected
+{
    'a' => {
        foo => {
            bar => ['x'],
        }
    }
}

