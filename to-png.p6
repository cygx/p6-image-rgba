use lib 'lib';

use Image::RGBA::Text;
use Image::PNG::Inflated;

spurt "{ .meta<name> }.png", to-png |.unbox
    for Image::RGBA::Text.decode($*ARGFILES, :all);
