use File::Basename;
use lib dirname(__FILE__), 'inc';
use Test::More tests => 1;

eval <<'...';
package Foo;
use base 'NonSpiffy';
...

is $@, '';
