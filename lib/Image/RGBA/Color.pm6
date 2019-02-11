# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

unit package Image::RGBA;

use Image::RGBA::Blending;

role Colored is export {
    method r { ... }
    method g { ... }
    method b { ... }
    method a { ... }

    method list { ($.r, $.g, $.b, $.a) }

    method hex { (self.value +> 8).fmt('%06X') }
    method hexa { self.value.fmt('%08X') }
    method gist { "rgba($.r,$.g,$.b,$.a)" }
    method Str { self.hexa }
}

class Color does Colored is export {
    has uint8 $.r;
    has uint8 $.g;
    has uint8 $.b;
    has uint8 $.a;

    method create($r, $g, $b, $a) {
        self.new(:$r, :$g, :$b, :$a);
    }
}

role ColoredRW does Colored is export {
    method Color { Color.new(:$.r, :$.g, :$.b, :$.a) }

    proto method blend($color, num $gamma?) {*}
    multi method blend($color) { fastblend(self, $color) }
    multi method blend($color, num $gamma) { blend(self, $color, $gamma) }
    method fakeblend($color) { fakeblend(self, $color) }
}

class ColorRW does Colored is export {
    has uint8 $.r is rw;
    has uint8 $.g is rw;
    has uint8 $.b is rw;
    has uint8 $.a is rw;

    method create($r, $g, $b, $a) {
        self.new(:$r, :$g, :$b, :$a);
    }
}
