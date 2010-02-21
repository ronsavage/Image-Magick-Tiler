package Image::Magick::Tiler;

# Name:
#	Image::Magick::Slice.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Reference:
#	Object Oriented Perl
#	Damian Conway
#	Manning
#	1-884777-79-1
#	P 114
#
# Note:
#	o Tab = 4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	Home page: http://savage.net.au/index.html
#
# Licence:
#	Australian copyright (c) 1999-2002 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use warnings;

use Carp;
use File::Spec;
use Image::Magick;

require 5.005_62;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Image::Magick::Tiler ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = '1.03';

# -----------------------------------------------

# Preloaded methods go here.

# -----------------------------------------------

# Encapsulated class data.

{
	my(%_attr_data) =
	(
		_input_file		=> '',
		_geometry		=> '2x2+0+0',
		_output_dir		=> '',
		_output_type	=> 'png',
		_return			=> 1,
		_verbose		=> 0,
		_write			=> 0,
	);

	sub _default_for
	{
		my($self, $attr_name) = @_;

		$_attr_data{$attr_name};
	}

	sub _standard_keys
	{
		keys %_attr_data;
	}

}	# End of encapsulated class data.

# -----------------------------------------------

sub new
{
	my($caller, %arg)		= @_;
	my($caller_is_obj)		= ref($caller);
	my($class)				= $caller_is_obj || $caller;
	my($self)				= bless({}, $class);

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($arg{$arg_name}) )
		{
			$$self{$attr_name} = $arg{$arg_name};
		}
		elsif ($caller_is_obj)
		{
			$$self{$attr_name} = $$caller{$attr_name};
		}
		else
		{
			$$self{$attr_name} = $self -> _default_for($attr_name);
		}
	}

	Carp::croak("Error. You must call new as new(input_file => 'some file'). ") if (! $$self{'_input_file'});

	my($g) = $$self{'_geometry'};

	if ($g =~ /^(\d*)(x?)(\d*)([+-]?\d*)([+-]?\d*)$/i)
	{
		$$self{'_geometry'}		= [$1, $2, $3, $4, $5];
		$$self{'_geometry'}[0]	= 2		if ($$self{'_geometry'}[0] eq '');
		$$self{'_geometry'}[1]	= 'x'	if ($$self{'_geometry'}[1] eq '');
		$$self{'_geometry'}[2]	= 2		if ($$self{'_geometry'}[2] eq '');
		$$self{'_geometry'}[3]	= '+0'	if ($$self{'_geometry'}[3] =~ /^(|\+|-)$/);
		$$self{'_geometry'}[4]	= '+0'	if ($$self{'_geometry'}[4] =~ /^(|\+|-)$/);

		Carp::croak("Error. Input (NxM+x+y = $g) specifies N = 0") if ($$self{'_geometry'}[0] =~ /^0+$/);
		Carp::croak("Error. Input (NxM+x+y = $g) specifies M = 0") if ($$self{'_geometry'}[2] =~ /^0+$/);

		if ($$self{'_verbose'})
		{
			print "Image::Magick:        V $Image::Magick::VERSION. \n";
			print "Image::Magick::Tiler: V $Image::Magick::Tiler::VERSION. \n";
			print "Geometry:             $g parsed as NxM+x+y = " . join('', @{$$self{'_geometry'} }) . ". \n";
		}
	}
	else
	{
		Carp::croak("Error. Input (NxM+x+y = $g) is not in the correct format. ");
	}

	return $self;

}	# End of new.

# -----------------------------------------------

sub tile
{
	my($self)	= @_;
	my($image)	= Image::Magick -> new();
	my($result)	= $image -> Read($$self{'_input_file'});

	Carp::croak("Error. Unable to read file $$self{'_input_file'}. Image::Magick error: $result. ") if ($result);

	my($param)			= {};
	$$param{'image'}	= {};
	($$param{'image'}{'width'}, $$param{'image'}{'height'}) = $image -> Get('width', 'height');

	$$param{'tile'}				= {};
	$$param{'tile'}{'width'}	= int($$param{'image'}{'width'} / $$self{'_geometry'}[0]);
	$$param{'tile'}{'height'}	= int($$param{'image'}{'height'} / $$self{'_geometry'}[2]);

	if ($$self{'_verbose'})
	{
		print "Image:                $$self{'_input_file'}. \n";
		print "Image size:           ($$param{'image'}{'width'}, $$param{'image'}{'height'}). \n";
		print "Tile size:            ($$param{'tile'}{'width'}, $$param{'tile'}{'height'}) (before applying x and y). \n";
	}

	Carp::croak("Error. Tile width ($$param{'tile'}{'width'}) < input x ($$self{'_geometry'}[3]). ")	if ($$param{'tile'}{'width'} < abs($$self{'_geometry'}[3]) );
	Carp::croak("Error. Tile height ($$param{'tile'}{'height'}) < input y ($$self{'_geometry'}[4]). ")	if ($$param{'tile'}{'height'} < abs($$self{'_geometry'}[4]) );

	$$param{'tile'}{'width'}	+= $$self{'_geometry'}[3];
	$$param{'tile'}{'height'}	+= $$self{'_geometry'}[4];

	if ($$self{'_verbose'})
	{
		print "Tile size:            ($$param{'tile'}{'width'}, $$param{'tile'}{'height'}) (after applying x and y). \n";
	}

	my($output)	= [];
	my($x)		= 0;

	my($y, $tile, $output_file_name);

	for my $xg (1 .. $$self{'_geometry'}[0])
	{
		$y = 0;

		for my $yg (1 .. $$self{'_geometry'}[2])
		{
			$output_file_name	= "$yg-$xg.$$self{'_output_type'}";
			$output_file_name	= File::Spec -> catfile($$self{'_output_dir'}, $output_file_name) if ($$self{'_output_dir'});
			$tile				= $image -> Clone();

			Carp::croak("Error. Unable to clone image $output_file_name") if (! ref $tile);

			$result = $tile -> Crop(x => $x, y => $y, width => $$param{'tile'}{'width'}, height => $$param{'tile'}{'height'});

			Carp::croak("Error. Unable to crop image $output_file_name. Image::Magick error: $result. ") if ($result);

			if ($$self{'_return'})
			{
				push @{$output},
				{
					file_name	=> $output_file_name,
					image		=> $tile,
				};
			}

			if ($$self{'_write'})
			{
				$tile -> Write($output_file_name);

				print "Wrote:                $output_file_name. \n" if ($$self{'_verbose'});
			}

			$y += $$param{'tile'}{'height'};
		}

		$x += $$param{'tile'}{'width'};
	}

	$output;

}	# End of tile.

# -----------------------------------------------

1;

__END__

=head1 NAME

C<Image::Magick::Tiler> - Slice an image into N x M tiles.

=head1 Synopsis

	#!/usr/bin/perl

	use Image::Magick::Tile;

	Image::Magick::Tile -> new
	(
		input_file  => 'image.png',
		geometry    => '3x4+5-6',
		output_dir  => '',
		output_type => 'png',

	) -> tile();

This slices image.png into 3 tiles horizontally and 4 tiles vertically.

Further, the width of each tile is ( (width of image.png) / 3) + 5 pixels,
and the height of each tile is ( (height of image.png) / 4) - 6 pixels.

In the geometry option NxM+x+y, the x and y offsets can be used to change the size of the tiles.

For example, if you specify 2x3, and the vertical line which splits the image goes through an
interesting part of the image, you could then try 2x3+50, say, to move the vertical line 50 pixels
to the right. This is what I do when printing database schema generated with GraphViz::DBI.

=head1 Description

C<Image::Magick::Tiler> is a pure Perl module.

=head1 Distributions

This module is available both as a Unix-style distro (*.tgz) and an
ActiveState-style distro (*.ppd). The latter is shipped in a *.zip file.

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing each type of distro.

=head1 Constructor and initialization

new(...) returns a C<Image::Magick::Tiler> object.

This is the class's contructor.

Parameters:

=over 4

=item input_file

This parameter is mandatory.

=item geometry

This parameter is optional.

It's format is 'NxM+x+y'.

The default is '2x2+0+0'.

N is the default number of tiles in the horizontal direction.

M is the default number of tiles in the verical direction.

The N and/or M component can be omitted. 2 is assumed for any missing N or M. The 'x' is optional
if M is missing. A single value, such as '5', is assumed to be an N value, and M is set to 2.

The '+x+y' component can be omitted. 0 is assumed for any missing x and y adjustments to the width
and height of the tiles. A single value, such as '+5', is assumed to be an x value, and y is set to 0.

Negative or positive values can be used for x and y. Negative values will probably cause extra tiles to be
required to cover the image. That why I used the phrase 'default number of tiles' above.

An example would be '2x3-10-12'.

=item output_dir

This parameter is optional.

The default is ''.

=item output_type

This parameter is optional.

The default is 'png'.

=item return

This parameter is optional.

It takes the values 0 and 1.

The default value is 1.

Setting it to 0 causes C<sub tile()> to return an empty array ref.

Presumably you've set option 'write' to 1 to write the tiles to disk in this case.

Setting return to 1 causes C<sub tile()> to return an array ref of elements.

Each element is a hashref, with these keys:

=over 4

=item file_name

This is an automatically generated file name.

When the geometry is '2x3', say, the file names are of the form 1-1.png, 1-2.png, 2-1.png, 2-2.png, 3-1.png
and 3-2.png.

=item image

This is the Image::Magick object for one tile.

=back

=item verbose

This parameter is optional.

It takes the values 0 and 1.

The default value is 0.

Setting it to 1 causes various information to be written to STDOUT.

=item write

This parameter is optional.

It takes the values 0 and 1.

The default value is 0.

This value causes tiles to be not written to disk.

Setting it to 1 causes the tiles to be written to disk using the automatically generated files names as above.

=back

=head1 Method: new(...)

Returns a object of type C<Image::Magick::Tiler>.

See above, in the section called 'Constructor and initialization'.

=head1 Method: tile()

Returns an array ref, which may be empty. See the 'return' option above for details.

=head1 Author

C<Image::Magick::Tiler> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2005.

Home page: http://savage.net.au/index.html

=head1 Copyright

Australian copyright (c) 2005, Ron Savage.
	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
