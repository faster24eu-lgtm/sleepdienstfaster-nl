# Measures duplicate text between city pages (5-word shingles, city name masked).
# Run from the site root after building: perl _build/check_similarity.pl
# Keep max-sim under ~40% and unique as high as possible.
use strict; use warnings; use utf8;
binmode STDOUT, ':utf8';
my @f = grep { !/sleepdienst\/index/ } glob 'sleepdienst/*/index.html';
my (%sh, %words);
for my $f (@f) {
  open my $h, '<:utf8', $f or die; local $/; my $t = <$h>;
  ($t) = $t =~ m{<main>(.*)</main>}s;
  $t =~ s/<script.*?<\/script>//gs; $t =~ s/<[^>]+>/ /g; $t =~ s/&[a-z]+;|&#\d+;/ /g;
  my @w = map { lc } $t =~ /(\w+)/g;
  my ($name) = $f =~ m{sleepdienst/([^/]+)/};
  my $nm = $name; $nm =~ s/-/ /g;
  # replace the city name so "Sleepdienst X" counts as the same text
  my $s = join ' ', @w;
  my @parts = split / /, $nm; my $re = join '\s+', map quotemeta, @parts;
  $s =~ s/\b$re\b/CITY/g;
  @w = split / /, $s;
  $words{$name} = scalar @w;
  my %s; $s{join ' ', @w[$_..$_+4]} = 1 for 0..$#w-4;
  $sh{$name} = \%s;
}
my @n = sort keys %sh;
my %cnt; for my $n (@n) { $cnt{$_}++ for keys %{$sh{$n}} }
for my $n (@n) {
  my $tot = keys %{$sh{$n}};
  my $uniq = grep { $cnt{$_} == 1 } keys %{$sh{$n}};
  my $max = 0; my $mx = '';
  for my $m (@n) { next if $m eq $n; my $i = grep { $sh{$m}{$_} } keys %{$sh{$n}}; my $u = $tot + (keys %{$sh{$m}}) - $i; my $j = $i/$u; ($max,$mx)=($j,$m) if $j>$max }
  printf "%-24s words %4d  unique %3.0f%%  max-sim %3.0f%% (%s)\n", $n, $words{$n}, 100*$uniq/$tot, 100*$max, $mx;
}
