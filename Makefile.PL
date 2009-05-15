use inc::Module::Install;
name 'Cache-Ehcache';
all_from 'lib/Cache/Ehcache.pm';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
