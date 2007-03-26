package Egg::Plugin::LWP;
#
# Copyright (C) 2006 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>mizunoE<64>bomcity.comE<gt>
#
# $Id: LWP.pm 62 2007-03-25 08:36:07Z lushe $
#
use strict;
use LWP::UserAgent;
use HTTP::Request::Common qw/GET POST/;

our $VERSION = '0.04';

sub setup {
	my($e)= @_;
	$e->config->{plugin_lwp} ||= {};
	$e->config->{plugin_lwp}{timeout} ||= 10;
	$e->config->{plugin_lwp}{agent} ||= __PACKAGE__. " v$VERSION";
	$e->next::method;
}
sub ua {
	my $e= shift;
	my %opt= %{$e->config->{plugin_lwp}};
	if (@_) {
		my $args= ref($_[0]) ? $_[0]: {@_};
		@opt{keys %$args}= values %$args;
	}
	LWP::UserAgent->new(%opt);
}
sub ua_request {
	my($e, $ua, $method, $url, $args)= Egg::Plugin::LWP::args::get(@_);
	no strict 'refs';  ## no critic
	$ua->request( &{$method}($url, %$args) );
}
sub ua_simple_request {
	my($e, $ua, $method, $url, $args)= Egg::Plugin::LWP::args::get(@_);
	no strict 'refs';  ## no critic
	$ua->simple_request( &{$method}($url, %$args) );
}

package Egg::Plugin::LWP::args;
use strict;
sub get {
	my $e = shift;
	my $ua= shift || $e->ua;
	my $meth= uc(shift) || 'GET';
	my $url = shift || Egg::Error->throw(q/I want URL/);
	my $args= shift || {};
	return ($e, $ua, $meth, $url, $args);
}

1;

__END__

=head1 NAME

Egg::Plugin::LWP - LWP for Egg.

=head1 SYNOPSIS

  package [MYPROJECT]
  use strict;
  use Egg qw/LWP/;

Configuration is setup.

  plugin_lwp=> {
    timeout=> 10,
    agent  => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
    },

* This item will set the option to pass to L<LWP::UserAgent>.

Example of code.

  my $response= $e->ua->get( 'http://yyyyyy.com/' );
  
    or
  
  my $response= $e->ua_request(0, POST=> 'http:/domain/form.cgi', {
    param1=> 'param string1',
    param2=> 'param string2',
    });
  
    or
  
  my $ua= $e->ua;
  $ua->proxy('http', 'http://proxy:8080');
  $ua->cookie_jar( HTTP::Cookies->new( file=> "cookies.txt") );
  my $response= $e->ua_request($ua, POST=> 'http:/domain/form.cgi', {
    ...
    });
  
  $response->is_success || die $response->status_line;
  
  my $content= $response->content || "";
  ...
  ...

=head1 DESCRIPTION

This module is wrapper of LWP::UserAgent and HTTP::Request::Common.
Please see the document of LWP::UserAgent and HTTP::Request::Common in detail.

=head1 METHODS

=head2 ua ([OPTION]);

LWP::UserAgent object is returned.

When the option is passed, the setting of the configuration is overwrited.

=head2 ua_request ([UA], [METHOD], [URL], [PARAMS]);

The HTTP::Response object that LWP::UserAgent returns is returned.

  UA     =  LWP::UserAgent object.
  METHOD =  'GET' or 'POST'.  default is 'GET'.
  URL    =  request URL.
  PARAMS =  Parameter put on URL.  ( HAHS reference )

=head2 ua_simple_request ([UA], [METHOD], [URL], [PARAMS]);

LWP::UserAgent-E<gt>simple_request is called and the same thing as $e-E<gt>us_request is done.

=head2 setup

It is a method for the start preparation that is called from the controller of 
the project. * Do not call it from the application.

=head1 SEE ALSO

L<LWP::UserAgent>,
L<HTTP::Request::Common>,
L<HTTP::Response>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>mizunoE<64>bomcity.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2006 by Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

