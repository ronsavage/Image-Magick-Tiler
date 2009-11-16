use File::Basename;
use Test::More tests => 7;

# ------------------------

BEGIN{ use_ok('Image::Magick::Tiler'); }

my($result) = Image::Magick::Tiler -> new
(
	input_file	=> './t/input/logo.png',
	geometry	=> '2x2+6',
	output_dir	=> './t/output', # Dir does not exist.
	output_type	=> 'png',
	return		=> 1,
	verbose		=> 1,
	write		=> 0,
);

isnt($result, undef, 'new() returned something');
isa_ok($result, 'Image::Magick::Tiler', 'new() returned an object of type Image::Magick::Tiler');

my($ara) = $result -> tile();

isnt($ara, undef, 'tile() returned something');
is($#$ara, 3, 'tile() returned an array ref of 4 elements');
isa_ok($$ara[0]{'image'}, 'Image::Magick', 'tile() returned an Image::Magick image');

# Under Windows, $path will be t\output\.

my($name, $path, $suffix) = fileparse($$ara[0]{'file_name'});

is($name, '1-1.png', 'tile() returned a file name');
