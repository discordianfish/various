#!/usr/bin/env perl
use strict;
use warnings;

use constant API_KEY => '5346da9a42bc26daa40d3aad9866e71b';
use constant API_SECRET => 'f71d99d43be0ffec625028e1bd1a35c2';

use File::Basename;
use WWW::Facebook::API;

my ($PATH, $AID) = @ARGV;

die "echo path/to/file.jpg | $0 path [album-id]"
    unless $PATH;

my $client = WWW::Facebook::API->new
(
    desktop => 1,
    throw_errors => 1,
    parse => 1,
);

$client->api_key(API_KEY);
$client->secret(API_SECRET);

my $token = $client->auth->login(browser => 'echo', sleep => 1); #create_token;
print "press return after visiting\n";
<STDIN>;
$client->auth->get_session($token);

unless ($AID)
{
    use Data::Dumper;
    $AID = ($client->photos->create_album(name => basename $PATH))->{aid}
        or die 'could not create new album';
}
for my $file (<$PATH/*>)
{
    open my $fh, '<', $file;
    unless ($fh)
    {
        warn "could not read $file";
        next;
    }
    my ($name, $path, $suffix) = fileparse $file;

    my $data;
    while ($fh->sysread(my $buffer, 256000)) { $data .= $buffer };
    close $fh;
    
    print "uploading $file\n";
    $client->photos->upload
    (
        aid => $AID,
        caption => $name,
        data => $data,
    );
}