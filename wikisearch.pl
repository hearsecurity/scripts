#!/usr/bin/perl

use strict; 
use warnings; 
use LWP::Simple;
use HTML::TreeBuilder::XPath;

print "Type your search: "; 
my $search = <STDIN>; 
chomp($search); 

print "\n[*] Searching for ".$search."\n\n"; 

my $query = "https://wikipedia.org/w/index.php?title=".$search."&action=render";
my $content = get($query); 

my $tree = HTML::TreeBuilder::XPath->new;
$tree->parse_content($content);
my $description = $tree->findvalue('/html/body/div/p[2]');

if(defined $description) {
    print $description . "\n"; 
}else{
    print "[-] Search not found.\n"; 
}



