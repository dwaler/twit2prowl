#!/usr/bin/perl
#
use strict;
use warnings;
no warnings 'once';
use Getopt::Long;
use Net::Twitter::Lite;
use LWP::UserAgent;

my ($lasttweet,$tweets,$userAgent,$request,$response,$requestURL,$user);
my $configfile = "twit2prowl.conf";
my $cache = 0;

sub readConfig {
  package cfg;
  my $configfile = shift;
  die "Error: configfile $configfile does not exist!" unless (-e $configfile);
  do($configfile);
  1;
}

readConfig($configfile);

$tweets = Net::Twitter::Lite->new(
  %{cfg::consumer_tokens}, 
  %{cfg::access_tokens}, 
  legacy_lists_api => 0,
);

if (! -e $cfg::cachefile) {
  $lasttweet = 0;
} 

else {
  open(TIMESTAMP,$cfg::cachefile) or die "Can't open file which contains the ID of our last tweet: $!\n";
  $lasttweet = <TIMESTAMP>;
  close(TIMESTAMP);
}

my $mentions = $tweets->mentions();
foreach my $mention (@{$mentions}) {
  if ($mention->{id} > $lasttweet) {
    # Generate our HTTP request
    $userAgent = LWP::UserAgent->new;
    $userAgent->agent("ProwlScript/1.2");
    $userAgent->env_proxy();

    # URL encode our tweet
    $mention->{text} =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg; 
    $user = $mention->{user}->{screen_name} . " (" . $mention->{user}->{name} . ")";
    $user =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;
    print "Sending tweet with id " . $mention->{id} . "\n" if $cfg::debug;
    $requestURL = sprintf("https://prowlapp.com/publicapi/add?apikey=%s&application=twit2prowl&event=%s&description=%s&priority=%d",
                           $cfg::apikey,
                           $user,
                           $mention->{text},
                           $cfg::priority);
    $request = HTTP::Request->new(GET => $requestURL);
    $response = $userAgent->request($request);
    if ($response->is_success) {
      print "Notification successfully posted.\n" if $cfg::debug;
    } elsif ($response->code == 401) {
      print STDERR "Notification not posted: incorrect API key.\n";
    } else {
      print STDERR "Notification not posted: " . $response->content . "\n";
    }
    if ( $mention->{id} > $cache) { $cache = $mention->{id}; }
  }
}

$cache = $lasttweet unless $cache;
open(TIMESTAMP,">",$cfg::cachefile) or die "Can't open file which contains the ID of our last tweet: $!\n";
print TIMESTAMP $cache;
close(TIMESTAMP);
