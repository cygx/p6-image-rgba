use Image::RGBA::Text;
use Image::PNG::Inflated;

spurt "{ .meta<name> }.png", to-png |.unbox
    for Image::RGBA::Text.decode('examples/feep.txt'.IO, :all);
