package karvi

import "core:strings"
import "core:strconv"

import "colorful"
import "colorful/color"

// Profile is a color profile: Ascii, ANSI, ANSI256, or TrueColor.
Profile :: int

Color_Profile :: enum {
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
		string =  strings.join(s, " "),
	}
}

// Convert transforms a given Color to a Color supported within the Profile.
profile_convert :: proc(p: Profile, c: Color) -> Color {
	if p == .Ascii {
		return No_Color{}
	}

	switch v in c.type {
	case ANSI:
		return v

	case ANSI256:
		if p == ANSI {
			return ansi256_to_ansi(v)
		}
		return v

	case RGB:
		h, err := colorful.Hex(string(v))
		if err != nil {
			return nil
		}
		if p != True_Color {
			ac := hex_to_ansi256(h)
			if p == ANSI {
				return ansi256_to_ansi(ac)
			}
			return ac
		}
		return v
	}

	return c
}

// Color creates a Color from a string. Valid inputs are hex colors, as well as
// ANSI color codes (0-15, 16-255).
profile_color :: proc(p: Profile, s: string) -> Color {
	if len(s) == 0 {
		return nil
	}

	c: Color
	if strings.has_prefix(s, "#") {
		c = RGB(s)
	} else {
		i, err := strconv.atoi(s)
		if err != nil {
			return nil
		}

		if i < 16 {
			c = ANSI(i)
		} else {
			c = ANSI256(i)
		}
	}

	return profile_convert(p, c)
}

// FromColor creates a Color from a color.Color.
profile_from_color :: proc(p: Profile, c: color.Color) -> Color {
	col, _ := colorful.make_color(c)
	return p.Color(col.Hex())
}
