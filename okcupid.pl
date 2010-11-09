#!/usr/bin/env perl
use strict;
use warnings;

use Mojo::Client;
use Config::Simple;
use Data::Dumper;
use constant OKC => 'http://www.okcupid.com';

my $LOGIN =  OKC . '/login';
my $JOURNAL = OKC . '/jpost';
my $POST = OKC . '/profile/discordianfish/journal';

my $post = "@ARGV" or die "$0 message to send";

my $cfg = Config::Simple->new("$ENV{HOME}/.okcupidrc") or die <<EOF
You need to provide username and password in ~/.okcupidrc, like:

username = discordianfish
password = foobar23

(Watchout for proper permission!)
EOF
;
my $c = Mojo::Client->new;
my $tx;

$tx = $c->post_form($LOGIN =>
{
    username => $cfg->param('username'),
    password => $cfg->param('password'),
});
die "could not login: $tx->error" unless $tx->success;

$tx = $c->get($JOURNAL);
die "could not load journal page" unless $tx->success;


my %FORM;
$tx->res->dom('form[id="jpost_form"] input')->each(sub
{
    my $attr = shift->attrs;
    $FORM{ $attr->{name} } = $attr->{value};
});

$post =~ m/^(.{0,45})(.?)/;
my $title = $1;
$title .= '...' if $2;

$tx = $c->post_form($POST =>
{
    %FORM,
    title => $title,
    content => $post,
    commentsecurity => 0,
    commentapproval => 0,
    postsecurity => 0,
});

die "could not post: $tx->error" unless $tx->success;

print "message sent\n";
