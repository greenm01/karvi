package karvi

import "core:strings"
import "core:strconv"

import "colorful"

Profile :: enum {
	Undefined,
	// TrueColor, 24-bit color profile
	True_Color,
	// ANSI256, 8-bit color profile
	ANSI256,
	// ANSI, 4-bit color profile
	ANSI,
	// Ascii, uncolored profile
	Ascii,
}

// String returns a new Style.
profile_string :: proc(p: Profile, s: ..string) -> Style {
	return Style{
		profile = p,
		str = strings.join(s, " "),
	}
}

// Convert transforms a given Color to a Color supported within the Profile.
profile_convert :: proc(p: Profile, c: ^Color) -> ^Color {
	using Profile
	if p == Ascii do return No_Color{}

	switch v in c.type {
	case ANSI_Color:
		return v
	case ANSI256_Color:
		if p == ANSI do	return ansi256_to_ansi(v)
		return v
	case RGB_Color:
		h, err := colorful.hex(v.c)
		if err != 0 do return nil
		if p != True_Color {
			ac := hex_to_ansi256(h)
			if p == ANSI do	return ansi256_to_ansi(ac.type.(ANSI256_Color))
			return ac
		}
		return v
	case No_Color:
	}

	return c
}

// Color creates a Color from a string. Valid inputs are hex colors, as well as
// ANSI color codes (0-15, 16-255).
profile_color :: proc(p: Profile, s: string) -> ^Color {
	if len(s) == 0 do return new(Color)

	c: ^Color
	if strings.has_prefix(s, "#") {
		c = new_rgb_color(s)
	} else {
		i := strconv.atoi(s)
		if i < 16 {
			c = new_ansi_color(i)
		} else {
			c = new_ansi256_color(i)
		}
	}

	return profile_convert(p, c)
}
