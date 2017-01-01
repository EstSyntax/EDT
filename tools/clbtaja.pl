#!/usr/bin/perl -w
# lisab clb märgendid inforem-formaadile kasutades vislcg3 parserit ja reeglite faili clbinforemile.rul


my $path="/home/kaili/Programmid/inforem2clb";
my @files = ();

opendir(DIR,$path) or die "Can't open $path: $!";
@files = grep {/\.inforem$/ } readdir(DIR);
closedir(DIR);

foreach $file (@files) {
  my $newname = $file . ".clb";
  #my $newcommand = "vislcg3 -g clbinforemile.rul < " .$file." >". $newfile;
  $status = system("vislcg3 -g clbinforemile.rul < $file > $newname")  ;
  die "jama majas: $?" unless $status == 0;
}




