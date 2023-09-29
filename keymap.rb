require "consumer_key"
require "i2c"
require "mouse"

kbd = Keyboard.new

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
  KC_Q    KC_W    KC_E      KC_R      KC_T    KC_Y     KC_U      KC_I     KC_O     KC_P
  KC_A    KC_S    KC_D      KC_F      KC_G    KC_H     KC_J      KC_K     KC_L     KC_SCOLON
  KC_Z    KC_X    KC_C      KC_V      KC_B    KC_N     KC_M      KC_COMMA KC_DOT   KC_SLASH
  KC_LALT KC_LCTL LOWER_SPC KC_BTN1  KC_MUTE  KC_BTN2  RAISE_ENT IME      KC_RGUI  RGB_HUI
]
kbd.add_layer :raise, %i[
  KC_EXLM KC_AT   KC_HASH KC_DLR    KC_PERC  KC_CIRC  KC_AMPR   KC_ASTER KC_LPRN  KC_RPRN
  KC_LABK KC_LCBR KC_LBRC KC_LPRN   KC_QUOTE KC_LEFT  KC_DOWN   KC_UP    KC_RIGHT KC_UNDS
  KC_RABK KC_RCBR KC_RBRC KC_RPRN   KC_DQUO  KC_TILD  KC_BSLS   KC_COMMA KC_DOT   KC_SLASH
  KC_LALT KC_LCTL LOWER_SPC KC_BTN1  RGB_TOG KC_BTN2  RAISE_ENT IME      KC_RGUI  RGB_HUI
]
kbd.add_layer :lower, %i[
  KC_1    KC_2    KC_3    KC_4      KC_5      KC_6     KC_7      KC_8     KC_9     KC_0
  KC_LABK KC_LCBR KC_LBRC KC_LPRN   KC_QUOTE  KC_LEFT  KC_DOWN   KC_UP    KC_RIGHT KC_NO
  KC_RABK KC_RCBR KC_RBRC KC_RPRN   KC_DQUO   KC_NO    KC_BTN1   KC_BTN2  KC_NO    KC_NO
  KC_LALT KC_LCTL LOWER_SPC KC_BTN1  ADNS_TOG KC_BTN2  RAISE_ENT IME      KC_RGUI  RGB_HUI
]

kbd.define_composite_key :IME, %i(KC_RSFT KC_RCTL KC_BSPACE)
kbd.define_mode_key :RAISE_ENT, [ :KC_ENTER, :raise, 150, 150 ]
kbd.define_mode_key :LOWER_SPC, [ :KC_SPACE, :lower, 150, 150 ]

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

i2c = I2C.new(
  unit: :RP2040_I2C0,
  frequency: 100 * 1000,
  sda_pin: 12,
  scl_pin: 13
)

# RDY pin
rdy = GPIO.new(11, GPIO::IN)

mouse = Mouse.new(driver: i2c)
mouse.task do |mouse, keyboard|
  if rdy.read == 1
    # get the value of the register address to 0x0006-0x0007(Gesture Events)
    info = mouse.driver.read(0xE9, 1).bytes
    puts info

    # get the value of the register address to 0x0006-0x0007(Gesture Events)
    # mouse.driver.write(0xE8, 0x000D)
    # event = mouse.driver.read(0xE9, 2)

    # get the value of the register address to 0x0006-0x0007(Num of fingers)
    # mouse.driver.write(0xE8, 0x0011)
    # nof = mouse.driver.read(0xE9, 1)

    # if nof > 0
    #   for i in 1..nof do
    #     # get the value of the register address to 0x0012-0x0013(relative x pos)
    #     mouse.driver.write(0xE8, 0x0012)
    #     event1= mouse.driver.read(0xE9, 2)

    #     # get the value of the register address to 0x0014-0x0015(relative y pos)
    #     mouse.driver.write(0xE8, 0x0014)
    #     event1= mouse.driver.read(0xE9, 2)

    #     if nof > 1
    #       # get the value of the register address to 0x0016-0x0017(absolute x pos)
    #       mouse.driver.write(0xE8, 0x0016)
    #       event1= mouse.driver.read(0xE9, 2)

    #       # get the value of the register address to 0x0018-0x0019(absolute y pos)
    #       mouse.driver.write(0xE8, 0x0018)
    #       event1= mouse.driver.read(0xE9, 2)
    #     end

    #     # get the value of the register address to 0x001A-0x001B(touch strength)
    #     mouse.driver.write(0xE8, 0x001A)
    #     event1= mouse.driver.read(0xE9, 2)

    #     # get the value of the register address to 0x0014-0x0015(Touch area/size)
    #     mouse.driver.write(0xE8, 0x001C)
    #     event1 = mouse.driver.read(0xE9, 1)
    #   end
    # end

    # # single touch
    # ref_x[0] = -left if 0 < left
    # ref_y[0] = -up if 0 < up
    # # LEFT: 0b001, RIGHT: 0b010, MIDDLE: 0b100
    # button = push == 128 ? 0b100 : 0
    # if keyboard.layer == :default
    #   # 4x speed if the value is larger than 3
    #   3 < x.abs ? x *= 4 : x *= 
    #   3 < y.abs ? y *= 4 : y *= 
    #   USB.merge_mouse_report(button, ref_x[0], ref_y[0], 0, 0)
    # else
    #   # Works as a scroll wheel when layer is changed
    #   USB.merge_mouse_report(button, 0, 0, x, -y)
    # end
  end
end
kbd.append mouse

kbd.start!

