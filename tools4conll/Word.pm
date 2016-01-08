#Word.pm
package Word;
use strict;
my $l="";

sub new {
  my $class = shift;
  if (@_) {$l=shift;}
  my $self = {
       NO => undef,  #sõne järjekord lauses, algab 0st
       FORM => $l,
       LEMMA => undef,
       ENDING => "",
       CPOS => "X",
       POS => "X",
       FEATS => undef,
       OLDNO => undef, #sõne järjekord sõltuvusinfo põhjal
       HEAD => undef,
       DEPREL => "xxx",
       PHEAD => "_",
       PDEPREL => "_",
       OTHER => undef,
    };
        bless($self,$class);
  return $self;
}

sub DESTROY {
  my $self= {};
}

sub number {
  my $self = shift;
  return $self->{NO};
}

sub oldnumber {
  my $self = shift;
  if ($self->{OLDNO}) {return $self->{OLDNO};}
  else {print STDERR $self->{FORM}, " ei ole sõltuvust\n";}
}


sub form{
  my $self= shift;
  return $self-> {FORM};
}  

sub lemma{
  my $self= shift;
  return $self->{LEMMA}; 
}  

sub cpos{
  my $self= shift;
  return $self->{CPOS}; 
} 

sub pos{
  my $self= shift;
  my $f = shift;
  if ($f==1){
    return $self->conllpos();
  }
  return $self->{POS}; 
} 

sub deprel{
  my $self= shift;
  my $f =shift;
  if ($f>0){
    return $self->conlldeprel();
  }
  return $self->{DEPREL}; 
} 

sub head{
  my $self= shift;
  return $self->{HEAD}; 
} 

sub feats{
  my $self= shift;
  my $f =shift;
  my $c =shift;
  
  if ($f) {
  if ($f==1){
    return $self->conllfeatures($c);
  }
  }
  return $self->{FEATS}; 
} 


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub addno {
  my $self= shift;
  my $no= shift;
  $self->{NO}=$no;
}

sub addlemma {
  my $self = shift;
  my $l =shift;
  $self->{LEMMA}="" . $l;
}  

sub addmorphsyn {
  my $self = shift;
  my $l =shift;
  my $opt=shift;
  my $c=shift;
  my $s=shift;
  
  my $feats="";
  if ($l =~ /(L\S+)\s*/) {
     $self->{ENDING}= $1;
  }   
  if (($l =~ /L\S+ (\S) (.*)$/) || ($l =~ /^\s*(\S) (.*)$/)) {
     $self->{CPOS} = $1;
     $self->{POS} = $1;
     $feats=$2;
  } 
  if ($opt==2){ #kirjuta mitmese asemele _
    if ($l =~ /@.*@.*/){  #mitmese analüüsi asemele _
       $self->{DEPREL}="_";
    } else {
    if ($l =~ /(@\S+)\s*/){
       $self->{DEPREL}=$1;
    } }
  }
  else {
    if ($l =~ /(@\S+)\s*/){
       $self->{DEPREL}=$1;
    } 
  }
  if ($l =~ /\#(\d+)->(\d+)\s*/){
    $self->{OLDNO}= $1;
    $self->{HEAD}= $2;
  }elsif ($l =~ /\#(\d+)->(\?+)\s*/){
    $self->{OLDNO}= $1;
    $self->{HEAD}= 0;
  }
  else {
    $self->{HEAD}=$self->{NO}+1;
  }
  
  $self->{OTHER}= "".$l;
  if ($s==0){
    $feats =~ s/@.*$//;   #kui tahta sünt funktsiooni tunnuste hulgas, siis see rida välja kommenteerida
  }
  $feats =~ s/#.*$//;
  $feats =~ s/\s+/\|/g;
  $feats =~ s/\|$//;
  if ($feats =~ /^$/) {$feats="_";}
  $self->{FEATS}=trim($feats);
}  

sub morphsyn{
  my $self = shift;
  return $self->{OTHER};
  
}

sub chhead{
  my $self= shift;
  my $no = shift;
  $self->{HEAD}=$no;
}


####################################################################################################
#  Sõnaliikide teisendamine
####################################################################################################

sub conllpos{
my $self = shift;
   if ($self->{POS} =~ /A/) {return "A";}
   if ($self->{POS} =~ /B/) {return "B";}
   if ($self->{POS} =~ /D/) {return "D";}
   if ($self->{POS} =~ /G/) {return "A";}
   if ($self->{POS} =~ /S/ && $self->{FEATS}=~ /prop/) {return "H";}   
   if ($self->{POS} =~ /I/) {return "I";}
   if ($self->{POS} =~ /J/) {
     if ($self->{FEATS} =~ /crd/) {return "Jc";}
     if ($self->{FEATS} =~ /sub/) {return "Js";}
     return "J";
   }
   if ($self->{POS} =~ /K/) {
     if ($self->{FEATS} =~ /pre/) {return "Ke";}
     if ($self->{FEATS} =~ /post/) {return "Kt";}
     return "K";
   }  
   if ($self->{POS} =~ /N/) {
     if ($self->{FEATS} =~ /card/) {return "N";}
     if ($self->{FEATS} =~ /ord/) {return "A";}
     return "N";
   }
   if ($self->{POS} =~ /P/) {
     if ($self->{FEATS} =~ /pers/) {return "Ppers";}
     return "P";
   }
   if ($self->{POS} =~ /S/ && $self->{FEATS} !~ /prop/) {return "S";}
   if ($self->{POS} =~ /V/) {
     if ($self->{FEATS} =~ /aux/) {return "Vaux";}
     if ($self->{FEATS} =~ /mod/) {return "Vmod";}
     if ($self->{FEATS} =~ /inf/) {return "Vinf";}
     if ($self->{FEATS} =~ /sup/) {return "Vsup";}
     return "V";
   }  
   if ($self->{POS} =~ /X/) {return "X";}
   if ($self->{POS} =~ /Y/) {return "Y";}
   if ($self->{POS} =~ /Z/) {return "Z";}
   return "M";
}

###################################################################################################
# Sünt funktsioonide teisendamine
###################################################################################################
sub conlldeprel{
my $self=shift;
   if ($self->{HEAD} == 0) {
      return "ROOT";
      #return "_";
   }
   if ($self->{POS} =~ /Z/) {return "\@Punc";}
#siit nüüd lisakriipsud   
   #if ($self->{DEPREL} =~ /\@J/) {return "_";}
   #if ($self->{DEPREL} =~ /\@<KN/) {return "_";}
   #if ($self->{DEPREL} =~ /\@<INFN/) {return "_";}
   #if ($self->{DEPREL} =~ /\@<NN/) {return "_";}
     
   
   return $self->{DEPREL};
   
#    if ($self->{DEPREL} =~ /\@NN>/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@<NN/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@AN>/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@<AN/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@DN>/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@<DN/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@VN>/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@<VN/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@KN>/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@<KN/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@<INFN/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@INFN>/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@SUBJ/) {return "subj";}
#    if ($self->{DEPREL} =~ /\@OBJ/) {return "obj";}
#    if ($self->{DEPREL} =~ /\@PRD/) {return "prd";}
#    if ($self->{DEPREL} =~ /\@ADVL/) {return "advl";}
#    if ($self->{DEPREL} =~ /\@P>/) {return "adp";}
#    if ($self->{DEPREL} =~ /\@<P/) {return "adp";}
#    if ($self->{DEPREL} =~ /\@Q>/) {return "qtr";}
#    if ($self->{DEPREL} =~ /\@<Q/) {return "qtr";}
#    if ($self->{DEPREL} =~ /\@J/) {return "conj";}
#    if ($self->{DEPREL} =~ /\@Vpart/) {return "vg";}
#    if ($self->{DEPREL} =~ /\@VpartN/) {return "attr";}
#    if ($self->{DEPREL} =~ /\@FMV/) {return "vg";}
#    if ($self->{DEPREL} =~ /\@FCV/) {return "vg";}
#    if ($self->{DEPREL} =~ /\@IMV/) {return "vg";}
#    if ($self->{DEPREL} =~ /\@ICV/) {return "vg";}
#    if ($self->{DEPREL} =~ /\@NEG/) {return "vg";}
#    if ($self->{DEPREL} =~ /\@I/) {return "i";}
#    if ($self->{DEPREL} =~ /\@B/) {return "b";}
#    if ($self->{POS} =~ /Z/) {return "punc";}
#    return "unk";
}

#######################################################################################################
# Muude tunnuste teisendamine
#######################################################################################################
sub conllfeatures{
my $self=shift;
my $c=shift;

my $fs = $self->{FEATS};

  $fs=~ s/<[^>]*>//g; #kustuta valentsiinfo  nt <Intr>
  $fs=~ s/"[^"]*"//g; #kustuta valentsiinfo  adj particute juures vastava verbi tüvi "tüvi"
  $fs=~ s/cap//g;     #cap
  
  if ($c==0) {
    $fs =~ s/CLBC//g;
    $fs =~ s/CLB//g;
    $fs=~ s/CLO//g;     #CLO
    $fs=~ s/CLC//g;     #CLC
  } else {
    $fs =~ s/CLBC/clb/g;
    $fs =~ s/CLB/clb/g;
    $fs=~ s/CLO/clb/g;     #CLO
    $fs=~ s/CLC/clb/g;     #CLC
    $fs=~ s/clb.clb/clb/g; #ühekordselt
  
  }
  
  #nimisõnad
  $fs =~ s/^com\|*//;
  $fs =~ s/^prop\|*//;
  
  #arvsõnad
#   $fs =~ s/^card\|*//;
#   $fs =~ s/^ord\|*//;
  
  #omadussõnad
  if ($self->{POS} =~ /A/){
    $fs =~ s/^pos\|*//;
    $fs =~ s/partic.partic/partic/g;
    #$fs =~ s/^com\|//;
  }  
  
  #sidesõnad
  $fs =~ s/^crd\|*//;    #juba sõnaliigis
  $fs =~ s/^sub\|*//; 	#juba sõnaliigis
  
  #verbid
  $fs =~ s/\|af\|*/|/;   #afirmatiiv
  $fs =~ s/\|ps\|/|/;    #personaal
  $fs =~ s/\|ps$//;    #personaal
  $fs =~ s/aux\|//;    #juba sõnaliigis
  $fs =~ s/mod\|//;    #juba sõnaliigis
  $fs =~ s/main\|//;    #juba sõnaliigis
  $fs =~ s/partic\|past/ppast/;    #üheks
  
  #asesõnad
  if ($self->{POS} =~ /P/){
     $fs =~ s/pers\|*//;    #personaal on juba sõnaliigis
  }
  $fs =~ s/inter\|rel\|*/intrel|/g;
  
  #kaassõnad
  if ($self->{POS} =~ /K/){
     $fs =~ s/post\|*//;    #post on juba sõnaliigis
     $fs =~ s/pre\|*//;    #pre on juba sõnaliigis
  }
  
  $fs =~ s/\|+/|/g;
  $fs =~ s/\|$//;
  
  if ($fs =~ /^\s*$/) {return "_";} #kui midagi ei jäänud alles, asenda _
  
  return $fs;
}

1;