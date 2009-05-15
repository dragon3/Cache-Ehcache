package Cache::Ehcache;

use strict;
use warnings;

use LWP::UserAgent;

our $VERSION = '0.01';

use Moose;

has 'server' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    default  => 'http://localhost:8080/ehcache/rest/',
);

has 'namespace' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'default_expires_in' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    default  => 0,
);

has 'ua' => (
    is       => 'rw',
    isa      => 'Object',
    required => 1,
    default  => sub {
        my $self = shift;
        my $ua   = LWP::UserAgent->new(
            agent   => __PACKAGE__ . "/$VERSION",
            timeout => 60,
        );
        return $ua;
    },
);

sub BUILDARGS {
    my ( $class, %args ) = @_;
    if (   $args{server}
        && $args{server} !~ m{/$} )
    {
        $args{server} = $args{server} . '/';
    }
    return {%args};
}

__PACKAGE__->meta->make_immutable;
no Moose;

use HTTP::Request;
use HTTP::Status qw(:constants);

sub set {
    my $self = shift;
    my ( $key, $value, $expires_in ) = @_;

    my @header =
      ($expires_in) ? ( 'ehcacheTimeToLiveSeconds' => $expires_in ) : ();
    my $req =
      HTTP::Request->new( 'PUT', $self->_make_url($key), \@header, $value );
    my $res = $self->ua->request($req);
    unless ( $res->is_success ) {
        warn $res->status_line;
    }
}

sub get {
    my $self  = shift;
    my ($key) = @_;
    my $res   = $self->ua->get( $self->_make_url($key) );
    if ( $res->is_success ) {
        return $res->decoded_content;
    }
    elsif ( $res->code != HTTP_NOT_FOUND ) {
        warn $res->status_line;
    }
}

sub delete {
    my $self  = shift;
    my ($key) = @_;
    my $req   = HTTP::Request->new( 'DELETE', $self->_make_url($key) );
    my $res   = $self->ua->request($req);
    if ( !$res->is_success && $res->code != HTTP_NOT_FOUND ) {
        warn $res->status_line;
    }
}

sub clear {
    my $self = shift;
    my $req  = HTTP::Request->new( 'DELETE', $self->_make_url('*') );
    my $res  = $self->ua->request($req);
    unless ( $res->is_success ) {
        warn $res->status_line;
    }
}

sub _make_url {
    my $self = shift;
    my ($path) = @_;
    return $self->server . $self->namespace . ( $path ? "/$path" : '' );
}

1;
__END__

=head1 NAME

Cache::Ehcache - client library for Ehcache Server

=head1 SYNOPSIS

  use Cache::Ehcache;

  my $cache = Cache::Ehcache->new({
    'server'             => 'http://localhost:8080/ehcache/rest/',
    'namespace'          => 'mynamespace',
    'default_expires_in' => 600, # option
  });

  # set cache element
  $cache->set('key_1', 'value_1');
  $cache->set('key_2', 'value_2', 3600);   # specify expires_in

  # get cache element
  my $value = $cache->get('key_1');

  # delete cache element
  $cache->delete('key_2');

  # remove all elements of this cache
  $cache->clear();

=head1 DESCRIPTION

Cache::Ehcache is

=head1 AUTHOR

YAMAMOTO Ryuzo E<lt>yamamoto@nulab.co.jpE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or
        modify it under the same terms as Perl itself .

=head1 SEE ALSO

Ehcache Site
  http://ehcache.sourceforge.net/index.html
  http://ehcache.sourceforge.net/documentation/cache_server.html

=cut
