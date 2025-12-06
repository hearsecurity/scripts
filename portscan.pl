#!/usr/bin/perl 

use strict; 
use warnings; 
use IO::Socket::INET;

print "Type your target: "; 
my $host = <STDIN>; 
chomp($host);  
print "\n"; 

my @ports = (21,22,23,25,53,80,443); 

foreach(@ports) {
   
   my $socket = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => $_,
    Proto    => "tcp",
    Timeout  => 3          # Set a timeout in seconds
  );
  
  print "[*] Checking port: ".$_."\n"; 

  if($socket) {
    print "[+] Port ".$_." is open.\n";
  }else{
    print "[-] Port ".$_." is closed\n";
  }
}
