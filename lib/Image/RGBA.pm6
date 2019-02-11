# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

my class Pixel is Positional {
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
    method ASSIGN-POS(uint $pos, uint8 $value) {
        $!bytes[$!offset + $pos] =  $value;
    }
    method EXISTS-POS(uint $pos) { 0 <= $pos < 4 }
    method STORE($values) {
        $!bytes[$!offset    ] = $values[0];
        $!bytes[$!offset + 1] = $values[1];
        $!bytes[$!offset + 2] = $values[2];
        $!bytes[$!offset + 3] = $values[3];
        self;
    }

    method list { ($.r, $.g, $.b, $.a) }

    method gist { self.Str }
    method Str { "rgba($.r,$.g,$.b,$.a)" }
    method hex { (self.value +> 8).fmt('%06X') }
    method hexa { self.value.fmt('%08X') }
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

    method buf8 { $!bytes }
    method ::('Buf[uint8]') { $!bytes }
    method blob8 { $!bytes }
    method ::('Blob[uint8]') { $!bytes }
}
