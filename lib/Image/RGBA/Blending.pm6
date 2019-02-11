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
        my uint8 ($dr, $dg, $db, $da) = @$d;
        my uint8 ($sr, $sg, $sb, $sa) = @$s;

        my num $inv-gamma = 1e0 / $gamma;
        my uint8 $a = blend-alpha($da, $sa);

        $d.r = blend-channel($dr, $da, $sr, $sa, $a, $gamma, $inv-gamma);
        $d.g = blend-channel($dg, $da, $sg, $sa, $a, $gamma, $inv-gamma);
        $d.b = blend-channel($db, $da, $sb, $sa, $a, $gamma, $inv-gamma);
        $d.a = $a;
    }
}

sub fastblend($d, $s --> Nil) is export {
    if $s.a != 0 {
        my uint8 ($dr, $dg, $db, $da) = @$d;
        my uint8 ($sr, $sg, $sb, $sa) = @$s;

        my uint8 $a = blend-alpha($da, $sa);

        $d.r = fastblend-channel($dr, $da, $sr, $sa, $a);
        $d.g = fastblend-channel($dg, $da, $sg, $sa, $a);
        $d.b = fastblend-channel($db, $da, $sb, $sa, $a);
        $d.a = $a;
    }
}

sub fakeblend($d, $s --> Nil) is export {
    if $s.a != 0 {
        my uint8 ($dr, $dg, $db, $da) = @$d;
        my uint8 ($sr, $sg, $sb, $sa) = @$s;

        my uint8 $a = blend-alpha($da, $sa);

        $d.r = fakeblend-channel($dr, $da, $sr, $sa, $a);
        $d.g = fakeblend-channel($dg, $da, $sg, $sa, $a);
        $d.b = fakeblend-channel($db, $da, $sb, $sa, $a);
        $d.a = $a;
    }
}
