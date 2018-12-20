#!/usr/bin/env perl
use Mojo::Base -strict;

use App::Prove;
use FindBin;
use Mojo::Util qw|getopt|;

chdir "$FindBin::Bin/..";

getopt 'l|limit=s' => \my $limit;

my $testuser = 'testuser';
my $testpwd  = 'Abc1234';
my $testdb   = 'test';
my @hosts    = (

  # {code => 'maria103', name => 'MariaDB 10.3', ip => '192.168.1.110', port => 33063},
  {code => 'maria103', name => 'MariaDB 10.3', ip => '127.0.0.1', port => 33063},
  {code => 'maria104', name => 'MariaDB 10.4', ip => '127.0.0.1', port => 33064},
  {code => 'my56',     name => 'MySQL 5.6',    ip => '127.0.0.1', port => 33056},
  {code => 'my57',     name => 'MySQL 5.7',    ip => '127.0.0.1', port => 33057},
  {code => 'my80',     name => 'MySQL 8.0',    ip => '127.0.0.1', port => 33080, ssl => 1,},
);
my %only = $limit ? map { $_ => 1 } split /,/, $limit : ();

my $app  = App::Prove->new;
my @args = qw|-I lib|;
push @args, @ARGV if @ARGV;

$ENV{TEST_FOR}       = 500;
for my $host (@hosts) {
  next if $limit && !$only{$host->{code}};

  $ENV{TEST_ONLINE} = qq|mysql://$testuser:$testpwd\@$host->{ip}:$host->{port}/$testdb|;
  $ENV{TEST_ONLINE} .= ';mysql_ssl=1' if $host->{ssl};
  $ENV{TEST_PUBSUB} = $host->{code} eq 'my80' ? 0 : 1;
  $app->process_args(@args);
  say "\n$host->{name} ($host->{code}):";
  $app->run;
  say "($host->{name})";
}
