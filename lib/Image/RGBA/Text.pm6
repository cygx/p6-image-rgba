use Image::RGBA;
use nqp;

unit module Image::RGBA::Text;

sub paint($bytes, uint $pos is copy, $color --> uint) {
    given $color.chars {
        # basic
        when 1 {
            my uint $val = (:16($color) orelse .throw);
            my uint $dark = !($val +& 8);

            $bytes[$pos++] = 0xFF * ?($val +& 1) +> $dark;
            $bytes[$pos++] = 0xFF * ?($val +& 2) +> $dark;
            $bytes[$pos++] = 0xFF * ?($val +& 4) +> $dark;
            $bytes[$pos++] = 0xFF * !($val == 8);
        }

        # grayscale
        when 2 {
            my uint $val = (:16($color) orelse .throw);

            $bytes[$pos++] = $val;
            $bytes[$pos++] = $val;
            $bytes[$pos++] = $val;
            $bytes[$pos++] = 0xFF;
        }

        # rgb
        when 3 {
            $bytes[$pos++] = 0x11 * :16($_) for $color.comb;
            $bytes[$pos++] = 0xFF;
        }

        # grayscale + alpha
        when 4 {
            $bytes[$pos++] = 0x11 * :16($_) for $color.comb;
        }

        # rrggbb
        when 6 {
            $bytes[$pos++] = :16($_) for $color.comb(2);
            $bytes[$pos++] = 0xFF;
        }

        # rrggbbaa
        when 8 {
            $bytes[$pos++] = :16($_) for $color.comb(2);
        }

        default { !!! }
    }

    $pos;
}

class BasicDecoder { ... }
class ScalingDecoder { ... }

class Decoder {
    has %.palette;

    method decode(Str $_ ) {
        self.paint(%!palette{$_} // $_) for .words;
        self;
    }

    proto method create(|) {*}

    multi method create($width, $height, :%palette = {}) {
        BasicDecoder.new(
            image => Image::RGBA.create($width, $height),
            :%palette);
    }

    multi method create($width, $height, $scale, :%palette = {}) {
        ScalingDecoder.new(
            image => Image::RGBA.create($width * $scale, $height * $scale),
            :$scale, :%palette);
    }
}

class BasicDecoder is Decoder {
    has Image::RGBA $.image is required;
    has uint $!pos;

    method scale { 1 }
    method seek(uint $pos) { $!pos = $pos }
    method tell { $!pos }
    method done { $!pos == $!image.width * $!image.height * 4 }
    method paint($color) { $!pos = paint($!image.bytes, $!pos, $color) }
}

class ScalingDecoder is BasicDecoder {
    has uint $.scale is required;
    has uint $!mark;

    method paint($color) {
        my $bytes := $.image.bytes;
        my uint $scanline = $.image.width * 4;
        my uint $blocksize = $!scale * 4;

        my $pixel := buf8.allocate(4);
        paint($pixel, 0, $color);

        my $row := buf8.allocate($blocksize);
        nqp::splice($row, $pixel, $_ * 4, 4) for ^$!scale;

        my uint $pos = $!mark;
        my uint $tail = $pos + $scanline * ($!scale - 1) + $blocksize;
        while $pos < $tail {
            nqp::splice($bytes, $row, $pos, $blocksize);
            $pos += $scanline;
        }

        self.seek($tail);

        $!mark += $blocksize;
        $!mark = $tail if $!mark %% $scanline;
    }
}

class Reader {
    method read($src) {
        LEAVE $src.?close;
        self.readall($src).iterator.pull-one;
    }

    method readall($src) {
        my %palettes;
        my $palette := Nil;
        my $decoder := Nil;

        gather for $src.lines {
            /^
            [ '=palette' <!{ defined $decoder }> \h+
                ((\w+) {
                    %palettes{$0} = $palette := {};
                })

            | '=img' <!{ defined $decoder }> \h+
                ((\d+) \h+ (\d+) \h+ (\d+) {
                    $decoder := Decoder.create(+$0, +$1, +$2);
                    $palette := $decoder.palette;
                })
                
            | '=img' <!{ defined $decoder }> \h+
                ((\d+) \h+ (\d+) {
                    $decoder := Decoder.create(+$0, +$1);
                    $palette := $decoder.palette;
                })

            | '=use' <?{ defined $palette }> \h+
                ((\w+) {
                    $palette{.keys} = .values
                        with %palettes{$0};
                })

            | '=map' <?{ defined $palette }> \h+
                ([(\H+) \h+ (<.xdigit>+)]+ % \h+ {
                    $palette{~<<$0} = ~<<$1;
                })

            | '=meta' <?{ defined $decoder }> \h+
                ((\w+) \h+ (.+) {
                    $decoder.image.meta{$0} = ~$1;
                })
            || '=' { !!! }
            || \h*
            ]
            $/
            or do if $decoder.decode($_).done {
                take $decoder.image;
                $decoder := Nil;
                $palette := Nil;
            }
        }
    }
}
