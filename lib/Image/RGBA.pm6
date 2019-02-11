# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use Image::RGBA::Color;

my class Pixel is Positional does ColoredRW {
    has $!bytes;
    has uint $!offset;

    submethod BUILD(:$!bytes, :$!offset) {}

    method r is rw { $!bytes[$!offset    ] }
    method g is rw { $!bytes[$!offset + 1] }
    method b is rw { $!bytes[$!offset + 2] }
    method a is rw { $!bytes[$!offset + 3] }

    method value($order = BigEndian) is rw {
        Proxy.new:
            FETCH => -> $ {
                $!bytes.read-uint32($!offset, $order);
            },
            STORE => -> $, $value {
                $!bytes.write-uint32($!offset, $value, $order);
            }
    }

    method of { uint8 }
    method elems { 4 }
    method AT-POS(uint $pos) is rw { $!bytes[$!offset + $pos] }
    method EXISTS-POS(uint $pos) { 0 <= $pos < 4 }

    method ASSIGN-POS(uint $pos, uint8 $value) {
        $!bytes[$!offset + $pos] =  $value;
    }

    method STORE($values) {
        $!bytes[$!offset    ] = $values[0];
        $!bytes[$!offset + 1] = $values[1];
        $!bytes[$!offset + 2] = $values[2];
        $!bytes[$!offset + 3] = $values[3];
        self;
    }
}

class Image::RGBA {
    has buf8 $.bytes = buf8.allocate($!width * $!height * 4);
    has uint $.width is required;
    has uint $.height is required;
    has %.meta;

    method create($width, $height, $bytes?) {
        self.new(:$width, :$height, |(:$bytes with $bytes));
    }

    method pixel($x, $y) {
        Pixel.new(:$!bytes, offset => ($y * $!width + $x) * 4);
    }

    method set(uint $x, uint $y, uint8 $r, uint8 $g, uint8 $b, uint8 $a) {
        my uint $offset = ($y * $!width + $x) * 4;
        $!bytes[$offset    ] = $r;
        $!bytes[$offset + 1] = $g;
        $!bytes[$offset + 2] = $b;
        $!bytes[$offset + 3] = $a;
        self;
    }

    method scanline(uint $y, uint $x = 0, uint $len = ($!width - $x) * 4) {
        my uint $offset = ($y * $!width + $x) * 4;
        $!bytes.subbuf-rw($offset, $len);
    }

    method buf8 { $!bytes }
    method ::('Buf[uint8]') { $!bytes }
    method blob8 { $!bytes }
    method ::('Blob[uint8]') { $!bytes }
}
