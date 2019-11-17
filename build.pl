#!/usr/bin/env perl

exit if system("nasm -f elf64 sc.asm -o sc.o");

my $output = `readelf -x .text sc.o` || die "Dump failed";

my $sc;
while($output =~ /0x[[:xdigit:]]+ (([[:xdigit:]]+ ){1,4})/g){
    $sc .= $1;
    $sc =~ s/ //g;
}

$sc =~ s/../\\x$&/g;

my @code;
push(@code, "sc+=\"$_\"\n") for(unpack "(A52)*", $sc);

open(my $fh, '<', "base.sh") || die "$!";
my @lines = <$fh>;
close $fh;

my ($begin) = grep { $lines[$_] eq "#BEGIN\n" } (0 .. $#lines);
my ($end)   = grep { $lines[$_] eq "#END\n" }   (0 .. $#lines);

die "unknown file format" if(!defined($begin) || !defined($end));

splice @lines, $begin + 1, $end - $begin - 1, @code;

open($fh, '>', "exec.sh") || die "$!";
print $fh @lines;
close $fh;
