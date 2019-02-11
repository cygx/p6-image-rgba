# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use Image::RGBA;
use Image::RGBA::Color;
use Image::RGBA::Text;

# Create individual images from raw data

sub create-image($width, $height, $bytes?) is export {
    Image::RGBA.create($width, $height, $bytes);
}

proto create-image-from-text($text, $width, $height,
        $scale = 1, :%palette) is export {
    {*}.decode($text).image;
}

multi create-image-from-text($text, $width, $height,
        $scale where * > 1, :%palette) {
    Image::RGBA::Text::ScalingDecoder.create($width, $height, $scale, %palette);
}

multi create-image-from-text($text, $width, $height, $?, :%palette) {
    Image::RGBA::Text::Decoder.create($width, $height, %palette);
}


# Load individual image, parsing directives

sub load-image-from-text($text, :%palettes) is export {
    Image::RGBA::Text.load($text, :%palettes);
}

proto load-image-from-textfile($file, :%palettes) is export {
    Image::RGBA::Text.load({*}, :%palettes);
}

multi load-image-from-textfile(IO::Handle $_) { $_ }
multi load-image-from-textfile(IO() $_) { $_ }


# Load all images, parsing directives

sub slurp-images-from-text($text, :%palettes) is export {
    Image::RGBA::Text.slurp($text, :%palettes);
}

proto slurp-images-from-textfile($file, :%palettes) is export {
    Image::RGBA::Text.slurp({*}, :%palettes);
}

multi slurp-images-from-textfile(IO::Handle $_) { $_ }
multi slurp-images-from-textfile(IO() $_) { $_ }


# Color manipulation

sub create-color($r, $g, $b, $a = 255) is export {
    Color.create($r, $g, $b, $a);
}

sub create-color-rw($r, $g, $b, $a = 255) is export {
    ColorRW.create($r, $g, $b, $a);
}

my constant black is export = Color.create(0, 0, 0);
my constant white is export = Color.create(255, 255, 255);
