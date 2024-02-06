package karvi

import "core:os"
import "core:unicode/utf8"
import "core:strings"

import sys "syscalls"

// TODO: Unify Error and Errno

Error :: enum {
	No_Error,
	Invalid_Color,
	Err_Status_Report = 2001,
}

Errno :: distinct i32

// Terminal escape codes:
// https://medium.com/israeli-tech-radar/terminal-escape-codes-are-awesome-heres-why-c8eb938b1a1c

// Escape character
ESC : string : "\e"
// Bell
BEL : string : "\a"
// Control Sequence Introducer
CSI : string : "\e["
// Operating System Command
OSC : string : "\e]"
// String Terminator: 
ST : string : "\e\\"

is_tty :: proc(o: ^Output) -> bool {
	if o.assume_tty || o.unsafe do return true
	if len(o.environ.get_env("CI")) > 0 do	return false
	fd := writer(o)
	if sys.is_atty(fd) == 1 do return true
	return false
}

// color_profile returns the supported color profile:
// Ascii, ANSI, ANSI256, or TrueColor.
color_profile :: proc() -> Profile {
	return output.profile
}

// ForegroundColor returns the terminal's default foreground color.
foreground_color :: proc() -> string {
	return output_fg_color(output).color
}

// BackgroundColor returns the terminal's default background color.
background_color :: proc() -> string {
	return output_bg_color(output).color
}

// has_dark_background returns whether terminal uses a dark-ish background.
has_dark_background :: proc() -> bool {
	return output_has_dark_bg(output)
}

// output_no_color returns true if the environment variables explicitly disable color output
// by setting NO_COLOR (https://no-color.org/)
// or CLICOLOR/CLICOLOR_FORCE (https://bixense.com/clicolors/)
// If NO_COLOR is set, this will return true, ignoring CLICOLOR/CLICOLOR_FORCE
// If CLICOLOR=="0", it will be true only if CLICOLOR_FORCE is also "0" or is unset.
output_env_no_color :: proc(o: ^Output) -> bool {
	return get_env(
		"NO_COLOR") != "" ||
		(get_env("CLICOLOR") == "0" &&
		!cli_color_forced(o)
	)
}

// env_no_color returns true if the environment variables explicitly disable color output
// by setting NO_COLOR (https://no-color.org/)
// or CLICOLOR/CLICOLOR_FORCE (https://bixense.com/clicolors/)
// If NO_COLOR is set, this will return true, ignoring CLICOLOR/CLICOLOR_FORCE
// If CLICOLOR=="0", it will be true only if CLICOLOR_FORCE is also "0" or is unset.
env_no_color :: proc() -> bool {
	return output_env_no_color(output)
}

// EnvColorProfile returns the color profile based on environment variables set
// Supports NO_COLOR (https://no-color.org/)
// and CLICOLOR/CLICOLOR_FORCE (https://bixense.com/clicolors/)
// If none of these environment variables are set, this behaves the same as ColorProfile()
// It will return the Ascii color profile if EnvNoColor() returns true
// If the terminal does not support any colors, but CLICOLOR_FORCE is set and not "0"
// then the ANSI color profile will be returned.
env_color_profile :: proc() -> Profile {
	return output_env_color_profile(output)
}

// EnvColorProfile returns the color profile based on environment variables set
// Supports NO_COLOR (https://no-color.org/)
// and CLICOLOR/CLICOLOR_FORCE (https://bixense.com/clicolors/)
// If none of these environment variables are set, this behaves the same as ColorProfile()
// It will return the Ascii color profile if EnvNoColor() returns true
// If the terminal does not support any colors, but CLICOLOR_FORCE is set and not "0"
// then the ANSI color profile will be returned.
output_env_color_profile :: proc(o: ^Output) -> Profile {
	using Profile
	if output_env_no_color(o) {
		return Ascii
	}
	p := output_color_profile(o)
	if cli_color_forced(o) && p == Ascii {
		return ANSI
	}
	return p
}

cli_color_forced :: proc(o: ^Output) -> bool {
	if forced := get_env("CLICOLOR_FORCE"); forced != "" {
		return forced != "0"
	}
	return false
}

