use strict;
use warnings;

use Plack::Builder;
use Plack::Middleware::Session;
use Cache::Memcached::Fast;
use Plack::Session::Store::Cache;
use Plack::Session::State::Cookie;

use Router::Simple->new;

my $map = Router::Simple->new;

$map->connect('/',{c =>'Root',action => index'});

use Plack::Request;
my $app = sub{

  my $req = Plack::Request->new(shift);

  my $param = $map->match($req->env);

  my $controller = "App::" . delete $param->{c};
  my $action = delete $param->{action};

  my $res = $controller->$acion($req,$param);

  return $res->finalize;

};

builder {
    enable 'Plack::Middleware::Session',
        store => Plack::Session::Store::Cache->new(
           cache => Cache::Memcached::Fast->new(+{
               servers => ["localhost:11211"],   
               namespace => 'App',
           }),
        ),
        state => Plack::Session::State::Cookie->new(
               session_key => 'app_session',
               httponly =>1,
               expires => 604800,
        );
    $app;
};