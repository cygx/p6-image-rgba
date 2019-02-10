use Test;
use Image::RGBA::Fun;

plan 2;

my $img := create-rgba-from-text(q:to/THE_END/, 2, 2);
    A B C D
    THE_END

ok     $img.pixel(0, 0).hexa eq '00FF00FF'
    && $img.pixel(1, 0).hexa eq 'FFFF00FF'
    && $img.pixel(0, 1).hexa eq '0000FFFF'
    && $img.pixel(1, 1).hexa eq 'FF00FFFF', 'parsed A B C D image';

ok load-rgba-from-text('') =:= Nil, 'loading empty text returns Nil';
