use Image::RGBA::Sugar;
use Image::PNG::Inflated;

for rgba::text.readall($*ARGFILES) {
    my $name = .meta<name>;
    my $src = $*ARGFILES.path;
    my $dest = $name ?? $src.sibling("$name\.png") !! $src.extension('png');

    my $ss = ($src.s / 1000).round(0.01);
    $*ERR.print: "$src ->> {$dest.basename}   {$ss}k ->> ?";

    spurt $dest, .&to-png;

    my $ds = ($dest.s / 1000).round(0.01);
    $*ERR.print: "\b{$ds}k\n";
}
