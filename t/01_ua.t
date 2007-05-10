
use Test::More tests => 12;
use Egg::Helper::VirtualTest;

my $test= Egg::Helper::VirtualTest->new(
  prepare => { controller => { egg_includes=> [qw/ LWP /] } }
  );

ok my $e= $test->egg_context;
can_ok $e,     qw/ ua /;
can_ok $e->ua, qw/ new request simple_request /;
isa_ok $e->ua,       'Egg::Plugin::LWP::handler';
isa_ok $e->ua->{ua}, 'LWP::UserAgent',

ok my($self, $method, $url, $args)=
   Egg::Plugin::LWP::handler::_get_args
      ($e, POST=> 'http://domainname/', { param1=> 'test1' });

is $method, 'POST';
is $url,    'http://domainname/';
isa_ok $args, 'HASH';
is $args->{param1}, 'test1';
ok my $res= $e->ua->request( GET => 'http://dummy');
isa_ok $res, 'HTTP::Response';

