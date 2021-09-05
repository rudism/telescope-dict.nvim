#!/usr/bin/env perl

# script that parses the following dictd output:
# arg1=synonyms: moby-thesaurus
#   - one word per line
# arg1=definitions: wn
#   - one definition per line separated by blank lines

use warnings;
use strict;

my ($cmd, $word) = (shift, shift);
my $qword = quotemeta($word);

if ($cmd eq 'synonyms') {
  open(my $fh, '-|', "dict -d moby-thesaurus $qword 2>/dev/null");
  my $first = 1;
  while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /^     /) {
      $line =~ s/^\s+//;
      $line =~ s/[\s,]*$//;
      my @words = split(/\s*,\s*/, $line);
      foreach my $word (@words) {
        if ($first) {
          $first = 0;
        } else {
          print "\n";
        }
        print $word;
      }
    }
  }
  close($fh);
}

elsif ($cmd eq 'definitions') {
  open(my $fh, '-|', "dict -d wn $qword 2>/dev/null");
  my $defsraw = '';
  while (my $line = <$fh>) {
    if ($line =~ /^ {6}/) {
      $defsraw .= $line;
    }
  }
  close($fh);
  my @defs = split(/\n      (?=[a-z]* ?\d+: )/, $defsraw);
  my $curtype;
  my $defmap = {};
  my ($biggest, $count) = (0, 0);
  my @deftypes = ();
  foreach my $def (@defs) {
    my $line = $def;
    if ($line) {
      $line =~ s/(^\s+|\s+$)//g;
      $line =~ s/\s*\n\s*/ /g;
      if ($line =~ /^(([^0-9]+) )?(\d+): (.*?)( \[.*)?$/) {
        my ($type, $num, $desc, $meta) = ($2, $3, $4, $5);
        if ($type) {
          $curtype = $type;
          $defmap->{$curtype} = [];
          push @deftypes, $type;
          $count = 0;
        }
        next if !$curtype;
        push @{$defmap->{$curtype}}, {
          desc => $desc,
          meta => $meta};
        $count++;
        if ($count > $biggest) {
          $biggest = $count;
        }
      }
    }
  }
  my $first = 1;
  for (my $i = 0; $i < $biggest; $i++) {
    foreach my $key (@deftypes) {
      if($defmap->{$key}->[$i]) {
        my $desc = $defmap->{$key}->[$i]->{desc};
        if ($first) {
          $first = 0;
        } else {
          print "\n\n";
        }
        print "$key: $desc";
      }
    }
  }
}
