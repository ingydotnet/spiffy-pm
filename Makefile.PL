use inc::Module::Install;

all_from    'lib/Spiffy.pm';
readme_from;
manifest_skip;
version_check;
ack_xxx;
repository 'git://github.com/ingydotnet/cog-pm.git';

requires    'Filter::Util::Call' => '0';
requires    'Scalar::Util' => '0';

WriteAll;
