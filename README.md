# Image::RGBA [![Build Status][TRAVIS_IMG]][TRAVIS]

Create and manipulate 32-bit RGBA images


# Synopsis

```perl6
use Image::RGBA;

my $img = Image::RGBA.create(10, 20);
my $pixel = $img.pixel(2, 5);
$pixel.g = 0xA0;
say $pixel;
```

```perl6
use Image::RGBA::Text;
use Image::PGN::Inflated;

my $img = Image::RGBA::Text.load('examples/camelia.txt'.IO);
spurt 'camelia.png', to-png($img);

for Image::RGBA::Text.slurp('examples/feep.txt'.IO) {
    spurt "{.meta<name>}.png", .&to-png;
}
```

```perl6
use Image::RGBA::Fun;
use Image::PGN::Inflated;

my $img = load-rgba-from-textfile('examples/camelia.txt');
spurt 'camelia.png', to-png($img);

my %palette = x => 'fbf', o => 'a33';
say create-rgba-from-text(q:to/THE_END/, 2, 2, :%palette).pixel(0, 1);
    x o
    o x
    THE_END
```


# Description

This module allows the manipulation of raw RGBA images on a per-pixel basis
and the creation of such images from a simple text format.

The pixel data is held in a flat byte buffer, with each 4-byte sequence
describing the red, green, blue and alpha channel.

The text representation of a pixel is given by a sequence of non-whitespace
characters (a 'word'), separated by whitespace to form the image data.

Before decoding, each word gets filtered through a 'palette', a hash mapping
arbitrary words to hexadecimal color values in one of the 6 supported formats.

Images may be embedded in structured text files, with each line potentially
holding a parsing directive starting in `=`, or pixel data.

## The Base Module Image::RGBA

Wraps binary pixel data.

```perl6
class Image::RGBA {
    has buf8 $.bytes;
    has uint $.width is required;
    has uint $.height is required;
    has %.meta;

    method create($width, $height, $bytes?) { ... }
    method pixel($x, $y) { ... }
}

my class Pixel {
    # numerical manipulation
    method r is rw { ... }
    method g is rw { ... }
    method b is rw { ... }
    method a is rw { ... }
    method value($order = BigEndian) is rw { ... }

    # stringification
    method Str { ... }  # rgba(?,?,?,?)
    method hex { ... }  # hexadecimal, excluding alpha channel
    method hexa { ... } # hexadecimal, including alpha channel
}
```

## Parsing Text with Image::RGBA::Text

Methods `load` and `slurp` for text parsing are exposed via the type object.

```perl6
class Image::RGBA::Text {
    # loads a single image
    method load($src, :%palettes = {}) { ... }

    # returns a sequence of all images
    method slurp($src, :%palettes = {}) { ... }
}
```

The `$src` argument must provide a `lines` method. Examples of valid sources
are strings, file handles and path objects. A hash of named palette hashes may
be passed in, allowing communication betweeen sources.

The module contains two decoder classes that implement parsing of color values
and colorization of the image.

```perl6
class Image::RGBA::Text::Decoder {
    has Image::RGBA $.image is required;
    has Associative $.palette = {};

    method create($width, $height, %palette?) { ... }

    # colorize a single pixel, moving the cursor forward
    method paint($color) { ... }

    # use each word of the text to colorize a subsequent pixel
    method decode($text) { ... }

    # check if the image has been fully colorized
    method done { ... }
}

class Image::RGBA::Text::ScalingDecoder is Image::RGBA::Text::Decoder {
    has uint $.scale is required;
    method create($width, $height, $scale, %palette?) { ... }
}
```
The latter class allows automatic scaling of the image by an integer factor.

## Functional API provided by Image::RGBA::Fun

```perl6
# Create individual images from raw data
sub create-rgba($width, $height, $bytes?) { ... }
sub create-rgba-from-text($text, $width, $height, $scale = 1, :%palette) { ... }

# Load individual image, parsing directives
sub load-rgba-from-text($text, :%palettes) { ... }
sub load-rgba-from-textfile($file, :%palettes) { ... }

# Load all images, parsing directives
sub slurp-rgba-from-text($text, :%palettes) { ... }
sub slurp-rgba-from-textfile($file, :%palettes) is export { ... }
```

If a file argument is not of type `IO::Handle`, it is assumed to be a file
path and converted via a call to `.IO`.


# The Textual Format

Yet to be properly documented. When in doubt, check the [`examples`][EXAMPLES]
directory for working code.

## Supported Directives

    =img <width> <height> <scale>?

    =palette <name>

    =map <alias> <color>

    =use <palette>

    =meta <key> <value>

Following an `=img` directive, until the image has been fully colorized,
each line that does not start in `=` is assumed to hold pixel data.

A `=palette` directive may occur between `=img` directives, but may not
occur until any given image is complete.

## Supported Color Formats

There are six different ways to specify colors. They are distinguished by the
number of characters in the given string.

### A single hexadecimal digit

Numbers 0 through 7 are black and dark colors, all opaque. Number 8 is a
transparent black pixel. Numbers 9 through F are bright colors followed
by white.

| Digit | RGB value | Alpha value | Name                  |
|-------|-----------|-------------|-----------------------|
| 0     | #000000   | 100%        | black                 |
| 1     | #800000   | 100%        | dark red (maroon)     |
| 2     | #008000   | 100%        | dark green            |
| 3     | #808000   | 100%        | dark yellow (olive)   |
| 4     | #000080   | 100%        | dark blue (navy)      |
| 5     | #800080   | 100%        | dark magenta (purple) |
| 6     | #008080   | 100%        | dark cyan (teal)      |
| 7     | #808080   | 100%        | dark gray             |
| 8     | #000000   | 0%          | transparent black     |
| 9     | #FF0000   | 100%        | red                   |
| A     | #00FF00   | 100%        | green (lime)          |
| B     | #FFFF00   | 100%        | yellow                |
| C     | #0000FF   | 100%        | blue                  |
| D     | #FF00FF   | 100%        | magenta (fuchsia)     |
| E     | #00FFFF   | 100%        | cyan (aqua)           |
| F     | #FFFFFF   | 100%        | white                 |

### Double hexadecimal digits

Double hexadecimal digits, i.e. 00 through FF, will result in a greyscale of
opaque pixels. 00 is black, FF is white, the values in between just have the
given hexadecimal number for the R, G, B channels and FF for the alpha channel.

### Three hexadecimal digits

Three hexadecimal digits will result in opaque pixels where the individual
hexadecimal digits are doubled and stored as the R, G, and B value
respectively. For example, the value `47e` would result in the RGB color
value `#4477ee` at fixed alpha value FF.

### Four hexadecimal digits

This works the same way as three hexadecimal digits, but the alpha channel
takes its value from the fourth digit rather than being fixed at FF.

### Six hexadecimal digits

Six hexadecimal digits work exactly like you would expect from HTML, CSS,
or graphics software in general: The first two digits are for the red
channel, the next two for the green channel, and the last two for the blue
channel. The alpha channel is always FF.

### Eight hexadecimal digits

This works the same way as six hexadecimal digits, but the last two digits
are used for the alpha channel.


# Bugs and Development

Development happens at [GitHub][GH]. If you found a bug or have a feature
request, use the [issue tracker][TRACKER] over there.


# Copyright and License

Copyright (C) 2019 by cygx \<<cygx@cpan.org>\>

Distributed under the [Boost Software License, Version 1.0][LICENSE]


[TRAVIS_IMG]:   https://travis-ci.org/cygx/p6-image-rgba.svg?branch=master
[TRAVIS]:       https://travis-ci.org/cygx/p6-image-rgba
[GH]:           https://github.com/cygx/p6-image-rgba
[TRACKER]:      https://github.com/cygx/p6-image-rgba/issues
[LICENSE]:      https://www.boost.org/LICENSE_1_0.txt
[EXAMPLES]:     https://github.com/cygx/p6-image-rgba/tree/master/examples
