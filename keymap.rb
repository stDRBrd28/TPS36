require "consumer_key"
require "i2c"
require "mouse"

kbd = Keyboard.new

# Initialize RGBLED with pin, underglow_size, backlight_size and is_rgbw.
rgb = RGB.new(
  5, # pin number
  40, # size of underglow pixel
  20   # size of backlight pixel
)
rgb.effect = :breath
rgb.hue = 0
rgb.speed = 25
kbd.append rgb
kbd.send_key :RGB_TOG

# OLED = I2C.new(
#   unit: :RP2040_I2C1,
#   frequency: 100 * 1000,
#   sda_pin: 6,
#   scl_pin: 7
# )

# # initialize
# OLED.write(0x3C, [0b10000000, 0x00])
# OLED.write(0x3C, [0b00000000, 0xAE])
# OLED.write(0x3C, [0b00000000, 0xA8, 0x3F])
# OLED.write(0x3C, [0b10000000, 0x40])
# OLED.write(0x3C, [0b10000000, 0xA1])
# OLED.write(0x3C, [0b10000000, 0xC8])
# OLED.write(0x3C, [0b00000000, 0xDA, 0x12])
# OLED.write(0x3C, [0b00000000, 0x81, 0xFF])
# OLED.write(0x3C, [0b10000000, 0xA4])
# OLED.write(0x3C, [0b00000000, 0xA6])
# OLED.write(0x3C, [0b00000000, 0xD5, 0x80])
# OLED.write(0x3C, [0b00000000, 0x20, 0x10])
# OLED.write(0x3C, [0b00000000, 0x21, 0x00, 0x7F])
# OLED.write(0x3C, [0b00000000, 0x22, 0x00, 0x07])
# OLED.write(0x3C, [0b00000000, 0x8D, 0x14])
# OLED.write(0x3C, [0b10000000, 0xAF])

# i=0
# while i<8 do
#   OLED.write(0x3C, [0b10000000,
#                     0xB0 | i,
#                     0x21,
#                     0x00 | 0,
#                     0x7F])

#   j=0
#   while j<128 do
#     OLED.write(0x3C, [0x00, 0x21, 0x00 | j, 0x00 | j+1])
#     if j%2 == 1
#       OLED.write(0x3C, [0b01000000,
#                         0xFF]) 
#     else
#       OLED.write(0x3C, [0b01000000,
#                         0x00])
#     end 
#     j=j+1
#   end
#   i=i+1
# end

i2c = I2C.new(
  unit: :RP2040_I2C0,
  frequency: 100 * 1000,
  sda_pin: 12,
  scl_pin: 13
)

# RDY pin
rdy = GPIO.new(11, GPIO::IN)

ref_x = Array.new(5)
ref_y = Array.new(5)
abs_x = Array.new(5)
abs_y = Array.new(5)
strength = Array.new(5)
area = Array.new(5)

mouse = Mouse.new(driver: i2c)

mouse.task do |mouse, keyboard|
  if rdy.read == 1 then
    # get the value of the register address to 0x000F-0x0010(info)
    # mouse.driver.write(0x74, [0x00, 0x0F])
    # temp1, temp2 = mouse.driver.read(0x74, 2).bytes
    # info = temp1 << 8 + temp2

    # get the value of the register address to 0x000D-0x000E(Gesture Events)
    mouse.driver.write(0x74, [0x00, 0x0D])
    temp1, temp2 = mouse.driver.read(0x74, 2).bytes
    event = (temp1 << 8) + temp2

    # get the value of the register address to 0x0011(Num of fingers)
    mouse.driver.write(0x74, [0x00, 0x11])
    nof = mouse.driver.read(0x74, 1).bytes[0]

    if nof > 0 then
      # for i = 0..4
      i=0
        # get the value of the register address to 0x0012-0x0013(relative x pos)
        mouse.driver.write(0x74, [0x00, 0x12])
        temp1, temp2 = mouse.driver.read(0x74, 2).bytes
        ref_x[i] = (temp1 + (temp2 << 8))/256

        # get the value of the register address to 0x0014-0x0015(relative y pos)
        mouse.driver.write(0x74, [0x00, 0x14])
        temp1, temp2 = mouse.driver.read(0x74, 2).bytes
        ref_y[i] = (temp1 + (temp2 << 8))/256

        ## 細かいジェスチャーを設定したい場合？
        # if nof > 1 then
        #   # get the value of the register address to 0x0016-0x0017(absolute x pos)
        #   mouse.driver.write(0x74, [0x00, 0x16])
        #   temp1, temp2 = mouse.driver.read(0x74, 2).bytes
        #   abs_x[0] = temp1 << 8 + temp2

        #   # get the value of the register address to 0x0018-0x0019(absolute y pos)
        #   mouse.driver.write(0x74, [0x00, 0x18])
        #   temp1, temp2 = mouse.driver.read(0x74, 2).bytes
        #   abs_y[i] = temp1 << 8 + temp2
        # end

        # get the value of the register address to 0x001A-0x001B(touch strength)
        # mouse.driver.write(0x74, [0x00, 0x1A])
        # temp1, temp2 = mouse.driver.read(0x74, 2).bytes
        # strength = temp1 << 8 + temp2

        # get the value of the register address to 0x0014-0x0015(Touch area/size)
        # mouse.driver.write(0x74, [0x00, 0x1C])
        # area[i] = mouse.driver.read(0x74, 1).bytes
      # end
    end

    # end of one communication cycle
    mouse.driver.write(0x74, [0xEE, 0xEE, 0x00])

    ## tap
    # LEFT: 0b001, RIGHT: 0b010
    button = 0
    # nof = 1
    if nof == 1 then
      if event & 0b0000001100000000 > 0 then
        button = 0b001
      end

      USB.merge_mouse_report(button, ref_x[0], ref_y[0], 0, 0)

    # nof >= 2
    elsif nof == 2
      if ( event & 0b0000000000000001 > 0 ) then
        button = 0b010
      elsif (event & 0b0000000000000010 > 0 )
        # Works as a scroll wheel
        USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      elsif (event & 0b0000000000000100 > 0 )
        USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      end
    elsif nof == 3
      if (event & 0b0000000000000010 > 0 ) then
        # Works as a scroll wheel
        USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      elsif (event & 0b0000000000000100 > 0 )
        USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      end
    elsif nof == 4
      if (event & 0b0000000000000010 > 0 ) then
        # Works as a scroll wheel
        USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      elsif (event & 0b0000000000000100 > 0 )
        USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      end
    elsif nof == 5
      if (event & 0b0000000000000010 > 0 ) then
        # Works as a scroll wheel
        USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      elsif (event & 0b0000000000000100 > 0 )
        USB.merge_mouse_report(button, 0, 0, ref_x[0], -ref_y[0])
      end
    end
  end
end
kbd.append mouse

r0, r1, r2, r3 = 14, 8, 9, 10
c0, c1, c2, c3, c4, c5, c6, c7, c8, c9 = 15, 26, 27, 28, 29, 4, 3, 2, 1, 0

kbd.init_matrix_pins(
  [
    [ [r0,c0], [r0,c1], [r0,c2], [r0,c3], [r0,c4],                                     [r0,c5], [r0,c6], [r0,c7], [r0,c8], [r0,c9] ],
    [ [r1,c0], [r1,c1], [r1,c2], [r1,c3], [r1,c4],                                     [r1,c5], [r1,c6], [r1,c7], [r1,c8], [r1,c9] ],
    [ [r2,c0], [r2,c1], [r2,c2], [r2,c3], [r2,c4],                                     [r2,c5], [r2,c6], [r2,c7], [r2,c8], [r2,c9] ],
    [                   [r3,c0], [r3,c1], [r3,c2], [r3,c3], [r3,c4], [r3,c5], [r3,c6], [r3,c7], [r3,c8], [r3,c9]          ]
  ]
)

kbd.add_layer :default, %i[
  KC_Q    KC_W    KC_E       KC_R   KC_T     KC_Y     KC_U   KC_I       KC_O     KC_P
  KC_A    KC_S    KC_D       KC_F   KC_G     KC_H     KC_J   KC_K       KC_L     KC_SCOLON
  KC_Z    KC_X    KC_C       KC_V   KC_B     KC_N     KC_M   KC_COMMA   KC_DOT   KC_SLASH
  KC_LSFT KC_LCTL LOWER_SPC  RAISE  KC_BTN1  KC_BTN2  LOWER  RAISE_ENT  KC_BSPC  KC_RALT
]
kbd.add_layer :raise, %i[
  KC_KP_PLUS   KC_7  KC_8   KC_9  KC_KP_SLASH     KC_RPRN   KC_CIRC   KC_AMPR  KC_ASTER  KC_LPRN
  KC_KP_MINUS  KC_4  KC_5   KC_6  KC_KP_ASTERISK  KC_UNDS   KC_DEL    KC_UP    KC_UP     KC_RIGHT
  KC_0         KC_1  KC_2   KC_3  KC_KP_ENTER     KC_SLASH  KC_LEFT   KC_DOWN  KC_RIGHT  KC_DOT
  KC_LSFT      KC_LCTL  FUNC_SPC  RAISE    KC_BTN1         KC_BTN2   FUNC      RAISE_ENT  KC_BSPC  KC_RALT
]
kbd.add_layer :lower, %i[
  KC_RPRN   KC_CIRC  KC_AMPR    KC_ASTER  KC_LPRN   KC_KP_PLUS   KC_7  KC_8   KC_9  KC_KP_SLASH
  KC_UNDS   KC_DEL   KC_UP      KC_UP     KC_RIGHT  KC_KP_MINUS  KC_4  KC_5   KC_6  KC_KP_ASTERISK
  KC_SLASH  KC_LEFT  KC_DOWN    KC_RIGHT  KC_DOT    KC_0         KC_1  KC_2   KC_3  KC_KP_ENTER
  KC_LSFT   KC_LCTL  LOWER_SPC  FUNC      KC_BTN1   KC_BTN2      LOWER    FUNC_ENT  KC_BSPC  KC_RALT
]
kbd.add_layer :func, %i[
  KC_F14  KC_F7   KC_F8     KC_F9  KC_F17   KC_F17   KC_F7  KC_F8     KC_F9    KC_F14
  KC_F13  KC_F4   KC_F5     KC_F6  KC_F16   KC_F16   KC_F4  KC_F5     KC_F6    KC_F13
  KC_F12  KC_F1   KC_F2     KC_F3  KC_INT1  KC_INT2  KC_F1  KC_F2     KC_F3    KC_F12
  RGB_TOG KC_RGUI FUNC_SPC  FUNC   KC_BTN1  KC_BTN2  FUNC   FUNC_ENT  KC_RGUI  RGB_TOG
]

kbd.define_composite_key :IME, %i(KC_LALT KC_LCTL KC_DEL)
kbd.define_mode_key :RAISE_ENT, [ :KC_ENTER, :raise, 150, 150 ]
kbd.define_mode_key :LOWER_SPC, [ :KC_SPACE, :lower, 150, 150 ]
kbd.define_mode_key :FUNC_ENT, [ :KC_ENTER, :func, 150, 150 ]
kbd.define_mode_key :FUNC_SPC, [ :KC_SPACE, :func, 150, 150 ]
kbd.define_mode_key :RAISE, [ nil, :raise, nil, nil ]
kbd.define_mode_key :LOWER, [ nil, :lower, nil, nil ]
kbd.define_mode_key :FUNC, [ nil, :func, nil, nil ]
kbd.define_mode_key :KC_BTN1, [ nil, Proc.new { USB.merge_mouse_report(0b000, 0, 0, 0, 0) }, nil, nil ]
kbd.define_mode_key :KC_BTN2, [ nil, Proc.new { USB.merge_mouse_report(0b010, 0, 0, 0, 0) }, nil, nil ]

kbd.start!

