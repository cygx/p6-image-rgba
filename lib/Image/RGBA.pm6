# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

class Image::RGBA {
    has buf8 $.bytes = buf8.allocate($!width * $!height * 4);
    has uint $.width is required;
    has uint $.height is required;
    has %.meta;

    method create($width, $height, $bytes?) {
        self.new(:$width, :$height, |(:$bytes with $bytes));
    }

    method pixel($x, $y) {
        my $bytes := $!bytes;
        my $offset := ($y * $!width + $x) * 4;

        my class Pixel {
            method r is rw { $bytes[$offset    ] }
            method g is rw { $bytes[$offset + 1] }
            method b is rw { $bytes[$offset + 2] }
            method a is rw { $bytes[$offset + 3] }

            method value($endian = BigEndian) is rw {
                Proxy.new:
                    FETCH => -> $ {
                        $bytes.read-uint32($offset, $endian);
                    },
                    STORE => -> $, $value {
                        $bytes.write-uint32($offset, $value, $endian);
                    }
            }

            method gist { self.Str }
            method Str { "rgba($.r,$.g,$.b,$.a)" }
            method hex { self.value.fmt('%08X') }
        }
    }

    method buf8 { $!bytes }
    method ::('Buf[uint8]') { $!bytes }
    method blob8 { $!bytes }
    method ::('Blob[uint8]') { $!bytes }
}
