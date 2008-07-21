use Module::Build;

Module::Build -> new
(
	module_name		=> 'Image::Magick::Tiler',
	license			=> 'artistic',
	dist_author		=> 'Ron Savage <ron@savage.net.au>',
	build_requires	=>
	{
		Test::More	=> 0,
		Test::Pod	=> 0,
	},
	requires		=>
	{
		Image::Magick	=> 6.00,
	},
) -> create_build_script();