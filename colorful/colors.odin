package colorful

import "core:strings"
import "core:c/libc"
import "core:math"
import "core:fmt"

when ODIN_OS == .Windows do foreign import cbrt_c "cbrt.lib"
when ODIN_OS == .Linux   do foreign import cbrt_c "cbrt.a"

foreign cbrt_c {
	cbrt :: proc(x: f64) -> f64 ---
}

// A color is stored internally using sRGB (standard RGB) values in the range 0-1
Color :: struct {
	r, g, b: f64
}

// color_hex returns the hex "html" representation of the color, as in #ff0080.
color_hex :: proc(col: Color) -> string {
	// Add 0.5 for rounding
	return fmt.tprintf("#%02x%02x%02x", u8(col.r*255.0+0.5), u8(col.g*255.0+0.5), u8(col.b*255.0+0.5))
}

/// HSL ///
///////////

// Hsl returns the Hue [0..360], Saturation [0..1], and Luminance (lightness) [0..1] of the color.
hsl :: proc(col: Color) -> (h, s, l: f64) {
	min := math.min(math.min(col.r, col.g), col.b)
	max := math.max(math.max(col.r, col.g), col.b)

	l = (max + min) / 2

	if min == max {
		s = 0
		h = 0
	} else {
		if l < 0.5 {
			s = (max - min) / (max + min)
		} else {
			s = (max - min) / (2.0 - max - min)
		}

		if max == col.r {
			h = (col.g - col.b) / (max - min)
		} else if max == col.g {
			h = 2.0 + (col.b-col.r)/(max-min)
		} else {
			h = 4.0 + (col.r-col.g)/(max-min)
		}

		h *= 60

		if h < 0 {
			h += 360
		}
	}

	return
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

sq :: proc(v: f64) -> f64 {
	return v * v
}

// clamp01 clamps from 0 to 1.
clamp01 :: proc(v: f64) -> f64 {
	return math.max(0.0, math.min(v, 1.0))
}

// Returns Clamps the color into valid range, clamping each value to [0..1]
// If the color is valid already, this is a no-op.
clamped :: proc(c: Color) -> Color {
	return Color{clamp01(c.r), clamp01(c.g), clamp01(c.b)}
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

/// Linear ///
//////////////
// http://www.sjbrown.co.uk/2004/05/14/gamma-correct-rendering/
// http://www.brucelindbloom.com/Eqn_RGB_to_XYZ.html
linearize :: proc(v: f64) -> f64 {
	if v <= 0.04045 {
		return v / 12.92
	}
	return math.pow((v+0.055)/1.055, 2.4)
}

// LinearRgb converts the color into the linear RGB space (see http://www.sjbrown.co.uk/2004/05/14/gamma-correct-rendering/).
color_linear_rgb :: proc(col: Color) -> (r, g, b: f64) {
	r = linearize(col.r)
	g = linearize(col.g)
	b = linearize(col.b)
	return
}

linear_rgb_to_xyz :: proc(r, g, b: f64) -> (x, y, z: f64) {
	x = 0.41239079926595948*r + 0.35758433938387796*g + 0.18048078840183429*b
	y = 0.21263900587151036*r + 0.71516867876775593*g + 0.072192315360733715*b
	z = 0.019330818715591851*r + 0.11919477979462599*g + 0.95053215224966058*b
	return
}

/// XYZ ///
///////////
// http://www.sjbrown.co.uk/2004/05/14/gamma-correct-rendering/
xyz :: proc(col: Color) -> (x, y, z: f64) {
	return linear_rgb_to_xyz(color_linear_rgb(col))
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

/// L*u*v* ///
//////////////
// http://en.wikipedia.org/wiki/CIELUV#XYZ_.E2.86.92_CIELUV_and_CIELUV_.E2.86.92_XYZ_conversions
// For L*u*v*, we need to L*u*v*<->XYZ<->RGB and the first one is device dependent.
xyz_to_luv_white_ref :: proc(x, y, z: f64, wref: [3]f64) -> (l, u, v: f64) {
	if y/wref[1] <= 6.0/29.0*6.0/29.0*6.0/29.0 {
		l = y / wref[1] * (29.0 / 3.0 * 29.0 / 3.0 * 29.0 / 3.0) / 100.0
	} else {
		l = 1.16*cbrt(y/wref[1]) - 0.16
	}
	ubis, vbis := xyz_to_uv(x, y, z)
	un, vn := xyz_to_uv(wref[0], wref[1], wref[2])
	u = 13.0 * l * (ubis - un)
	v = 13.0 * l * (vbis - vn)
	return
}

luv_to_luvlch :: proc(L, u, v: f64) -> (l, c, h: f64) {
	// Oops, floating point workaround necessary if u ~= v and both are very small (i.e. almost zero).
	if math.abs(v-u) > 1e-4 && math.abs(u) > 1e-4 {
		h = math.mod(57.29577951308232087721*math.atan2(v, u)+360.0, 360.0) // Rad2Deg
	} else {
		h = 0.0
	}
	l = L
	c = math.sqrt(sq(u) + sq(v))
	return
}

// Converts the given color to CIE L*u*v* space, taking into account
// a given reference white. (i.e. the monitor's white)
// L* is in [0..1] and both u* and v* are in about [-1..1]
luv_white_ref :: proc(col: Color, wref: [3]f64) -> (l, u, v: f64) {
	x, y, z := xyz(col)
	return xyz_to_luv_white_ref(x, y, z, wref)
}

// Converts the given color to LuvLCh space, taking into account
// a given reference white. (i.e. the monitor's white)
// h values are in [0..360], c and l values are in [0..1]
luvlch_white_ref :: proc(col: Color, wref: [3]f64) -> (l, c, h: f64) {
	return luv_to_luvlch(luv_white_ref(col, wref))
}
