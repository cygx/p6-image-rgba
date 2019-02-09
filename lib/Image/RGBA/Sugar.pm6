use Image::RGBA;
use Image::RGBA::Text;

my class rgba-text {
    method read(|c) { Image::RGBA::Text::Reader.read(|c) }
    method readall(|c) { Image::RGBA::Text::Reader.readall(|c) }
    method parse($text, |c) {
        Image::RGBA::Text::Decoder.create(|c).decode($text).image;
    }
}

my class rgba is export {
    method image(|c) { Image::RGBA.create(|c) }
    method text { rgba-text }
}
