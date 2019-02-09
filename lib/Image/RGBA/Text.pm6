use Image::RGBA;

my class Decoder {
    has Image::RGBA $.image is required;
    has %.palette;
    has uint $!pos;

    method seek(uint $pos) {
        $!pos = $pos;
    }

    method tell {
        $!pos;
    }

    method done {
        $!pos == $!image.width * $!image.height * 4;
    }

    method paint($color --> Nil) {
        my $bytes := $!image.bytes;
        my uint $pos = $!pos;
        LEAVE $!pos = $pos;

        given $color.chars {
            # basic
            when 1 {
                my uint $val = :16($color) orelse .throw;
                my uint $dark = !($val +& 8);

                $bytes[$pos++] = 0xFF * ?($val +& 1) +> $dark;
                $bytes[$pos++] = 0xFF * ?($val +& 2) +> $dark;
                $bytes[$pos++] = 0xFF * ?($val +& 4) +> $dark;
                $bytes[$pos++] = 0xFF * !($val == 8);
            }

            # grayscale
            when 2 {
                my uint $val = :16($color) orelse .throw;

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
    }

    method decode(Str $_ ) {
        self.paint(%!palette{$_} // $_)
            for .words;

        self;
    }
}

my class ScalingDecoder is Decoder {
    has uint $.scale is required;
    has uint $!pos;

    method paint($color) {
        my uint $scanline = $.image.width * 4;

        loop (my uint $y = 0; $y < $!scale; ++$y) {
            self.seek($!pos + $y * $scanline);

            loop (my uint $x = 0; $x < $!scale; ++$x) {
                self.Decoder::paint($color);
            }
        }

        $!pos += $!scale * 4;
        $!pos = $.tell if $!pos %% $scanline;
    }
}

class Image::RGBA::Text {
    multi method decode($src) {
        LEAVE $src.?close;
        self.decode($src, :all).iterator.pull-one;
    }

    multi method decode($src, :$all!) {
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
                    my $scale = +$2;
                    my $width = +$0 * $scale;
                    my $height = +$1 * $scale;
                    my $image = Image::RGBA.new(:$width, :$height);

                    $decoder := ScalingDecoder.new(:$image, :$scale);
                    $palette := $decoder.palette;
                })
                
            | '=img' <!{ defined $decoder }> \h+
                ((\d+) \h+ (\d+) {
                    my $width = +$0;
                    my $height = +$1;
                    my $image = Image::RGBA.new(:$width, :$height);

                    $decoder := Decoder.new(:$image);
                    $palette := $decoder.palette;
                })

            | '=use' <?{ defined $palette }> \h+
                ((\w+) {
                    $palette{.keys} = .values
                        with %palettes{$0};
                })

            | '=map' <?{ defined $palette }> \h+
                ([(\H+) \h+ (<.xdigit>+)]+ % \h+ {
                    $palette{$0} = ~$1;
                })

            | '=meta' <?{ defined $decoder }> \h+
                ((\w+) \h+ (.+) {
                    $decoder.image.meta{$0} = ~$1;
                })
            ]
            || '=' { !!! }
            $/
            or do if $decoder.decode($_).done {
                take $decoder.image;
                $decoder := Nil;
                $palette := Nil;
            }
        }
    }
}
