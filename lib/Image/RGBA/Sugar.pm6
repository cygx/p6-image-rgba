use Image::RGBA;
use Image::RGBA::Text;

class rgba {
    method image(|c) { Image::RGBA.create(|c) }

    class text {
        method read(|c) { Image::RGBA::Text::Reader.read(|c) }
        method readall(|c) { Image::RGBA::Text::Reader.readall(|c) }
        method parse($text, |c) {
            Image::RGBA::Text::Decoder.create(|c).decode($text).image;
        }
    }
}
