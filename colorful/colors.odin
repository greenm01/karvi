package colorful

import "core:fmt"
import "core:os"
import "core:c/libc"
import "core:math"

// A color is stored internally using sRGB (standard RGB) values in the range 0-1
Color :: struct {
	r, g, b: f64
}

// Hex parses a "html" hex color-string, either in the 3 "#f0c" or 6 "#ff1034" digits form.
hex :: proc(scol: string) -> (Color, os.Errno) {
	format := "#%02x%02x%02x"
	factor := 1.0 / 255.0
	if len(scol) == 4 {
		format = "#%1x%1x%1x"
		factor = 1.0 / 15.0
	}

	r, g, b: u8
	s := strings.clone_to_cstring(scol)
	f := strings.clone_to_cstring(format)
	n := libc.sscanf(s, f, &r, &g, &b)
	//n, err := fmt.Sscanf(scol, format, &r, &g, &b)
	if n != 3 {
		return Color{}, fmt.eprintf("color: %v is not a hex-color", scol)
	}

	return Color{f64(r) * factor, f64(g) * factor, f64(b) * factor}, os.ERROR_NONE
}

// clamp01 clamps from 0 to 1.
clamp01 :: proc(v: f64) -> f64 {
	return math.max(0.0, math.min(v, 1.0))
}
