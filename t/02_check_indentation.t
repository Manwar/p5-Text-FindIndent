#!/usr/bin/perl
use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;
use File::Spec;
use Text::FindIndent;

chdir('t') if -d 't';

my %tests;
opendir DH, 'data' or die $!;
while (my $file = readdir(DH)) {
  my $path = File::Spec->catfile("data", $file);
  next unless -f $path;
  next unless $file =~ /^(mixed|tabs|spaces|unknown)(\d*)(?:_\d*)\.txt/i;
  my $type = $1;
  my $n = $2;
  if ($type =~ /mixed/i) {
    $n ||= 1;
    push @{$tests{"m$n"}}, $path;
  }
  elsif ($type =~ /space/i) {
    $n ||= 1;
    push @{$tests{"s$n"}}, $path;
  }
  elsif ($type =~ /tab/i) {
    $n ||= 1;
    push @{$tests{"t$n"}}, $path;
  }
  else {
    push @{$tests{"u"}}, $path;
  }
}
closedir(DH);

my $no_tests = 0;
foreach (map {scalar @$_} values %tests) {
  $no_tests += $_ * 3;
}
plan tests => $no_tests;



foreach my $exp_result (keys %tests) {
  my $testfiles = $tests{$exp_result};
  foreach my $file (@$testfiles) {
    my $text = slurp($file);
    ok(defined $text, "slurped file '$file'");
    my $result = Text::FindIndent->parse($text);
    ok(defined $result, "Text::FindIndent->parse($file) returns something");
    is($result, $exp_result, "Text::FindIndent->parse($file) returns correct result");

  }
}

sub slurp {
  my $file = shift;
  open FH, "<$file" or die $!;
  local $/ = undef;
  my $text = <FH>;
  close FH;
  return $text;
}

