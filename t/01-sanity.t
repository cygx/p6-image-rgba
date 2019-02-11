use Test;
use Image::RGBA::Fun;

plan 2;

ok     .pixel(0, 0) eq '00FF00FF'
    && .pixel(1, 0) eq 'FFFF00FF'
    && .pixel(0, 1) eq '0000FFFF'
    && .pixel(1, 1) eq 'FF00FFFF', 'parsed A B C D image'
    given create-image-from-text(q:to/THE_END/, 2, 2);
        A B C D
        THE_END

ok load-image-from-text('') =:= Nil, 'loading empty text returns Nil';
