require "consumer_key"
require "ssd1306"
require "tps65"
require "logo"

kbd = Keyboard.new

# Initialize RGBLED with pin, underglow_size, backlight_size and is_rgbw.
rgb = RGB.new(
  5, # pin number
  40, # size of underglow pixel
  20   # size of backlight pixel
)
rgb.effect = :swirl
rgb.hue = 0
rgb.speed = 25
kbd.append rgb
kbd.send_key :RGB_TOG

# tps65 = TPS65.new(unit_name: :RP2040_I2C0,
#                   freq: 100 * 1000, sda: 12, scl: 13)
# kbd.append tps65.mouse

OLED = SSD1306.new(unit_name: :RP2040_I2C1, freq: 100 * 1000, sda: 6, scl: 7)
OLED.all_clear()
OLED.draw_all(pic: $logo)

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
  KC_LCTL KC_LSFT LOWER_SPC  RAISE  KC_BTN1  KC_BTN2  LOWER  RAISE_ENT  KC_BSPC  KC_RALT
]
kbd.add_layer :lower, %i[
  KC_1   KC_2  KC_3   KC_4  KC_5     KC_6   KC_7   KC_8  KC_9  KC_0
  KC_TAB  IME  KC_ZKHK    KC_NONUS_HASH  KC_LBRC  KC_RBRC   KC_MINUS  KC_EQUAL  KC_UNDS  KC_BSLASH
  KC_F1  KC_F2  KC_F3   KC_F4  KC_F5     KC_F6  KC_F7   KC_F8  KC_F9  KC_F10
  KC_LCTL KC_LSFT  LOWER_SPC   FUNC    KC_BTN1         KC_BTN2   LOWER   FUNC_ENT     KC_BSPC  KC_RALT
]
kbd.add_layer :raise, %i[
  KC_KP_PLUS   KC_7  KC_8   KC_9  KC_KP_SLASH       KC_RPRN   KC_CIRC  KC_AMPR    KC_ASTER  KC_LPRN
  KC_KP_MINUS  KC_4  KC_5   KC_6  KC_KP_ASTERISK    KC_UNDS   KC_DEL   KC_UP      KC_UP     KC_RIGHT
  KC_0         KC_1  KC_2   KC_3  KC_KP_ENTER       KC_SLASH  KC_LEFT  KC_DOWN    KC_RIGHT  KC_DOT
  KC_LCTL KC_LSFT  FUNC_SPC  RAISE     KC_BTN1   KC_BTN2   FUNC      RAISE_ENT   KC_BSPC  KC_RALT
]
kbd.add_layer :func, %i[
  KC_F14  KC_F7   KC_F8     KC_F9  KC_F17   KC_F17   KC_F7  KC_F8     KC_F9    KC_F14
  KC_F13  KC_F4   KC_F5     KC_F6  KC_F16   KC_F16   KC_F4  KC_F5     KC_F6    KC_F13
  KC_F12  KC_F1   KC_F2     KC_F3  KC_INT1  HELP  KC_F1  KC_F2     KC_F3    KC_F12
  RGB_TOG KC_RGUI FUNC_SPC  FUNC   KC_BTN1  KC_BTN2  FUNC   FUNC_ENT  KC_RGUI  RGB_TOG
]

kbd.define_composite_key :HELP, %i(KC_LALT KC_LCTL KC_DEL)
kbd.define_composite_key :IME, %i(KC_LGUI KC_SPC)
kbd.define_mode_key :RAISE_ENT, [ :KC_ENTER, :raise, 300, 300 ]
kbd.define_mode_key :LOWER_SPC, [ :KC_SPACE, :lower, 300, 300 ]
kbd.define_mode_key :FUNC_ENT, [ :KC_ENTER, :func, 300, 300 ]
kbd.define_mode_key :FUNC_SPC, [ :KC_SPACE, :func, 300, 300 ]
kbd.define_mode_key :RAISE, [ nil, :raise, nil, nil ]
kbd.define_mode_key :LOWER, [ nil, :lower, nil, nil ]
kbd.define_mode_key :FUNC, [ nil, :func, nil, nil ]
kbd.define_mode_key :KC_BTN1, [ nil, Proc.new { USB.merge_mouse_report(0b000, 0, 0, 0, 0) }, nil, nil ]
kbd.define_mode_key :KC_BTN2, [ nil, Proc.new { USB.merge_mouse_report(0b010, 0, 0, 0, 0) }, nil, nil ]

kbd.start!

