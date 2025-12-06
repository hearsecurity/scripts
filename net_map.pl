#!/usr/bin/perl 

use strict;
use warnings;
use Net::IP;
use IO::Socket::INET;
use Parallel::ForkManager;

print "\033[2J";
print "\033[0;0H";
print " \

███    ██ ███████ ████████ ███    ███  █████  ██████  
████   ██ ██         ██    ████  ████ ██   ██ ██   ██ 
██ ██  ██ █████      ██    ██ ████ ██ ███████ ██████  
██  ██ ██ ██         ██    ██  ██  ██ ██   ██ ██      
██   ████ ███████    ██    ██      ██ ██   ██ ██      
                                                      
                                                      

";
print "\n[*] Type the initial IP range: "; 
my $init = <STDIN>; 
print "[*] Type the final IP range: "; 
my $final = <STDIN>;
print "[*] Type ports separated by comma: "; 
my $port_list = <STDIN>; 
my @ports = split(',',$port_list);
print "[*] Type number of threads: "; 
my $threads = <STDIN>; 
print "\n"; 

my $ip_range = "$init - $final"; 
my $ip = Net::IP->new($ip_range) or die Net::IP::Error();

my @ips; 

sub check_port {
    
    my $ip = shift; 
    chomp($ip);  

    foreach(@ports) {
        
        my $port = $_; 
        chomp($port); 
        my $socket = IO::Socket::INET->new(
        PeerAddr => $ip,
        PeerPort => $port,
        Proto    => "tcp",
        Timeout  => 3          # Set a timeout in seconds
        );  
    
    if($socket) {

        print "[+] IP: ".$ip." PORT: ".$port." Open.\n"; 
    }
    }
}

do {
    push @ips, $ip->ip();
} while (++$ip);

my $fm = Parallel::ForkManager->new($threads);

foreach my $ip (@ips) {
    
    my $pid = $fm->start;
    if ($pid == 0) {
        check_port($ip);   
        $fm->finish;
    }
} 
   
