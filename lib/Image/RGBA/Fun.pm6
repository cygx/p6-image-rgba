# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use Image::RGBA;
use Image::RGBA::Text;

# Create individual images from raw data

sub rgba-create-image($width, $height, $bytes?) is export {
    Image::RGBA.create($width, $height, $bytes);
}

proto rgba-create-image-from-text($text, $width, $height,
        $scale = 1, :%palette) is export {
    {*}.decode($text).image;
}

multi rgba-create-image-from-text($text, $width, $height,
        $scale where * > 1, :%palette) {
    Image::RGBA::Text::ScalingDecoder.create($width, $height, $scale, %palette);
}

multi rgba-create-image-from-text($text, $width, $height, $?, :%palette) {
    Image::RGBA::Text::Decoder.create($width, $height, %palette);
}


# Load individual image, parsing directives

sub rgba-load-image-from-text($text, :%palettes) is export {
    Image::RGBA::Text.load($text, :%palettes);
}

proto rgba-load-image-from-textfile($file, :%palettes) is export {
    Image::RGBA::Text.load({*}, :%palettes);
}

multi rgba-load-image-from-textfile(IO::Handle $_) { $_ }
multi rgba-load-image-from-textfile(IO() $_) { $_ }


# Load all images, parsing directives

sub rgba-slurp-text($text, :%palettes) is export {
    Image::RGBA::Text.slurp($text, :%palettes);
}

proto rgba-slurp-textfile($file, :%palettes) is export {
    Image::RGBA::Text.slurp({*}, :%palettes);
}

multi rgba-slurp-textfile(IO::Handle $_) { $_ }
multi rgba-slurp-textfile(IO() $_) { $_ }
