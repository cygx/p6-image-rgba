# Copyright 2019 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

sub blend-alpha(uint8 $da, uint8 $sa --> uint8) {
    $sa + $da - ($sa * $da + 127) div 255;
}

sub blend-channel(uint8 $dc, uint8 $da, uint8 $sc, uint8 $sa, uint8 $a,
    num $gamma, num $inv-gamma --> uint8) {
    my uint $tmp = $da * (255 - $sa);
    my num $nu = $sc**$gamma * ($sa * 255) + $dc**$gamma * $tmp;
    my num $de = $sa * 255 + $tmp;
    (($nu / $de)**$inv-gamma).round;
}

sub fastblend-channel(uint8 $dc, uint8 $da, uint8 $sc, uint8 $sa, uint8 $a
    --> uint8) {
    my uint $tmp = $da * (255 - $sa);
    my num $nu = $sc * $sc * ($sa * 255) + $dc * $dc * $tmp;
    my num $de = $sa * 255 + $tmp;
    ($nu / $de).sqrt.round;
}

sub fakeblend-channel(uint8 $dc, uint8 $da, uint8 $sc, uint8 $sa, uint8 $a
    --> uint8) {
    my uint $tmp = $da * (255 - $sa);
    my uint $nu = $sc * ($sa * 255) + $dc * $tmp;
    my uint $de = $sa * 255 + $tmp;
    ($nu + $de div 2) div $de;
}

sub blend($d, $s, num $gamma --> Nil) is export {
    if $s.a != 0 {
        my uint8 $da = $d.a;
        my uint8 $sa = $s.a;
        my uint8 $a = blend-alpha($da, $sa);
        my num $inv-gamma = 1e0 / $gamma;

        $d.r = blend-channel($d.r, $da, $s.r, $sa, $a, $gamma, $inv-gamma);
        $d.g = blend-channel($d.g, $da, $s.g, $sa, $a, $gamma, $inv-gamma);
        $d.b = blend-channel($d.b, $da, $s.b, $sa, $a, $gamma, $inv-gamma);
        $d.a = $a;
    }
}

sub fastblend($d, $s --> Nil) is export {
    if $s.a != 0 {
        my uint8 $da = $d.a;
        my uint8 $sa = $s.a;
        my uint8 $a = blend-alpha($da, $sa);

        $d.r = fastblend-channel($d.r, $da, $s.r, $sa, $a);
        $d.g = fastblend-channel($d.g, $da, $s.g, $sa, $a);
        $d.b = fastblend-channel($d.b, $da, $s.b, $sa, $a);
        $d.a = $a;
    }
}

sub fakeblend($d, $s --> Nil) is export {
    if $s.a != 0 {
        my uint8 $da = $d.a;
        my uint8 $sa = $s.a;
        my uint8 $a = blend-alpha($da, $sa);

        $d.r = fakeblend-channel($d.r, $da, $s.r, $sa, $a);
        $d.g = fakeblend-channel($d.g, $da, $s.g, $sa, $a);
        $d.b = fakeblend-channel($d.b, $da, $s.b, $sa, $a);
        $d.a = $a;
    }
}
