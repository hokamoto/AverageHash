=begin
Copyright (c) 2014 Hideki Okamoto (Twitter: @tox2ro)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
                                 distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end

require 'bundler'
Bundler.require

class AverageHash
  def self.calc(filename, size = 16)
    image = Magick::Image::read(filename).first
    columns = image.columns
    rows =  image.rows

    minified_pixels = image.resize(size, size).quantize(256, Magick::GRAYColorspace).get_pixels(0, 0, size, size)
    average_color = minified_pixels.reduce(0.0) { |sum, pixel| sum+= (pixel.red * 256 / Magick::QuantumRange) } / (size * size)

    image.destroy!

    hash = ''
    minified_pixels.map { |pixel| (pixel.red * 256 / Magick::QuantumRange) < average_color ? 1 : 0 }.each_slice(8) do |word|
      hash << '%02x' % word.join('').to_i(2)
    end

    image = nil

    [hash, columns, rows]
  end

  def self.compare(hash1, hash2)
    0 if hash1.length != hash2.length

    hash1_binary = '%0256b' % hash1.to_i(16)
    hash2_binary = '%0256b' % hash2.to_i(16)

    sum = 0.0
    hash1_binary.length.times do |i|
      sum += 1.0 if hash1_binary[i] == hash2_binary[i]
    end
    sum / hash1_binary.length
  end
end
