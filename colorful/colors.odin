package colorful

import "core:strings"
import "core:c/libc"
import "core:math"

import "color"

// A color is stored internally using sRGB (standard RGB) values in the range 0-1
Color :: struct {
	r, g, b: f64
}

// Constructs a colorful.Color from something implementing color.Color
make_color :: proc(col: color.Color) -> (Color, bool) {
	r, g, b, a := color.get_rgba(&col)
	if a == 0 {
		return Color{0, 0, 0}, false
	}

	// Since color.Color is alpha pre-multiplied, we need to divide the
	// RGB values by alpha again in order to get back the original RGB.
	r *= 0xffff
	r /= a
	g *= 0xffff
	g /= a
	b *= 0xffff
	b /= a

	return Color{f64(r) / 65535.0, f64(g) / 65535.0, f64(b) / 65535.0}, true
}

// color_hex returns the hex "html" representation of the color, as in #ff0080.
color_hex :: proc(col: Color) -> string {
	// Add 0.5 for rounding
	return fmt.tprintf("#%02x%02x%02x", u8(col.r*255.0+0.5), u8(col.g*255.0+0.5), u8(col.b*255.0+0.5))
}

// hex parses a "html" hex color-string, either in the 3 "#f0c" or 6 "#ff1034" digits form.
hex :: proc(scol: string) -> (Color, int) {
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
		return Color{}, 1
	}

	return Color{f64(r) * factor, f64(g) * factor, f64(b) * factor}, 0
}

// clamp01 clamps from 0 to 1.
clamp01 :: proc(v: f64) -> f64 {
	return math.max(0.0, math.min(v, 1.0))
}

// Returns Clamps the color into valid range, clamping each value to [0..1]
// If the color is valid already, this is a no-op.
clamped :: proc(c: Color) -> Color {
	return Color{clamp01(c.R), clamp01(c.G), clamp01(c.B)}
}

luvlch_to_luv :: proc(l, c, h: f64) -> (L, u, v: f64) {
	H := 0.01745329251994329576 * h // Deg2Rad
	u = c * math.cos(H)
	v = c * math.sin(H)
	L = l
	return
}

delinearize :: proc(v: f64) -> f64 {
	if v <= 0.0031308 do return 12.92 * v
	return 1.055*math.pow(v, 1.0/2.4) - 0.055
}

// LinearRgb creates an sRGB color out of the given linear RGB color (see http://www.sjbrown.co.uk/2004/05/14/gamma-correct-rendering/).
linear_rgb :: proc(r, g, b: f64) -> Color {
	return Color{delinearize(r), delinearize(g), delinearize(b)}
}

// XyzToLinearRgb converts from CIE XYZ-space to Linear RGB space.
xyz_to_linear_rgb :: proc(x, y, z: f64) -> (r, g, b: f64) {
	r = 3.2409699419045214*x - 1.5373831775700935*y - 0.49861076029300328*z
	g = -0.96924363628087983*x + 1.8759675015077207*y + 0.041555057407175613*z
	b = 0.055630079696993609*x - 0.20397695888897657*y + 1.0569715142428786*z
	return
}

cub :: proc(v: f64) -> f64 {
	return v * v * v
}

// For this part, we do as R's graphics.hcl does, not as wikipedia does.
// Or is it the same?
xyz_to_uv :: proc(x, y, z: f64) -> (u, v: f64) {
	denom := x + 15.0*y + 3.0*z
	if denom == 0.0 {
		u, v = 0.0, 0.0
	} else {
		u = 4.0 * x / denom
		v = 9.0 * y / denom
	}
	return
}

luv_to_xyz_white_ref :: proc(l, u, v: f64, wref: [3]f64) -> (x, y, z: f64) {
	//y = wref[1] * lab_finv((l + 0.16) / 1.16)
	if l <= 0.08 {
		y = wref[1] * l * 100.0 * 3.0 / 29.0 * 3.0 / 29.0 * 3.0 / 29.0
	} else {
		y = wref[1] * cub((l+0.16)/1.16)
	}
	un, vn := xyz_to_uv(wref[0], wref[1], wref[2])
	if l != 0.0 {
		ubis := u/(13.0*l) + un
		vbis := v/(13.0*l) + vn
		x = y * 9.0 * ubis / (4.0 * vbis)
		z = y * (12.0 - 3.0*ubis - 20.0*vbis) / (4.0 * vbis)
	} else {
		x, y = 0.0, 0.0
	}
	return
}
