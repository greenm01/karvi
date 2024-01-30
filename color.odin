package karvi

import "core:fmt"
import "core:math"
import "core:strings"

import "colorful"

// FOREGROUND and BACKGROUND sequence codes
FOREGROUND :: "38"
BACKGROUND :: "48"

// Color is an interface implemented by all colors that can be converted to an
// ANSI sequence.
Color :: struct {
	// Sequence returns the ANSI Sequence for the color.
	//Sequence(bg bool) string
   type: union {No_Color, ANSI_Color, ANSI256_Color, RGB_Color}
}

// No_Color is a nop for terminals that don't support colors.
No_Color :: struct {
	using color: ^Color,
}

new_no_color :: proc() -> ^Color {
	color := new(Color)
	color.type := No_Color{color}
	return color	
}

no_color_string :: proc(c: No_Color) -> string {
	return ""
}

// ANSI is a color (0-15) as defined by the ANSI Standard.
ANSI_Color :: struct {
	using color: ^Color,
	c: int,
}

new_ansi_color :: proc(c: int) -> ^Color {
	color := new(Color)
	color.type := ANSI_Color{color, c}
	return color	
}
	
ansi_string :: proc(c: ANSI_Color) -> string {
	return ANSI_HEX[c.c]
}

// ANSI256_Color is a color (16-255) as defined by the ANSI Standard.
ANSI256_Color :: struct {
	using color: ^Color,
	c: int,
}

new_ansi256_color :: proc(c: int) -> ^Color {
	color := new(Color)
	color.type := ANSI256_Color{color, c}
	return color	
}
	
ansi256_string :: proc(c: ANSI256_Color) -> string {
	return ANSI_HEX[c.c]
}

// RGB is a hex-encoded color, e.g. "#abcdef".
RGB_Color :: struct {
	using color: ^Color,
	c: string,
}

new_rgb_color :: proc(c: string) -> ^Color {
	color := new(Color)
	color.type := RGB_Color{color, c}
	return color
}

// ConvertToRGB converts a Color to a colorful.Color.
convert_to_rbg :: proc(c: Color) -> colorful.Color {
	hex: string
	switch v in c.type {
	case RGB_Color:
		hex = v.c
	case ANSI_Color:
		hex = ANSI_HEX[v.c]
	case ANSI256_Color:
		hex = ANSI_HEX[v.c]
	}

	ch, _ := colorful.hex(hex)
	return ch
}

sequence :: proc(color: ^Color) -> string {
	switch c in color.type {
	case No_Color:
		return no_color_sequence(c)
	case ANSI_Color:
		return ansi_sequence(c)
	case ANSI256_Color:
		return ansi256_sequence(c)
	case RGB_Color:
		return rgb_sequence(c)
	}
}

// Sequence returns the ANSI Sequence for the color.
no_color_sequence :: proc(_: bool) -> string {
	return ""
}

// Sequence returns the ANSI Sequence for the color.
ansi_sequence :: proc(c: ANSI_Color, bg: bool) -> string {
	col := c.c
	bgMod :: proc(c: int) -> int {
		if bg {
			return c + 10
		}
		return c
	}

	if col < 8 {
		return fmt.tprintf("%d", bg_mod(col)+30)
	}
	return fmt.tprintf("%d", bg_mod(col-8)+90)
}

// Sequence returns the ANSI_Color Sequence for the color.
ansi256_sequence :: proc(c: ANSI256_Color, bg: bool) -> string {
	prefix := FOREGROUND
	if bg {
		prefix = BACKGROUND
	}
	return fmt.tprintf("%s;5;%d", prefix, c.c)
}

// Sequence returns the ANSI Sequence for the color.
rgb_sequence :: proc(c: RGB_Color, bg: bool) -> string {
	f, err := colorful.hex(c.c)
	if err != 0 {
		return ""
	}

	prefix := FOREGROUND
	if bg {
		prefix = BACKGROUND
	}
	return fmt.tprintf("%s;2;%d;%d;%d", prefix, u8(f.r*255), u8(f.g*255), u8(f.b*255))
}

xterm_color :: proc(s: string) -> (RGB_Color, Error) {
	using Error
	if len(s) < 24 || len(s) > 25 {
		return new_rgb_color(""), Invalid_Color
	}

	switch {
	case strings.has_suffix(s, string(BEL)):
		s = strings.trim_suffix(s, string(BEL))
	case strings.has_suffix(s, string(ESC)):
		s = strings.trim_suffix(s, string(ESC))
	case strings.has_suffix(s, ST):
		s = strings.trim_suffix(s, ST)
	case:
		return new_rgb_color(""), Invalid_Color
	}

	s = s[4:]

	prefix := ";rgb:"
	if !strings.has_prefix(s, prefix) {
		return new_rgb_color(""), Invalid_Color
	}
	s = strings.trim_prefix(s, prefix)

	h := strings.split(s, "/")
	hex := fmt.tprintf("#%s%s%s", h[0][:2], h[1][:2], h[2][:2])
	return new_rgb_color(hex), No_Error
}

ansi256_to_ansi :: proc(c: ANSI256_Color) -> ANSI_Color {
	r: int
	md := math.F64_MAX

	h, _ := colorful.hex(ANSI_HEX[c.c])
	for i := 0; i <= 15; i += 1 {
		hb, _ := colorful.hex(ANSI_HEX[i])
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
	r := v2ci(c.R * 255.0) // 0..5 each
	g := v2ci(c.G * 255.0)
	b := v2ci(c.B * 255.0)
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

	if color_dist <= gray_dist do return new_ansi256_color(16 + ci)
	return new_ansi256_color(232 + gray_idx)
}
