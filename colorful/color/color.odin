// ported from golang standard lib
// Package color implements a basic color library.
package color

// Color can convert itself to alpha-premultiplied 16-bits per channel RGBA.
// The conversion may be lossy.

Color_List :: union {
   ^RGBA,
   ^RGBA64,
   ^NRGBA,
   ^NRGBA64,
   ^Alpha,
   ^Alpha16,
   ^Gray,
   ^Gray16,
}

Color :: struct {
	derived: Color_List,
}

new_color :: proc($T: typeid) -> ^Color {
	c := new(Color)
	c.derived = T{color = c}
	return c	
}

get_color :: proc(c: ^Color) -> (r, g, b, a: u32) {
	switch color in c.derived {
	case ^RGBA:
		r, g, b, a = get_rgba(color)
	case ^RGBA64:
		r, g, b, a = get_rgba64(color)
	case ^NRGBA:
		r, g, b, a = get_nrgba(color)
	case ^NRGBA64:
		r, g, b, a = get_nrgba64(color)
	case ^Alpha:
		r, g, b, a = get_alpha(color)
	case ^Alpha16:
		r, g, b, a = get_alpha16(color)
	case ^Gray:
		r, g, b, a = get_gray(color)
	case ^Gray16:
		r, g, b, a = get_gray16(color)
	}
	return
}
	
// RGBA returns the alpha-premultiplied red, green, blue and alpha values
// for the color. Each value ranges within [0, 0xffff], but is represented
// by a u32 so that multiplying by a blend factor up to 0xffff will not
// overflow.
//
// An alpha-premultiplied color component c has been scaled by alpha (a),
// so has valid values 0 <= c <= a.

// RGBA represents a traditional 32-bit alpha-premultiplied color, having 8
// bits for each of red, green, blue and alpha.
//
// An alpha-premultiplied color component C has been scaled by alpha (A), so
// has valid values 0 <= C <= A.

RGBA :: struct {
	using color: ^Color,
	r, g, b, a: u8,
}

new_rgba :: proc(r, g, b, a: u8) -> (rgba: ^RGBA) {
	color := new(Color)
	rgba = new(RGBA)
	rgba.color = color
	rgba.r = r
	rgba.g = g
	rgba.b = b
	rgba.a = a
	color.derived = rgba
	return	
}

get_rgba :: proc(c: ^RGBA) -> (r, g, b, a: u32) {
	r = u32(c.r)
	r |= r << 8
	g = u32(c.g)
	g |= g << 8
	b = u32(c.b)
	b |= b << 8
	a = u32(c.a)
	a |= a << 8
	return
}

// RGBA64 represents a 64-bit alpha-premultiplied color, having 16 bits for
// each of red, green, blue and alpha.
//
// An alpha-premultiplied color component C has been scaled by alpha (A), so
// has valid values 0 <= C <= A.
RGBA64 :: struct {
	using color: ^Color,
	r, g, b, a: u16,
}

new_rgba64 :: proc(r, g, b, a: u16) -> (rgba64: ^RGBA64) {
	color := new(Color)
	rgba64 = new(RGBA64)
	rgba64.r = r
	rgba64.g = g
	rgba64.b = b
	rgba64.a = a
	color.derived = rgba64
	return	
}

get_rgba64 :: proc(c: ^RGBA64) -> (r, g, b, a: u32) {
	return u32(c.r), u32(c.g), u32(c.b), u32(c.a)
}

// NRGBA represents a non-alpha-premultiplied 32-bit color.
NRGBA :: struct {
	using color: ^Color,
	r, g, b, a: u8,
}

new_nrgba :: proc(r, g, b, a: u8) -> (nrgba: ^NRGBA) {
	color := new(Color)
	nrgba = new(NRGBA)
	nrgba.r = r
	nrgba.g = g
	nrgba.b = b
	nrgba.a = a
	color.derived = nrgba
	return	
}
	
get_nrgba :: proc(c: ^NRGBA) -> (r, g, b, a: u32) {
	r = u32(c.r)
	r |= r << 8
	r *= u32(c.a)
	r /= 0xff
	g = u32(c.g)
	g |= g << 8
	g *= u32(c.a)
	g /= 0xff
	b = u32(c.b)
	b |= b << 8
	b *= u32(c.a)
	b /= 0xff
	a = u32(c.a)
	a |= a << 8
	return
}

// NRGBA64 represents a non-alpha-premultiplied 64-bit color,
// having 16 bits for each of red, green, blue and alpha.
NRGBA64 :: struct {
	using color: ^Color,
	r, g, b, a: u16,
}

new_nrgba64 :: proc(r, g, b, a: u16) -> (nrgba64: ^NRGBA64) {
	color := new(Color)
	nrgba64 = new(NRGBA64)
	nrgba64.r = r
	nrgba64.g = g
	nrgba64.b = b
	nrgba64.a = a
	color.derived = nrgba64
	return	
}
	
get_nrgba64 :: proc(c: ^NRGBA64) -> (r, g, b, a: u32) {
	r = u32(c.r)
	r *= u32(c.a)
	r /= 0xffff
	g = u32(c.g)
	g *= u32(c.a)
	g /= 0xffff
	b = u32(c.b)
	b *= u32(c.a)
	b /= 0xffff
	a = u32(c.a)
	return
}

// Alpha represents an 8-bit alpha color.
Alpha :: struct {
	using color: ^Color,
	a: u8,
}

new_alpha :: proc(a: u8) -> (alpha: ^Alpha) {
	color := new(Color)
	alpha = new(Alpha)
	alpha.a = a
	color.derived = alpha
	return	
}
	
get_alpha :: proc(c: ^Alpha) -> (r, g, b, a: u32) {
	a = u32(c.a)
	a |= a << 8
	return a, a, a, a
}

// Alpha16 represents a 16-bit alpha color.
Alpha16 :: struct {
	using color: ^Color,
	a: u16,
}

new_alpha16 :: proc(a: u16) -> (alpha16: ^Alpha16) {
	color := new(Color)
	alpha16 = new(Alpha16)
	alpha16.a = a
	color.derived = alpha16
	return	
}
	
get_alpha16 :: proc(c: ^Alpha16) -> (r, g, b, a: u32) {
	a = u32(c.a)
	return a, a, a, a
}

// Gray represents an 8-bit grayscale color.
Gray :: struct {
	using color: ^Color,
	y: u8,
}

new_gray :: proc(y: u8) -> (gray: ^Gray) {
	color := new(Color)
	gray = new(Gray)
	gray.y = y
	color.derived = gray
	return	
}
	
get_gray :: proc(c: ^Gray) -> (r, g, b, a: u32) {
	y := u32(c.y)
	y |= y << 8
	return y, y, y, 0xffff
}

// Gray16 represents a 16-bit grayscale color.
Gray16 :: struct {
	using color: ^Color,
	y: u16,
}

new_gray16 :: proc(y: u16) -> (gray16: ^Gray16) {
	color := new(Color)
	gray16 = new(Gray16)
	gray16.y = y
	color.derived = gray16
	return	
}
	
get_gray16 :: proc(c: ^Gray16) -> (r, g, b, a: u32) {
	y := u32(c.y)
	return y, y, y, 0xffff
}

// Model can convert any Color to one from its own color model. The conversion
// may be lossy.
//Model :: Struct {
//	Convert(c Color) Color
//}

convert :: proc {
	convert_model,
	convert_palette,
}

Model :: struct {
	f: proc(^Color) -> ^Color
}

// ModelFunc returns a Model that invokes f to implement the conversion.
model_func :: proc(f: proc(^Color) -> ^Color) -> Model {
	// Note: using *modelFunc as the implementation
	// means that callers can still use comparisons
	// like m == RGBAModel. This is not possible if
	// we use the func value directly, because funcs
	// are no longer comparable.
	return Model{f}
}

convert_model :: proc(m: ^Model, c: ^Color) -> ^Color {
	return m.f(c)
}

// Models for the standard color types.
RGBA_Model    := model_func(rgba_model)
RGBA64_Model  := model_func(rgba64_model)
NRGBA_Model   := model_func(nrgba_model)
NRGBA64_Model := model_func(nrgba64_model)
Alpha_Model   := model_func(alpha_model)
Alpha16_Model := model_func(alpha16_model)
Gray_Model    := model_func(gray_model)
Gray16_Model  := model_func(gray16_model)

rgba_model :: proc(c: ^Color) -> ^Color {
	if color, ok := c.derived.(^RGBA); ok {
		return color
	}
	r, g, b, a := get_color(c)
	return new_rgba(u8(r >> 8), u8(g >> 8), u8(b >> 8), u8(a >> 8))
}

rgba64_model :: proc(c: ^Color) -> ^Color {
	if color, ok := c.derived.(^RGBA64); ok {
		return color
	}
	r, g, b, a := get_color(c)
	return new_rgba64(u16(r), u16(g), u16(b), u16(a))
}

nrgba_model :: proc(c: ^Color) -> ^Color {
	if color, ok := c.derived.(^NRGBA); ok {
		return color
	}
	r, g, b, a := get_color(c)
	if a == 0xffff {
		return new_nrgba(u8(r >> 8), u8(g >> 8), u8(b >> 8), 0xff)
	}
	if a == 0 {
		return new_nrgba(0, 0, 0, 0)
	}
	// Since Color.RGBA returns an alpha-premultiplied color, we should have r <= a && g <= a && b <= a.
	r = (r * 0xffff) / a
	g = (g * 0xffff) / a
	b = (b * 0xffff) / a
	return new_nrgba(u8(r >> 8), u8(g >> 8), u8(b >> 8), u8(a >> 8))
}

nrgba64_model :: proc(c: ^Color) -> ^Color {
	if color, ok := c.derived.(^NRGBA64); ok {
		return color
	}
	r, g, b, a := get_color(c)
	if a == 0xffff {
		return new_nrgba64(u16(r), u16(g), u16(b), 0xffff)
	}
	if a == 0 {
		return new_nrgba64(0, 0, 0, 0)
	}
	// Since Color.RGBA returns an alpha-premultiplied color, we should have r <= a && g <= a && b <= a.
	r = (r * 0xffff) / a
	g = (g * 0xffff) / a
	b = (b * 0xffff) / a
	return new_nrgba64(u16(r), u16(g), u16(b), u16(a))
}

alpha_model :: proc(c: ^Color) -> ^Color {
	if color, ok := c.derived.(^Alpha); ok {
		return color
	}
	_, _, _, a := get_color(c)
	return new_alpha(u8(a >> 8))
}

alpha16_model :: proc(c: ^Color) -> ^Color {
	if color, ok := c.derived.(^Alpha16); ok {
		return color
	}
	_, _, _, a := get_color(c)
	return new_alpha16(u16(a))
}

gray_model :: proc(c: ^Color) -> ^Color {
	if color, ok := c.derived.(^Gray); ok {
		return color
	}
	r, g, b, _ := get_color(c)

	// These coefficients (the fractions 0.299, 0.587 and 0.114) are the same
	// as those given by the JFIF specification and used by RGBToYCbCr in
	// ycbcr.go.
	//
	// Note that 19595 + 38470 + 7471 equals 65536.
	//
	// The 24 is 16 + 8. The 16 is the same as used in RGBToYCbCr. The 8 is
	// because the return value is 8 bit color, not 16 bit color.
	y := (19595*r + 38470*g + 7471*b + 1<<15) >> 24

	return new_gray(u8(y))
}

gray16_model :: proc(c: ^Color) -> ^Color {
	if color, ok := c.derived.(^Gray16); ok {
		return color
	}
	r, g, b, _ := get_color(c)

	// These coefficients (the fractions 0.299, 0.587 and 0.114) are the same
	// as those given by the JFIF specification and used by RGBToYCbCr in
	// ycbcr.go.
	//
	// Note that 19595 + 38470 + 7471 equals 65536.
	y := (19595*r + 38470*g + 7471*b + 1<<15) >> 16

	return new_gray16(u16(y))
}

// Palette is a palette of colors.
Palette :: []^Color

// Convert returns the palette color closest to c in Euclidean R,G,B space.
convert_palette :: proc(p: Palette, c: ^Color) -> ^Color {
	if len(p) == 0 {
		return nil
	}
	return p[palette_index(p, c)]
}

// Index returns the index of the palette color closest to c in Euclidean
// R,G,B,A space.
palette_index :: proc(p: Palette, c: ^Color) -> int {
	// A batch version of this computation is in image/draw/draw.go.

	cr, cg, cb, ca := get_color(c)
	ret, best_sum := 0, u32(1<<32-1)
	for v, i in p {
		vr, vg, vb, va := get_color(v)
		sum := sq_diff(cr, vr) + sq_diff(cg, vg) + sq_diff(cb, vb) + sq_diff(ca, va)
		if sum < best_sum {
			if sum == 0 {
				return i
			}
			ret, best_sum = i, sum
		}
	}
	return ret
}

// sqDiff returns the squared-difference of x and y, shifted by 2 so that
// adding four of those won't overflow a u32.
//
// x and y are both assumed to be in the range [0, 0xffff].
sq_diff :: proc(x, y: u32) -> u32 {
	// The canonical code of this function looks as follows:
	//
	//	var d u32
	//	if x > y {
	//		d = x - y
	//	} else {
	//		d = y - x
	//	}
	//	return (d * d) >> 2
	//
	// Language spec guarantees the following properties of unsigned integer
	// values operations with respect to overflow/wrap around:
	//
	// > For unsigned integer values, the operations +, -, *, and << are
	// > computed modulo 2n, where n is the bit width of the unsigned
	// > integer's type. Loosely speaking, these unsigned integer operations
	// > discard high bits upon overflow, and programs may rely on ``wrap
	// > around''.
	//
	// Considering these properties and the fact that this function is
	// called in the hot paths (x,y loops), it is reduced to the below code
	// which is slightly faster. See TestSqDiff for correctness check.
	d := x - y
	return (d * d) >> 2
}

// Standard colors.
BLACK       := new_gray16(y=0)
WHITE       := new_gray16(y=0xffff)
TRANSPARENT := new_alpha16(a=0)
OPAQUE      := new_alpha16(a=0xffff)
