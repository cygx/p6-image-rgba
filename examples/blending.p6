use Image::RGBA::Fun;
use Image::PNG::Inflated;

my $background = buf8.new(|@(black) xx 256);

my $real = create-image(256, 1, $background.clone);
my $fast = create-image(256, 1, $background.clone);
my $fake = create-image(256, 1, $background.clone);

for ^256 -> $x {
    given create-color(255, 0, 0, $x) {
        $real.pixel($x, 0).blend($_, 2.2);
        $fast.pixel($x, 0).blend($_);
        $fake.pixel($x, 0).fakeblend($_);
    }
}

my $rows = 24;
my $bytes = [~] ($real, $fast, $fake).map({ |(.bytes xx $rows) });
spurt @*ARGS[0] // 'blending.png', to-png($bytes, 256, $rows * 3);
