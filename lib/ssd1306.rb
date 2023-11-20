# Library for ssd1306 OLED module
# filepath: /lib/ssd1306.rb
require "i2c"

class SSD1306
    def initialize(unit_name:, freq:, sda:, scl:)
        @i2c = I2C.new(unit: unit_name, frequency: freq, sda_pin: sda, scl_pin: scl)

        # initialize
        @i2c.write(0x3C, [0b10000000, 0x00])
        @i2c.write(0x3C, [0b00000000, 0xAE])
        @i2c.write(0x3C, [0b00000000, 0xA8, 0x3F])
        @i2c.write(0x3C, [0b10000000, 0x40])
        @i2c.write(0x3C, [0b10000000, 0xA1])
        @i2c.write(0x3C, [0b10000000, 0xC8])
        @i2c.write(0x3C, [0b00000000, 0xDA, 0x12])
        @i2c.write(0x3C, [0b00000000, 0x81, 0xFF])
        @i2c.write(0x3C, [0b10000000, 0xA4])
        @i2c.write(0x3C, [0b00000000, 0xA6])
        @i2c.write(0x3C, [0b00000000, 0xD5, 0x80])
        @i2c.write(0x3C, [0b00000000, 0x20, 0x10])
        @i2c.write(0x3C, [0b00000000, 0x21, 0x00, 0x7F])
        @i2c.write(0x3C, [0b00000000, 0x22, 0x00, 0x07])
        @i2c.write(0x3C, [0b00000000, 0x8D, 0x14])
        @i2c.write(0x3C, [0b10000000, 0xAF])


        i=0
        while i<8 do
            @i2c.write(0x3C, [0b10000000,
                            0xB0 | i,
                            0x21,
                            0x00 | 0,
                            0x7F])

          j=0
          while j<128 do
            @i2c.write(0x3C, [0x00, 0x21, 0x00 | j, 0x00 | j+1])
            @i2c.write(0x3C, [0b01000000,
                            0xFF])
            j=j+1
          end
          i=i+1
        end
        return @i2c
    end

    def all_clear()
        i=0
        while i<8 do
            @i2c.write(0x3C, [0b10000000,
                            0xB0 | i,
                            0x21,
                            0x00 | 0,
                            0x7F])

          j=0
          while j<128 do
            @i2c.write(0x3C, [0x00, 0x21, 0x00 | j, 0x00 | j+1])
            @i2c.write(0x3C, [0b01000000,
                            0x00])
            j=j+1
          end
          i=i+1
        end
    end

    def all_white()
        i=0
        while i<8 do
            @i2c.write(0x3C, [0b10000000,
                            0xB0 | i,
                            0x21,
                            0x00 | 0,
                            0x7F])

          j=0
          while j<128 do
            @i2c.write(0x3C, [0x00, 0x21, 0x00 | j, 0x00 | j+1])
            @i2c.write(0x3C, [0b01000000,
                            0xFF])
            j=j+1
          end
          i=i+1
        end
    end

    def write_string(str, font, size)
    end

    # def draw(pic)
    #     for k = 0 .. pic.length - 1
    #         k 

end