#!/usr/bin/env perl
use strict;
use warnings;

use constant API_KEY => '5346da9a42bc26daa40d3aad9866e71b';
use constant API_SECRET => 'f71d99d43be0ffec625028e1bd1a35c2';

use File::Basename;
use File::Spec;
use WWW::Facebook::API;

my @PATHS = @ARGV;

die "$0 path [path2.. path3..]"
    unless @PATHS;

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


for my $path (@PATHS)
{
    print "uploading files in $path\n";
    my $AID = $ENV{AID} ? $ENV{AID} : ($client->photos->create_album(name => basename $path))->{aid}
        or die 'could not create new album';
 
    opendir(my $dir, $path);
    unless ($dir)
    {
        warn "could not readdir $dir";
        next;
    }
        
    while (my $file = readdir $dir)
    {
        next if $file eq '.';
        next if $file eq '..';

        open my $fh, '<', File::Spec->catdir($path, $file);
        unless ($fh)
        {
            warn "could not read $file";
            next;
        }
    
        my $data;
        while ($fh->sysread(my $buffer, 256000)) { $data .= $buffer };
        close $fh;

        unless ($data)
        {
            warn "no data in $file, skipping";
            next;
        }
        
        print "   uploading $file\n";
        $client->photos->upload
        (
            aid => $AID,
            caption => $file,
            data => $data,
        );
    }
    close $dir;
}
