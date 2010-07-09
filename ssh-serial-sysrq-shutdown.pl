#!/usr/bin/env perl
# tool to connect to a ssh based terminal server and send it
# a sysrq/break code to (hopefully) shutdown the system in a sane
# manner
# the 'sending break'-sequence is written for cyclades ts-3000
# see the contant RQ

use strict;
use warnings;
use lib 'perl'; # perl/ relative dir for modules

use constant RQ => "\n\n~break";

use Net::OpenSSH;

my ($user,$host) = @ARGV or die "$0 user host";

my $ssh = Net::OpenSSH->new($host, user => $user);
die "Couldn't establish SSH connection: ". $ssh->error if $ssh->error;



my @proc = 
(
	{
		desc => 'TERM. Waiting for "%s"',
		code => 'e',
		wait => 'SysRq : Terminate All Tasks', sleep => 30
	},
	{
		desc => 'KILL. Waiting for "%s"',
		code => 'i',
		wait => 'SysRq : Kill All Tasks'
	},
	{
		desc => 'Flushing filesystem cache. Waiting for "%s"',
		code => 's',
		wait => 'Emergency Sync complete'
	},
	{
		desc => 'Remounting read-only. Waiting for "%s"',
		code => 'u',
		wait => 'Emergency Remount R/O'
	},
	{
		desc => 'Power off',
		code => 'o'
	},
);

my ($pty, $pid) = $ssh->open2pty;

for my $p (@proc)
{
	printf $p->{desc} . "\n", $p->{wait};
	print $pty RQ . $p->{code};
	while (my $line = <$pty>)
	{
		print $line;
		last if $line =~ m/$p->{wait}/ or not $p->{wait};
	}
	if ($p->{sleep})
	{
		print "\tgiving $p->{sleep}s time to complete\n";
		sleep $p->{sleep}
	}
}
