#!/usr/bin/perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Cache::Ehcache;

my $cache = Cache::Ehcache->new( namespace => 'cache_ehcache' );
$cache->set( 'foo', 'bar' );
print $cache->get('foo') . "\n";

$cache->delete('foo');
print $cache->get('foo') . "\n";

$cache->delete('baz');

$cache->clear;

exit;
