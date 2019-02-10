# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use Image::RGBA;
use Image::RGBA::Text;

# Create individual images from raw data

sub create-rgba($width, $height, $bytes?) is export {
    Image::RGBA.create($width, $height, $bytes);
}

proto create-rgba-from-text($text, $width, $height,
        $scale = 1, :%palette) is export {
    {*}.decode($text).image;
}

multi create-rgba-from-text($text, $width, $height,
        $scale where * > 1, :%palette) {
    Image::RGBA::Text::ScalingDecoder.create($width, $height, $scale, %palette);
}

multi create-rgba-from-text($text, $width, $height, $?, :%palette) {
    Image::RGBA::Text::Decoder.create($width, $height, %palette);
}


# Load individual image, parsing directives

sub load-rgba-from-text($text, :%palettes) is export {
    Image::RGBA::Text.load($text, :%palettes);
}

proto load-rgba-from-textfile($file, :%palettes) is export {
    Image::RGBA::Text.load({*}, :%palettes);
}

multi load-rgba-from-textfile(IO::Handle $_) { $_ }
multi load-rgba-from-textfile(IO() $_) { $_ }


# Load all images, parsing directives

sub slurp-rgba-from-text($text, :%palettes) is export {
    Image::RGBA::Text.slurp($text, :%palettes);
}

proto slurp-rgba-from-textfile($file, :%palettes) is export {
    Image::RGBA::Text.slurp({*}, :%palettes);
}

multi slurp-rgba-from-textfile(IO::Handle $_) { $_ }
multi slurp-rgba-from-textfile(IO() $_) { $_ }
