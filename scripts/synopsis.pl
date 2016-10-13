#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;

use Image::Magick::Tiler;

# ------------------------

my($temp_dir)	= '/tmp';
my($tiler)		= Image::Magick::Tiler -> new
(
	input_file	=> File::Spec -> catdir('t', 'sample.png'),
	geometry	=> '2x2+6+0',
	output_dir	=> $temp_dir,
	output_type	=> 'png',
	return		=> 1,
	verbose		=> 1,
	write		=> 1,
);

my($tiles) = $tiler -> tile;
my($count) = $tiler -> count; # Warning: Must go after calling tile().

print "Tiles written: $count. \n";

for my $i (0 .. $#$tiles)
{
	print "Tile: @{[$i + 1]}. File name:   $$tiles[$i]{file_name}. \n";
}
