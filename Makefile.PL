use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (ron@savage.net.au)',
		'ABSTRACT' => 'Slice an image into N x M tiles',
    ) : (),
	clean			=>
	{
		FILES		=> 'blib/* Makefile MANIFEST Image-Magick-Tiler-*'
	},
	dist			=>
	{
		COMPRESS	=> 'gzip',
		SUFFIX		=> 'gz'
	},
	DISTNAME		=> 'Image-Magick-Tiler',
	NAME			=> 'Image::Magick::Tiler',
	PL_FILES		=> {},
	PREREQ_PM		=>
	{
		Image::Magick	=> 6.00,
		Test::More		=> 0,
		Test::Pod		=> 0,
	},
	VERSION_FROM	=> 'lib/Image/Magick/Tiler.pm',
);
