package colorful

import "core:math"

hsluv_d65 := [3]f64{0.95045592705167, 1.0, 1.089057750759878}

m := [3][3]f64{
	{3.2409699419045214, -1.5373831775700935, -0.49861076029300328},
	{-0.96924363628087983, 1.8759675015077207, 0.041555057407175613},
	{0.055630079696993609, -0.20397695888897657, 1.0569715142428786},
}

KAPPA :: 903.2962962962963
EPSILON :: 0.0088564516790356308

luvlch_to_hsluv :: proc(l, c, h: f64) -> (f64, f64, f64) {
	// [-1..1] but the code expects it to be [-100..100]
	cc := c * 100.0
	ll := l * 100.0

	s := math.F64_MAX
	if ll > 99.9999999 || ll < 0.00000001 {
		s = 0.0
	} else {
		max := max_chroma_for_lh(ll, h)
		s = cc / max * 100.0
	}
	return h, clamp01(s / 100.0), clamp01(ll / 100.0)
}

max_chroma_for_lh :: proc(l, h: f64) -> f64 {
	h_rad := h / 360.0 * math.PI * 2.0
	min_length := math.F64_MAX
	for line in get_bounds(l) {
		length := length_of_ray_until_intersect(h_rad, line[0], line[1])
		if length > 0.0 && length < min_length {
			min_length = length
		}
	}
	return min_length
}

get_bounds :: proc(l: f64) -> [6][2]f64 {
	sub2: f64
	ret: [6][2]f64
	sub1 := math.pow(l+16.0, 3.0) / 1560896.0
	if sub1 > EPSILON {
		sub2 = sub1
	} else {
		sub2 = l / KAPPA
	}
	for _, i in m {
		for k := 0; k < 2; k += 1 {
			top1 := (284517.0*m[i][0] - 94839.0*m[i][2]) * sub2
			top2 := (838422.0*m[i][2]+769860.0*m[i][1]+731718.0*m[i][0])*l*sub2 - 769860.0*f64(k)*l
			bottom := (632260.0*m[i][2]-126452.0*m[i][1])*sub2 + 126452.0*f64(k)
			ret[i*2+k][0] = top1 / bottom
			ret[i*2+k][1] = top2 / bottom
		}
	}
	return ret
}

length_of_ray_until_intersect :: proc(theta, x, y: f64) -> (length: f64) {
	length = y / (math.sin(theta) - x*math.cos(theta))
	return
}

hsluv_to_luvlch :: proc(h, s, l: f64) -> (f64, f64, f64) {
	ll := l * 100.0
	ss := s * 100.0

	c, max: f64
	if ll > 99.9999999 || ll < 0.00000001 {
		c = 0.0
	} else {
		max = max_chroma_for_lh(ll, h)
		c = max / 100.0 * ss
	}

	// c is [-100..100], but for LCh it's supposed to be almost [-1..1]
	return clamp01(ll / 100.0), c / 100.0, h
}


// HSLuv creates a new Color from values in the HSLuv color space.
// Hue in [0..360], a Saturation [0..1], and a Luminance (lightness) in [0..1].
//
// The returned color values are clamped (using .Clamped), so this will never output
// an invalid color.
hsluv :: proc(h, s, l: f64) -> Color {
	// HSLuv -> LuvLCh -> CIELUV -> CIEXYZ -> Linear RGB -> sRGB
	l, u, v := luvlch_to_luv(hsluv_to_luvlch(h, s, l))
	return clamped(linear_rgb(xyz_to_linear_rgb(luv_to_xyz_white_ref(l, u, v, hsluv_d65))))
}

// HSLuv returns the Hue, Saturation and Luminance of the color in the HSLuv
// color space. Hue in [0..360], a Saturation [0..1], and a Luminance
// (lightness) in [0..1].
color_hsluv :: proc(col: Color) -> (h, s, l: f64) {
	// sRGB -> Linear RGB -> CIEXYZ -> CIELUV -> LuvLCh -> HSLuv
	return luvlch_to_hsluv(luvlch_white_ref(col, hsluv_d65))
}

// DistanceHSLuv calculates Euclidan distance in the HSLuv colorspace. 
// The Hue value is divided by 100 before the calculation, so that H, S, and L
// have the same relative ranges.
distance_hsluv :: proc(c1: Color, c2: Color) -> f64 {
	h1, s1, l1 := color_hsluv(c1)
	h2, s2, l2 := color_hsluv(c2)
	return math.sqrt(sq((h1-h2)/100.0) + sq(s1-s2) + sq(l1-l2))
}
