use Image::RGBA::Fun;
use Image::PNG::Inflated;

sub size($file) {
    ($file.s / 1000).round(0.01) ~ 'k';
}

for @*ARGS -> IO() $src {
    for slurp-rgba-from-textfile($src) {
        my $name = .meta<name>;
        my $dest = $name ?? $src.sibling("$name\.png")
                         !! $src.extension('png');

        $*ERR.print: "$src ->> {$dest.basename}   {size $src} ->> ?";
        spurt $dest, .&to-png;
        $*ERR.print: "\b{size $dest}\n";
    }
}
