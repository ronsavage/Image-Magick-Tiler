use Module::Build;

Module::Build -> new
(
 module_name    => 'Image::Magick::Tiler',
 license        => 'artistic',
 dist_abstract  => 'Slice an image into N x M tiles',
 dist_author    => 'Ron Savage <ron@savage.net.au>',
 build_requires =>
 {
	 Test::More => 0,
	 Test::Pod  => 0,
 },
 configure_requires =>
 {
	 Module::Build => 0.3800,
 },
 requires =>
 {
	 Image::Magick => 6.00,
 },
) -> create_build_script();
