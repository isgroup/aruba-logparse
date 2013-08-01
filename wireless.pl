#!/usr/bin/perl -w
use strict;
use warnings;

use File::Tail;
use Parse::Syslog;
use IO::Handle qw();

autoflush STDOUT 1;

sub trim($) {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

my $logFile = "/var/log/aruba-userdebug.log";

my @ignoreLogs = (
	"AM: Sending Laser Beam Active Frame",
	"add more here.."
);

my %ignoreLogsHash = map { $_ => 1 } @ignoreLogs;

my $file = File::Tail->new(name=>$logFile, maxinterval=>1);
while (defined(my $line=$file->read)) {
	if($line =~ m/(\w{3}\s+\d{1,2}\s\d{2}:\d{2}:\d{2})\s([^\s]*)\s([^\s:]*):\s([^\s]*)\s([^\s]*)\s([<|][^<|]*[>|])\s\s(.*)$/) {
		my $date=$1;
		my $host=$2;
		my $facility=$3;
		my $mesg=$4;
		my $level=$5;
		my $device=$6;
		my $message=trim($7);
		if (!exists($ignoreLogsHash{$message})) {
			print "Date\t$date\n";
			print "Host\t$host\n";
			print "Facility\t$facility\n";
			print "Mesg\t$mesg\n";
			print "Level\t$level\n";
			print "Device\t$device\n";
			print "Message\t$message\n";
			print "--\n";
		}
	} else {
		print "Martian log: $line";
	}
}
