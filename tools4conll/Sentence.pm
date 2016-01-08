# Sentence.pm
package Sentence;
use strict;

use Word;

#konstruktor

my $RecNo=0;

sub new {
  my $class = shift;
  my $self = {
       NO => undef,
       WORDS => [],
    };
    bless($self,$class);
  return $self;
}

sub DESTROY {
  $RecNo=0;
  my $self= {};
}


sub empty {
  $RecNo=0;
  my $self=shift;
  #print @{$self->{WORDS}};
  #foreach $i (@{$self->{WORDS}}) {
  #
  #}
  $self=>{};
}

sub addform {
  my ($self,$line)= @_;
  my $word= Word->new(trim($line));
  push @{$self->{WORDS}}, $word; 
  $word->addno($RecNo++);
}

sub addlemma {
  my $self= shift;
  my $line= shift;
  #print ">>>",$line,"\n";
  my $word = pop @{$self->{WORDS}};
  $word->addlemma(trim($line));
  push @{$self->{WORDS}}, $word;
}

sub addmorphsyn {
  my $self= shift;
  my $line= shift;
  my $opt =shift;
  my $c=shift;
  my $s=shift;
  #print "$line";
  my $word = pop @{$self->{WORDS}};
  $word->addmorphsyn(trim($line),$opt,$c,$s);
  push @{$self->{WORDS}}, $word;
}

sub recalculateheads{
  my $self = shift;
  my $item;
  my $i;
  
  foreach $item (@{$self->{WORDS}}){
    #kui teisendamise käigus on tõlgenduseta token välja visatud
    #siis tuleb headide numbreid muuta
    #siin saaks optimeerida
      foreach $i (@{$self->{WORDS}}){
        if ($i->oldnumber()==$item->head()){
          $item->chhead($i->number()+1);
          next;
        }
      }  
  }
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


sub punctuationmarks_old{ #lisab lingid lause ruudule, mitte iseendale
  my $self = shift;
  my $item;
  my $head=1;
  foreach $item (@{$self->{WORDS}}){
     if ($item->head()==0){
      $head= $item->number()+1;
      last;
     }
  }
  foreach $item (@{$self->{WORDS}}){
     if ($item->head()==$item->number()+1){
       $item->chhead($head);
     }
  }   
}
sub punctuationmarks{ #link eelnevale tokenile, v.a opr ja oquo

  my $self = shift;
  my $item;
  
  foreach $item (@{$self->{WORDS}}){
       if ($item->head()==$item->number()+1){ #kui link on iseendale
         $item->chhead($item->number());      #link eelnevale
       }
       if ($item->feats(1,0) =~ /Opr/) {
         $item->chhead($item->number()+2);    #link järgnevale
         next;
       }
       if ($item->feats(1,0) =~ /Oqu/) {
         $item->chhead($item->number()+2);    #link järgnevale
         next;
       }
       if ($item->feats(1,0) =~ /Quo/ && $item->head()==0) {
          $item->chhead($item->number()+2);    #link järgnevale
       }   
       
   }
}   

sub printCONLL{
  my $self=shift;
  
  my $p=shift;
  my $c=shift;
  
  my $item;
  my $i=0;
 
 foreach $item (@{$self->{WORDS}}){
   #print $i++, "\t";
   print $item->number()+1, "\t";
   print $item->form(),"\t";
   print $item->lemma(),"\t";
   print $item->cpos(),"\t";
   print $item->pos($p),"\t";
   print $item->feats($p,$c),"\t";
   print $item->head(),"\t";
   print $item->deprel($p),"\t_\t_\n";
   #print $item->morphsyn(),"\n";
 }
 print "\n";
} 

sub dellast{
  my $self = shift;
  my $word = pop @{$self->{WORDS}};
  $RecNo--;
}

1;