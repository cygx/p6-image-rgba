use Test;
use Image::RGBA::Fun;

plan 4;

my $img := rgba-create-image-from-text(q:to/THE_END/, 2, 2);
    A B
    C D
    THE_END

is $img.pixel(0, 0).hex, '00FF00FF', 'parsed A';
is $img.pixel(1, 0).hex, 'FFFF00FF', 'parsed B';
is $img.pixel(0, 1).hex, '0000FFFF', 'parsed C';
is $img.pixel(1, 1).hex, 'FF00FFFF', 'parsed D';
