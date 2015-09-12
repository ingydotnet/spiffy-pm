#
# Tests issue reported at: https://github.com/ingydotnet/spiffy-pm/issues/4
#
# Basically, issue is that spiffy_dump() overrides any configured (or
# default) behavior of Data::Dumper by setting indenting and key
# sorting.
#
# We validate that keys remain in an unsorted order after calling
# spiffy_dump.
#
# Note that there isn't a great way to do it.
#

use strict; use warnings;
use lib (-e 't' ? 't' : 'test'), 'inc';

package Foo;
use Spiffy qw(-base -dumper);
BEGIN { @Foo::EXPORT=qw(xxx) }
sub xxx {}
sub e {
    my $self = shift;
    # Call error reporting function
    $self->XXX(main::buildtesthash());
}

package main;
use Data::Dumper;
use Test::More tests => 5;

my $skip;

# Just in case Data::Dumper doesn't exist in core at some point
eval { require Data::Dumper; };
if ($@) { $skip = 1; }

ok(Foo->isa('Spiffy'));

my $f = new Foo;
ok(defined $f, 'instantiated');

SKIP: {
    skip 'Data::Dumper failed require', 3 if $skip;

    $Data::Dumper::Sortkeys = undef;  # Just in case the default changes

    eval { $f->e(); };
    my $out = $@;
    ok($out, "properly died");

    my $tmphash = buildtesthash();
    my $keys = [ sort keys %$tmphash ];

    ok(checkdumpsort($keys, $out), 'keys inside of Spiffy in sorted order');

    my $d = Data::Dumper::Dumper($tmphash);
    ok(!defined(checkdumpsort($keys, $d)),
        'keys outside of Spiffy not in sorted order');
}

# Checks dump ordering matches the array reference provided by keys
# This isn't a great checker - but I want it to work if Data::Dumper
# makes any small changes to output format.  So you want to test with a
# lot of longish keys, so that they are unlikely to appear on their own
# and so that it's unlikely to randomly end up in order if we aren't
# sorting inside of Data::Dumper.
sub checkdumpsort {
    my $keys = shift;
    my $dumpout = shift;

    my $curr;
    my $prev;
    foreach my $k (@$keys) {
        $prev = $curr;
        $curr = $k;
        if (!defined($prev)) { next; }

        if ($dumpout =~ m/${prev}.*${curr}/s) {
            # Good
        } else {
            # Bad
            return undef;
        }
    }

    return 1;  # We're good.
}

# This builds a hash.  Keys are 'aaa' through 'zzz' and 'AAA' through
# 'ZZZ'.  Values are set to the first character of the key.
sub buildtesthash {
    my $tmphash;
    for(my $c='a'; ord($c)<ord('z'); $c=chr(ord($c)+1)) {
        $tmphash->{"$c$c$c"} = $c;
        my $v = uc($c);
        $tmphash->{"$v$v$v"} = $v;
    }

    return $tmphash;
}

