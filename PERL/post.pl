#!/usr/bin/perl

read(STDIN, $FormData, $ENV{'CONTENT_LENGTH'});
my @pairs = split(/&/, $FormData);
foreach $pair (@pairs)
{
  my ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
}

return 1