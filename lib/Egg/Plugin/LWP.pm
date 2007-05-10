package Egg::Plugin::LWP;

=head1 NAME

Egg::Plugin::LWP - LWP for Egg Plugin.

=head1 SYNOPSIS

  use Egg qw/ LWP /;
  
  __PACKAGE__->egg_startup(
   ...
   .....
  
   plugin_lwp => {
     timeout => 10,
     agent   => 'MyApp Agent.',
     },
  
    );

  # The GET request is sent.
  my $res= $e->ua->request( GET => 'http://domain.name/hoge/' );
  
  # The POST request is sent.
  my $res= $e->ua->request( POST => 'http://domain.name/hoge/form', {
    param1 => 'hooo',
    param2 => 'booo',
    } );
  
  # It requests it GET doing to pass ua the option.
  my $res= $e->ua( agent => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)' )
             ->request( GET => 'http://domain.name/hoge/' );
  
  # It turns by using ua made once.
  my $ua= $e->ua( timeout => 5 );
  for my $domain (qw/ domain1 domain2 domain3 /) {
    my $res= $ua->request( GET => "http://$domain/" ) || next;
    $res->is_success || next;
    $res->...
  }

=head1 DESCRIPTION

It is a plugin to use L<LWP::UserAgent>.

Please define HASH in 'plugin_lwp' about the setting.
All these set values are passed to L<LWP::UserAgent>.

* Please refer to the document of L<LWP::UserAgent> for the option.

=cut
use strict;
use warnings;

our $VERSION = '2.00';

sub _setup {
	my($e)= @_;
	my $conf= $e->config->{plugin_lwp} ||= {};
	$conf->{timeout} ||= 10;
	$conf->{agent}   ||= __PACKAGE__. " v$VERSION";
	$e->next::method;
}

=head1 METHODS

=head2 ua ( [UA_OPTION_HASH] )

The handler object of Egg::Plugin::LWP is returned.

When UA_OPTION_HASH is given, everything is passed to L<LWP::UserAgent> as an 
option.

UA_OPTION_HASH overwrites a set value of default.

=cut
sub ua { Egg::Plugin::LWP::handler->new(@_) }


package Egg::Plugin::LWP::handler;
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common qw/ GET POST /;

=head1 HANDLER METHODS

=head2 new

It is a constructor who is called by $e-E<gt>ua.

L<LWP::UserAgent> object is generated here.

=cut
sub new {
	my($class, $e)= splice @_, 0, 2;
	my $ua= LWP::UserAgent->new(
	  %{$e->config->{plugin_lwp}},
	  %{$_[1] ? {@_}: ($_[0] || {})},
	  );
	bless { e=> $e, ua=> $ua }, $class;
}

{
	no strict 'refs';  ## no critic

=head2 request ( [REQUEST_METHOD], [URL], [ARGS_HASH] )

The request is sent based on generated ua.

When an invalid value to REQUEST_METHOD is passed, it treats as GET request.

URL is not omissible. The exception is generated when omitting it.

ARGS_HASH is treated as an argument passed to L<HTTP::Request::Common>.

L<HTTP::Response> object that ua returns after completing the request is returned.

  my $res= $e->ua->request(0, 'http://domain.name/');

=cut
	sub request {
		my($self, $method, $url, $args)= _get_args(@_);
		$self->{ua}->request( &{$method}($url, %$args) );
	}

=head2 simple_request

Simple_request of L<LWP::UserAgent> is done.

The argument and others is similar to 'request' method.

  my $res= $e->ua->simple_request(0, 'http://domain.name/');

=cut
	sub simple_request {
		my($self, $method, $url, $args)= _get_args(@_);
		$self->{ua}->simple_request( &{$method}($url, %$args) );
	}
  };

sub _get_args {
	my $self= shift;
	my $meth= uc(shift) || 'GET';
	my $url = shift || die qq{ I want 'url' };
	($self, $meth, $url, ($_[1] ? {@_}: ($_[0] || {})));
}

=head1 SEE ALSO

L<LWP::UserAgent>,
L<HTTP::Request::Common>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
