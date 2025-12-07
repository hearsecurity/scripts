#!/usr/bin/perl 

use strict;
use warnings;
use Net::IP;
use LWP::Simple; 
use Parallel::ForkManager;
use LWP::UserAgent;

open my $handle, '<', 'list.txt';
chomp(my @urls = <$handle>);
close $handle;

our $counter; 

sub check_host {
    
    my $url = shift;  

    chomp($url);
    my $ua = LWP::UserAgent->new(agent => "Mozilla/4.0 (compatible; MSIE 6.0; MSIE 5.5; Windows NT 5.1) Opera 7.01 [en]", env_proxy => 1, keep_alive => 1,timeout => 10);
    my $res = $ua->get( $url );
    my $total = `grep -c . list.txt`;
    chomp($total);

    print "\e[0;32m[-] $url . \e[0;31m " . $res->code . " [\e[0;32m$counter \e[1;32mof \e[0;32m$total\e[0;32m]\e[0;31m\n";
    
    my $content = $res->content; 
    our $status;

    if (index($content, "Configuration") != -1) {
        $status = 1;
    } 

    if($res->code == 200 && $status == 1) {
        print("\e[1;33m[\e[0;31m+\e[1;33m]\e[0;32m[200]\e[0;31;33m -> $url \e[0m\n");
        open(OUT, ">> up.txt");
        print OUT ("$url\n");
        close OUT;
    }
}

my $fm = Parallel::ForkManager->new($ARGV[0]);

foreach my $pmas (@urls) {
    $counter += 1;
    my $pid = $fm->start;
    if ($pid == 0) {
        check_host($pmas);    
        $fm->finish;
    }
}