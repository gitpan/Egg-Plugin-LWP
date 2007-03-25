
use Test::More qw/no_plan/;
use Egg::Helper;

my $test= Egg::Helper->run('O:Test');

$test->prepare({ controller=> { egg=> 'LWP' } });

my $e= $test->egg_virtual;

ok my $ua= $e->ua;
ok ref($ua) eq 'LWP::UserAgent';
like $ua->agent, qr{Egg\:\:Plugin\:\:LWP\s+v[\d\.]+};
ok $ua->timeout == 10;
ok my($self, $lua, $method, $url, $args)= Egg::Plugin::LWP::args::get
    ( $e, 0, POST=> 'http://domainname/', { param1=> 'test1' } );
ok ref($lua) eq 'LWP::UserAgent';
ok $method eq 'POST';
ok $url eq 'http://domainname/';
ok ref($args) eq 'HASH';
ok $args->{param1};
ok $args->{param1} eq 'test1';
ok my $res= $e->ua_request($ua, GET=> 'http://dummy');
ok ref($res) eq 'HTTP::Response';
