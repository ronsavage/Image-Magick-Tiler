#!/usr/bin/env perl

use strict;
use warnings;

use File::Basename;
use File::Temp;

use Image::Magick::Tiler;

# ------------------------

# The EXLOCK option is for BSD-based systems.

my($temp_dir)	= File::Temp -> newdir('temp.XXXX', CLEANUP => 1, EXLOCK => 0, TMPDIR => 1);
$temp_dir		= '/tmp';
my($result)		= Image::Magick::Tiler -> new
(
	input_file	=> './t/input/logo.png',
	geometry	=> '2x2+6',
	output_dir	=> $temp_dir,
	output_type	=> 'png',
	return		=> 1,
	verbose		=> 1,
	write		=> 0,
);

my($tiles) = $result -> tile();

for my $i (0 .. $#$tiles)
{
	print "Tile: @{[$i + 1]}. File name; $$tiles[$i]{file_name}. \n";
}
