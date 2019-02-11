# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

unit package Image::RGBA;

use Image::RGBA::Blending;

class Color { ... }
class ColorRW { ... }

role Colored is export {
    method r { ... }
    method g { ... }
    method b { ... }
    method a { ... }

    method list { ($.r, $.g, $.b, $.a) }
    method shortlist { ($.r, $.g, $.b) }

    method hex { self.shortlist>>.fmt('%02X').join }
    method hexa { self.list>>.fmt('%02X').join }

    method gist { "rgba($.r,$.g,$.b,$.a)" }
    method Str { self.hexa }
    method Int { ($.r +< 24) +| ($.g +< 16) +| ($.b +< 8) +| $.a }
    method Numeric { self.Int }

    method ro { self }
    method rw { self.ColorRW }

    method Color { Color.new(:$.r, :$.g, :$.b, :$.a) }
    method ColorRW { ColorRW.new(:$.r, :$.g, :$.b, :$.a) }
}

role ColoredRW does Colored is export {
    method ro { self.Color }
    method rw { self }

    proto method blend($color, $gamma?) {
        {*}
        self;
    }

    multi method blend($color) {
        fastblend(self, $color);
    }

    multi method blend($color, Num() $gamma) {
        blend(self, $color, $gamma);
    }

    method fakeblend($color) {
        fakeblend(self, $color);
        self;
    }
}

class Color does Colored is export {
    has uint8 ($.r, $.g, $.b, $.a);

    # RAKUDOBUG
    method r { my uint8 $ = $!r }
    method g { my uint8 $ = $!g }
    method b { my uint8 $ = $!b }
    method a { my uint8 $ = $!a }

    method create(*@ ($r, $g, $b, $a = 255)) {
        self.new(:$r, :$g, :$b, :$a);
    }

    method Color { self }
}

class ColorRW does ColoredRW is export {
    has uint8 ($.r is rw, $.g is rw, $.b is rw, $.a is rw);

    # RAKUDOBUG
    method r is rw {
        Proxy.new(FETCH => -> $ { my $ = my uint8 $ = $!r },
                  STORE => -> $, uint8 $_ { $!r = $_ });
    }
    method g is rw {
        Proxy.new(FETCH => -> $ { my $ = my uint8 $ = $!g },
                  STORE => -> $, uint8 $_ { $!g = $_ });
    }
    method b is rw {
        Proxy.new(FETCH => -> $ { my $ = my uint8 $ = $!b },
                  STORE => -> $, uint8 $_ { $!b = $_ });
    }
    method a is rw {
        Proxy.new(FETCH => -> $ { my $ = my uint8 $ = $!a },
                  STORE => -> $, uint8 $_ { $!a = $_ });
    }

    method create(*@ ($r, $g, $b, $a = 255)) {
        self.new(:$r, :$g, :$b, :$a);
    }

    method ColorRW { self }
}
