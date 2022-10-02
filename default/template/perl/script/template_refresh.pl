#!/usr/bin/perl -T

# template_refresh.pl
# this script checks for defaults which have been updated after their config values
# primarily used during development

exit;
# script has not been tested well yet

require('./utils.pl');

use strict;
use warnings;
use 5.010;

my @config = `find config`;
my @default = `find default`;

#todo sanity checks

my @changed;

my %changedTopLevel;

for my $c (@config) {
	#todo rename $c
	#todo sanity check each line should begin with config/
	WriteLog('template_refresh.pl: $c = ' . $c);

	if ($c =~ m/^config\/(\S+)$/) { #sanity check on config filename
		$c = trim($c);
		my $key = $1;
		if ($key && -f "config/$key" && -f "default/$key") {
			#print "-";
			my $configTime = filemtime("config/$key");
			my $defaultTime = filemtime("default/$key");

			if ($defaultTime && $configTime) {
				#print "+";
				if ($defaultTime > $configTime) {
					#print ('"');
					if (-f $c) {
						WriteLog('template_refresh.pl: change found: $c = ' . $c);

						push @changed, $key;
						#print "$key\n";

						my $changedCategory = substr($key, 0, index($key, '/'));
						$changedTopLevel{$changedCategory} = 1;
					} else {
						print "$c\n";
					}
				} # if ($defaultTime > $configTime)
			} # if ($key && -f "config/$key" && -f "default/$key")
		} # if ($key && -f "config/$key" && -f "default/$key")
	} # # if ($c =~ m/^config\/(\S+)$/)
} # for my $c (@config)

#print "=====================\n";
for my $key (@changed) {
	if (-f "config/$key" && !-f "default/$key") {
		print $key;
		print "\n";
		print "---";
		print "\n";
		#print "default: " . GetDefault($key);
		print "default: ";
		`cat default/$key`;
		print "\n";
		#print "config: " . GetConfig($key);
		print "config: ";
		print "\n";
		`cat config/$key`;
		#print "\n";
		print "===";
		print "\n";
	} # if (-f "config/$key" && !-f "default/$key")
} # for my $key (@changed)

my $changeCount = scalar(@changed); # like 5

WriteLog('template_refresh.pl: scalar(@changed) = ' . scalar(@changed));

if ($changeCount) {
	print "\n";
	print "=====================\n";
	print "DEFAULTS CHANGED: $changeCount \n";
	for my $change (@changed) {
		print $change;
		print "\n";
	}
	print "=====================\n";
	print "Refreshing in 2s ... \n";
	print "=====================\n";

	sleep 2;

	for my $key (@changed) {
		if (-f "config/$key") {
			`rm -v config/$key`;
			print "\n";
		}
		print "$key";
		if ($key =~ m/^template\/(js\/.+)/) {
			my $jsFile = $1;
			print `grep \"$jsFile\" html -irl`;
		}
	}
} # if ($changeCount)

print "\n";

1;