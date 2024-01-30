package karvi

import "core:os"
import "core:fmt"
/*
import (
	"errors"
	"os"

	"github.com/mattn/go-isatty"
)
*/

Error :: enum {
	No_Error,
	Invalid_Color,
	Err_Status_Report,
}

// Escape character
ESC :: '\x1b'
// Bell
BEL :: '\a'
// Control Sequence Introducer
CSI :: fmt.tprintf("%v%s", ESC, "[")
// Operating System Command
OSC :: fmt.tprintf("%v%s", ESC, "]")
// String Terminator
ST  :: fmt.tprintf("%v%v", ESC, `\`)

is_tty :: proc(o: ^Output) -> bool {
	if o.assume_tty || o.unsafe do return true
	if len(get_env(o.environ, "CI")) > 0 do	return false
	if f, ok := o.Writer().(*os.File); ok {
		return true //isatty.IsTerminal(f.Fd())
	}
	return false
}

// ColorProfile returns the supported color profile:
// Ascii, ANSI, ANSI256, or TrueColor.
color_profile :: proc() -> Profile {
	return output_color_profile(output)
}

// ForegroundColor returns the terminal's default foreground color.
foreground_color :: proc() -> Color {
	return output_foreground_color(output)
}

// BackgroundColor returns the terminal's default background color.
background_color :: proc() -> Color {
	return output_background_color(output)
}

// has_dark_background returns whether terminal uses a dark-ish background.
has_dark_background :: proc() -> bool {
	return output_has_dark_background(output)
}

// EnvNoColor returns true if the environment variables explicitly disable color output
// by setting NO_COLOR (https://no-color.org/)
// or CLICOLOR/CLICOLOR_FORCE (https://bixense.com/clicolors/)
// If NO_COLOR is set, this will return true, ignoring CLICOLOR/CLICOLOR_FORCE
// If CLICOLOR=="0", it will be true only if CLICOLOR_FORCE is also "0" or is unset.
env_no_color :: proc(o: ^Output) -> bool {
	return get_env(o.environ, "NO_COLOR") != "" || (get_env(o.environ, "CLICOLOR") == "0" && !cli_color_forced(o))
}

// EnvNoColor returns true if the environment variables explicitly disable color output
// by setting NO_COLOR (https://no-color.org/)
// or CLICOLOR/CLICOLOR_FORCE (https://bixense.com/clicolors/)
// If NO_COLOR is set, this will return true, ignoring CLICOLOR/CLICOLOR_FORCE
// If CLICOLOR=="0", it will be true only if CLICOLOR_FORCE is also "0" or is unset.
env_no_color :: proc() -> bool {
	return env_no_color(output.)
}

// EnvColorProfile returns the color profile based on environment variables set
// Supports NO_COLOR (https://no-color.org/)
// and CLICOLOR/CLICOLOR_FORCE (https://bixense.com/clicolors/)
// If none of these environment variables are set, this behaves the same as ColorProfile()
// It will return the Ascii color profile if EnvNoColor() returns true
// If the terminal does not support any colors, but CLICOLOR_FORCE is set and not "0"
// then the ANSI color profile will be returned.
env_color_profile :: proc() -> Profile {
	return env_color_profile(output)
}

// EnvColorProfile returns the color profile based on environment variables set
// Supports NO_COLOR (https://no-color.org/)
// and CLICOLOR/CLICOLOR_FORCE (https://bixense.com/clicolors/)
// If none of these environment variables are set, this behaves the same as ColorProfile()
// It will return the Ascii color profile if EnvNoColor() returns true
// If the terminal does not support any colors, but CLICOLOR_FORCE is set and not "0"
// then the ANSI color profile will be returned.
env_color_profile :: proc(o: ^Output) -> Profile {
	using Profile
	if env_no_color(o) {
		return Ascii
	}
	p := color_profile(o)
	if cli_color_forced(o) && p == Ascii {
		return ANSI
	}
	return p
}

cli_color_forced :: proc(o: ^Output) -> bool {
	if forced := get_env(o.environ, "CLICOLOR_FORCE"); forced != "" {
		return forced != "0"
	}
	return false
}
