use Mojo::Base -strict;

use Mojo::JSON;
use Mojo::mysql;
use Test::More;

plan skip_all => 'TEST_ONLINE=mysql://root@/test' unless $ENV{TEST_ONLINE};

my $mysql = Mojo::mysql->new($ENV{TEST_ONLINE});
my $db    = $mysql->db;

eval {
  $db->query('drop table if exists mojo_json_test');
  $db->query('create table mojo_json_test (id int(10), name varchar(60), j json)');
  $db->query('insert into mojo_json_test (id, name, j) values (?, ?, ?)', $$, $0, {json => {foo => 42}});
} or do {
  plan skip_all => $@;
};

is $db->query('select json_type(j) from mojo_json_test')->array->[0],             'OBJECT', 'json_type';
is $db->query('select json_extract(j, "$.foo") from mojo_json_test')->array->[0], '42',     'json_extract';
is_deeply $db->query('select id, name, j from mojo_json_test where json_extract(j, "$.foo") = 42')->expand->hash,
  {id => $$, name => $0, j => {foo => 42}}, 'expand json';

$db->query('insert into mojo_json_test (name) values (?)', {json => {nick => 'supergirl'}});
is_deeply $db->query('select name from mojo_json_test where name like "%supergirl%"')->expand->hash,
  {name => Mojo::JSON::to_json({nick => 'supergirl'})}, 'name as string';

is_deeply $db->query('select name from mojo_json_test where name like "%supergirl%"')->expand(1)->hash,
  {name => {nick => 'supergirl'}}, 'name as hash';

# extended JSON

# INSERT

ok $db->query('delete from mojo_json_test'), 'clean db';
my @testvalues = (
  {id => 1, name => 'Katniss Everdeen', j => {district => 12, mascot => 'Mockingjay', tournament => 74,}},
  {
    id   => 2,
    name => 'Peeta Mellark',
    j    => {district => 12, occupation => 'baker', skills => 'camouflage', tournament => 74,}
  },
  {id => 3, name => 'Primrose Everdeen',  j => {district => 12, skills     => 'healing'}},
  {id => 4, name => 'Haymitch Abernathy', j => {district => 12, tournament => 50,}},
  {id => 5, name => 'Rue',                j => {district => 11, tournament => 74,}},
  {id => 6, name => 'Gale Hawthorne',     j => {district => 12, occupation => 'miner',}},
);

for (@testvalues) {
  ok $db->insert('mojo_json_test', $_), "insert $_->{name}";
}

# SELECT

is_deeply $db->select('mojo_json_test', '*', {id => 1})->expand->hash, $testvalues[0], 'content for Katniss';

is_deeply $db->select('mojo_json_test', ['name', 'j->>district', 'j->>occupation'], {id => 2})->hash,
  {district => 12, name => 'Peeta Mellark', occupation => 'baker'}, 'details for Peeta';

is_deeply $db->select('mojo_json_test', ['name'], {'j->>tournament' => 50})->hash,
  {name => 'Haymitch Abernathy'}, 'Haymitch was in 50';

is_deeply $db->select('mojo_json_test', ['name'], {-e => 'j->skills'})->arrays,['Peeta Mellark','Primrose Everdeen'], 'who has skills';

done_testing;
