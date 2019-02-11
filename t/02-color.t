use Test;
use Image::RGBA::Color;

plan 7;

ok all(.r, .g, .b, .a) == 0xFF, 'Color passes through 0xFF'
    given Color.create(|(0xFF xx 4));

ok all(.r, .g, .b, .a) == 0xFF, 'ColorRW passes through 0xFF'
    given ColorRW.create(|(0xFF xx 4));

for ^5 {
    my $d = Color.create(|roll(4, ^0xFF));
    my $s = Color.create(|roll(3, ^0xFF), 0);
    ok $d == all($d.rw.blend($s),
                 $d.rw.blend($s, 2.2),
                 $d.rw.fakeblend($s)), "blending $s onto $d does nothing";
}
