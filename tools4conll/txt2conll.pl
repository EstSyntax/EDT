#!/usr/bin/perl -w
# teksti kujul sõltuvuspuu teisendamine CONLLL formaati MaltParseri tarvis
# teadaolevad bugid:  	kui tekstis on tõlgenduseta osalauseeraldajad { ja }, siis annab küll veahoiatuse, kuid saab hakkama
# 			kui tekstis on tühi token "<>", siis annab hoiatuse, aga ei paranda. (Tavaliselt <> on kadunud.) MaltParser seda väljundit ei talu
#			kui tekstis on "<s>", mis ei ole lause algus, siis hoiatust ei anna, aga MaltParser minestab.
# märgendite teisendamise skriptid on failis Word.pm
# ilma liputa teisendab midagi muutmata tulpadesse
# -n 1 teisendab maltparserile paremaks
# -n 2 teisendab muutmata tulpadesse, ainult mitmesed süntaktilised märgendid asendab kriipsudega

use Getopt::Std;
use lib '/home/kaili/Programmid/Konverter';
use Sentence;

my %option;
my $pr=0;
my $clb=0;
my $snx=0;

getopts("n:cs", \%option);

if ($option{n}) { $pr= $option{n}; }
else {$pr = 0;}

if ($option{c}) { print STDERR "CLB märgendid jäävad sisse\n"; $clb =1; }
if ($option{s}) { print STDERR "SNX märgendid jäävad sisse\n"; $snx =1; }


my $lineno=0;
my $fl=0;   #1 kui järgmine peab olema tõlgenduse rida
my $skip=0; #kui eelmine oli lause alguse või lõpu märgend, siis järgmine rida pole oluline.
my $str1; 
my $str2; 
my $str3;
my $rida;
my $sulg=0;

while(<>){
  $lineno++;
  #print "###";
  #print;
  if ($skip) {$skip=0; $fl=0; next;}
  chomp();
  $rida=$_;
  #print $rida;
  if ($rida =~ /"<[{|}]+>"/){ #{osalausepiirid
  #   next;
  $sulg=1;
  }   
  
  
  if ($rida =~ /^(.*?)(".*?")(.*)$/){ #kui on mitmesõnaline asi tühikutega sõnavormis
     $str1=$1;$str2=$2;$str3=$3;
     $str2 =~ s/ /_/g;
     $rida = $str1.$str2.$str3;
  }   
  #print $rida;
  
  if ($rida =~ /<s>/) {
     $s=Sentence->new(); 
     $skip=1;
     #print "Lause algas\n";
     next;
     }
  if ( $rida=~/<\/s>/){
     #print "Lause lõppes\n"; 
     #$s->printCONLL();
     $s->recalculateheads();
     #$s->printCONLL();
     $s->punctuationmarks();
     $s->printCONLL($pr,$clb);
     #print "printCONLL oli ära\n";
     $s->empty();
     $skip=1;
     next;
  }
  if ($rida=~/^\"<(\S+)>"/) {
     if ($fl) { 
       if (!$sulg) {print(STDERR "Tõlgendus puudub? ",$lineno,":",$_,  "\n"); }
       else {$sulg=0;}
       #print "####"; 
       $s->dellast();
       #next;
     }
     $s->addform($1); 
     $fl=1; 
     #print "Lisati vorm ", $1,"\n";
     next;
  }
  if ($rida =~ /^\"<(.*)>"/) {
      print(STDERR "Imelik ASI? ",$lineno,":",$_,  "\n"); #sõnavorm tuli eelnevast läbi
  }
  if ($rida=~/^\s*$/) {
    if ($fl) { print(STDERR "Tühi rida. Tõlgendus puudub? ",$lineno, "\n");} 
    next;
  }
  if ($rida=~/^\s+\"(\S+)\"(.*)$/){
    if ($fl==0) { 
      print(STDERR "Mitu tõlgendust? ",$lineno,"\n");
    }
    else {
     # print "Lisati lemma ",$1,"\n";
      $s->addlemma($1);
     # print "Lisati märgendid ",$2,"\n";
      $s->addmorphsyn($2,$pr,$clb,$snx);
      $fl=0;
    }  
  }  
 

     
}

#$s->printCONLL();
#     $s->empty();
#print "\n"; 