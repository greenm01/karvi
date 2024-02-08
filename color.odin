package karvi

import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"

import "colorful"

// FOREGROUND and BACKGROUND sequence codes
FOREGROUND :: "38"
BACKGROUND :: "48"

// Color is an interface implemented by all colors that can be converted to an
// ANSI sequence.
Color :: struct {
	color: string,  // hex color
	type: union {No_Color, ANSI_Color, ANSI256_Color, RGB_Color},
}

// create a new colorful hex color
// TODO: Add colorful.Color to API above?
// May be confusing becase RGB_Color is a hex string internally
// while a colorful.Color is abtually defined (r,g,b)
// Define an RGB color with (r,g,b) too?
new_hex_color :: proc(s: string) -> (color: colorful.Color) {
	color, _ = colorful.hex(s)
	return
}

// No_Color is a nop for terminals that don't support colors.
No_Color :: struct {
	using clr: ^Color,
}

new_no_color :: proc() -> ^Color {
	color := new(Color)
	color.color = ""
	color.type = No_Color{color}
	return color	
}

no_color_string :: proc(c: No_Color) -> string {
	return ""
}

// ANSI is a color (0-15) as defined by the ANSI Standard.
ANSI_Color :: struct {
	using clr: ^Color,
	c: int,
}

new_ansi_color :: proc(c: int) -> ^Color {
	color := new(Color)
	color.color = ansi_hex[c]
	color.type = ANSI_Color{color, c}
	return color	
}
	
ansi_string :: proc(c: ANSI_Color) -> (str: string) {
	return c.color
}

// ANSI256_Color is a color (16-255) as defined by the ANSI Standard.
ANSI256_Color :: struct {
	using clr: ^Color,
	c: int,
}

new_ansi256_color :: proc(c: int) -> ^Color {
	color := new(Color)
	color.color = ansi_hex[c]
	color.type = ANSI256_Color{color, c}
	return color	
}
	
ansi256_string :: proc(c: ANSI256_Color) -> (str: string) {
	return c.color
}

// RGB is a hex-encoded color, e.g. "#abcdef".
RGB_Color :: struct {
	using clr: ^Color,
	c: string,
}

new_rgb_color :: proc(c: string) -> ^Color {
	color := new(Color)
	color.color = c
	color.type = RGB_Color{color, c}
	return color
}

// ConvertToRGB converts a Color to a colorful.Color.
convert_to_hex :: proc(c: ^Color) -> colorful.Color {
	hex: string
	switch v in c.type {
	case RGB_Color:
		hex = v.c
	case ANSI_Color:
		hex = ansi_hex[v.c]
	case ANSI256_Color:
		hex = ansi_hex[v.c]
	case No_Color:
		hex = ""
	}

	ch, _ := colorful.hex(hex)
	return ch
}

// returns a hex string from a color
hex :: proc(c: colorful.Color) -> string {
	return colorful.color_hex(c)
}

sequence :: proc(color: ^Color, bg: bool) -> string {
	switch c in color.type {
	case No_Color:
		return ""
	case ANSI_Color:
		return ansi_sequence(c, bg)
	case ANSI256_Color:
		return ansi256_sequence(c, bg)
	case RGB_Color:
		return rgb_sequence(c, bg)
	}
	return ""
}

// Sequence returns the ANSI Sequence for the color.
ansi_sequence :: proc(c: ^Color, bg: bool) -> string {
	col := c.type.(ANSI_Color).c
	bg_mod :: proc(c: int, bg: bool) -> int {
		if bg {
			return c + 10
		}
		return c
	}

	if col < 8 {
		return fmt.tprintf("%d", bg_mod(col, bg)+30)
	}
	return fmt.tprintf("%d", bg_mod(col-8, bg)+90)
}

// Sequence returns the ANSI_Color Sequence for the color.
ansi256_sequence :: proc(c: ^Color, bg: bool) -> string {
	prefix := FOREGROUND
	if bg {
		prefix = BACKGROUND
	}
	return fmt.tprintf("%s;5;%d", prefix, c.type.(ANSI256_Color).c)
}

// Sequence returns the ANSI Sequence for the color.
rgb_sequence :: proc(c: ^Color, bg: bool) -> string {
	f, err := colorful.hex(c.type.(RGB_Color).c)
	if err != 0 {
		return ""
	}

	prefix := FOREGROUND
	if bg {
		prefix = BACKGROUND
	}
	return fmt.tprintf("%s;2;%d;%d;%d", prefix, u8(f.r*255), u8(f.g*255), u8(f.b*255))
}

// Converts an xterm term color with a 4 digit RGB component
// https://www.x.org/releases/X11R7.7/doc/man/man7/X.7.xhtml#heading11
xterm_color :: proc(s: string) -> (^Color, Error) {
	using Error
	if len(s) < 24 || len(s) > 25 {
		return new_rgb_color(""), Invalid_Color
	}

	str := s
	switch {
	case strings.has_suffix(str, BEL):
		str = strings.trim_suffix(str, BEL)
	case strings.has_suffix(str, ESC):
		str = strings.trim_suffix(str, ESC)
	case strings.has_suffix(str, ST):
		str = strings.trim_suffix(str, ST)
	case:
		return new_rgb_color(""), Invalid_Color
	}

	str = str[4:]
	prefix := ";rgb:"
	if !strings.has_prefix(str, prefix) {
		return new_rgb_color(""), Invalid_Color
	}

	str = strings.trim_prefix(str, prefix)

	h := strings.split(str, "/")
	hex := fmt.tprintf("#%s%s%s", h[0][:2], h[1][:2], h[2][:2])
	return new_rgb_color(hex), No_Error
}

// Similar to above, but shifting some bits and returns a string
xterm_color2 :: proc(s: string, cmd: int) -> string {
	prefix := fmt.tprintf("\e]%d;rgb:", cmd)
	s := strings.trim_prefix(s, prefix)
	// trim both just in case
	s = strings.trim_right(s, ST)
	s = strings.trim_right(s, BEL)
	
	i: int
	rgb: [3]f64
	for str in strings.split_iterator(&s, "/") {
		num, _ := strconv.parse_int(str, 16)
		rgb[i] = f64(num)
		i += 1
	}

	// https://github.com/dranjan/python-colordemo/blob/master/colordemo/terminal_query.py#L360
	// assume four digits
	nd: uint = 4 
	u := ((1 << (nd << 2)) - 1)
	fu := f64(u)

	r := rgb[0]/fu 
	g := rgb[1]/fu
	b := rgb[2]/fu 

	return colorful.color_hex(colorful.Color{r, g, b})
}
	
ansi256_to_ansi :: proc(c: ANSI256_Color) -> ^Color {
	r: int
	md := math.F64_MAX

	h, _ := colorful.hex(ansi_hex[c.c])
	for i := 0; i <= 15; i += 1 {
		hb, _ := colorful.hex(ansi_hex[c.c])
		d := colorful.distance_hsluv(h, hb)

		if d < md {
			md = d
			r = i
		}
	}

	return new_ansi_color(r)
}

hex_to_ansi256 :: proc(c: colorful.Color) -> ^Color {
	v2ci :: proc(v: f64) -> int {
		if v < 48 {
			return 0
		}
		if v < 115 {
			return 1
		}
		return int((v - 35) / 40)
	}

	// Calculate the nearest 0-based color index at 16..231
	r := v2ci(c.r * 255.0) // 0..5 each
	g := v2ci(c.g * 255.0)
	b := v2ci(c.b * 255.0)
	ci := 36*r + 6*g + b /* 0..215 */

	// Calculate the represented colors back from the index
	i2cv := [6]int{0, 0x5f, 0x87, 0xaf, 0xd7, 0xff}
	cr := i2cv[r] // r/g/b, 0..255 each
	cg := i2cv[g]
	cb := i2cv[b]

	// Calculate the nearest 0-based gray index at 232..255
	gray_idx: int
	average := (r + g + b) / 3
	if average > 238 {
		gray_idx = 23
	} else {
		gray_idx = (average - 3) / 10 // 0..23
	}
	gv := 8 + 10*gray_idx // same value for r/g/b, 0..255

	// Return the one which is nearer to the original input rgb value
	c2 := colorful.Color{r = f64(cr) / 255.0, g = f64(cg) / 255.0, b = f64(cb) / 255.0}
	g2 := colorful.Color{r = f64(gv) / 255.0, g = f64(gv) / 255.0, b = f64(gv) / 255.0}
	color_dist := colorful.distance_hsluv(c, c2)
	gray_dist := colorful.distance_hsluv(c, g2)

	color_string := colorful.color_hex(c)
	if color_dist <= gray_dist do return new_ansi256_color(16 + ci)
	return new_ansi256_color(232 + gray_idx)
}
