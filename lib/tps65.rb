# Library for tps65 touchpad contoroller evaluation board
# filepath: /lib/tps65.rb
require "mouse"
require "i2c"

class TPS65
  attr_reader :mouse
  def initialize(unit_name:, freq:, sda:, scl:)
    i2c = I2C.new(unit: unit_name, frequency: freq, sda_pin: sda, scl_pin: scl)

    # RDY pin
    rdy = GPIO.new(11, GPIO::IN)

    ref_x = Array.new(5)
    ref_y = Array.new(5)
    abs_x = Array.new(5)
    abs_y = Array.new(5)
    strength = Array.new(5)
    area = Array.new(5)

    @mouse = Mouse.new(driver: i2c)
    @mouse.task do |mouse|
      # puts 1
      # if rdy.read == 1 then
      #   # get the value of the register address to 0x000F-0x0010(info)
      #   # mouse.driver.write(0x74, [0x00, 0x0F])
      #   # temp1, temp2 = mouse.driver.read(0x74, 2).bytes
      #   # info = temp1 << 8 + temp2

      #   # get the value of the register address to 0x000D-0x000E(Gesture Events)
      #   mouse.driver.write(0x74, [0x00, 0x0D])
      #   temp1, temp2 = mouse.driver.read(0x74, 2).bytes
      #   event = (temp1 << 8) + temp2

      #   # get the value of the register address to 0x0011(Num of fingers)
      #   mouse.driver.write(0x74, [0x00, 0x11])
      #   nof = mouse.driver.read(0x74, 1).bytes[0]

      #   if nof > 0 then
      #     # for i = 0..4
      #     i=0
      #     # get the value of the register address to 0x0012-0x0013(relative x pos)
      #     mouse.driver.write(0x74, [0x00, 0x12])
      #     temp1, temp2 = mouse.driver.read(0x74, 2).bytes
      #     ref_x[i] = (temp1 + (temp2 << 8))/256

      #     # get the value of the register address to 0x0014-0x0015(relative y pos)
      #     mouse.driver.write(0x74, [0x00, 0x14])
      #     temp1, temp2 = mouse.driver.read(0x74, 2).bytes
      #     ref_y[i] = (temp1 + (temp2 << 8))/256

      #     ## 細かいジェスチャーを設定したい場合？
      #     # if nof > 1 then
      #     #   # get the value of the register address to 0x0016-0x0017(absolute x pos)
      #     #   mouse.driver.write(0x74, [0x00, 0x16])
      #     #   temp1, temp2 = mouse.driver.read(0x74, 2).bytes
      #     #   abs_x[0] = temp1 << 8 + temp2

      #     #   # get the value of the register address to 0x0018-0x0019(absolute y pos)
      #     #   mouse.driver.write(0x74, [0x00, 0x18])
      #     #   temp1, temp2 = mouse.driver.read(0x74, 2).bytes
      #     #   abs_y[i] = temp1 << 8 + temp2
      #     # end

      #     # get the value of the register address to 0x001A-0x001B(touch strength)
      #     # mouse.driver.write(0x74, [0x00, 0x1A])
      #     # temp1, temp2 = mouse.driver.read(0x74, 2).bytes
      #     # strength = temp1 << 8 + temp2

      #     # get the value of the register address to 0x0014-0x0015(Touch area/size)
      #     # mouse.driver.write(0x74, [0x00, 0x1C])
      #     # area[i] = mouse.driver.read(0x74, 1).bytes
      #     # end
      #   end

      #   # end of one communication cycle
      #   mouse.driver.write(0x74, [0xEE, 0xEE, 0x00])

      #   ## tap
      #   # LEFT: 0b001, RIGHT: 0b010
      #   button = 0
      #   # nof = 1
      #   if nof == 1 then
      #     if event & 0b0000001100000000 > 0 then
      #       button = 0b001
      #     end

      #     USB.merge_mouse_report(button, ref_x[0], ref_y[0], 0, 0)

      #   # nof >= 2
      #   elsif nof == 2
      #     if ( event & 0b0000000000000001 > 0 ) then
      #       button = 0b010
      #     elsif (event & 0b0000000000000010 > 0 )
      #       # Works as a scroll wheel
      #       USB.merge_mouse_report(button, 0, 0, ref_x[0], ref_y[0])
      #     elsif (event & 0b0000000000000100 > 0 )
      #       USB.merge_mouse_report(button, 0, 0, ref_x[0], ref_y[0])
      #     end
      #   elsif nof == 3
      #     if (event & 0b0000000000000010 > 0 ) then
      #       # Works as a scroll wheel
      #       USB.merge_mouse_report(button, 0, 0, ref_x[0]/2.0, -ref_y[0]/2.0)
      #     elsif (event & 0b0000000000000100 > 0 )
      #       USB.merge_mouse_report(button, 0, 0, ref_x[0]/2.0, -ref_y[0]/2.0)
      #     end
      #   elsif nof == 4
      #     if (event & 0b0000000000000010 > 0 ) then
      #       # Works as a scroll wheel
      #       USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      #     elsif (event & 0b0000000000000100 > 0 )
      #       USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      #     end
      #   elsif nof == 5
      #     if (event & 0b0000000000000010 > 0 ) then
      #       # Works as a scroll wheel
      #       USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      #     elsif (event & 0b0000000000000100 > 0 )
      #       USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      #     end
      #   end
      # end
    end
  end
end