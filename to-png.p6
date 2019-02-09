use lib 'lib';

use Image::RGBA::Sugar;
use Image::PNG::Inflated;

spurt "{ .meta<name> }.png", .&to-png
    for rgba.text.readall($*ARGFILES);
