use Image::RGBA::Sugar;
use Image::PNG::Inflated;

for rgba::text.readall($*ARGFILES) {
    my $name = .meta<name>;
    my $src = $*ARGFILES.path;
    my $dest = $name ?? $src.sibling("$name\.png") !! $src.extension('png');

    note "$src ->> $dest";
    spurt $dest, .&to-png;
}
