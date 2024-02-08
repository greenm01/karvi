package karvi

import "core:io"
import "core:os"
import "core:sync"
import "core:unicode/utf8"
import "core:strings"

import sys "syscalls"
import "colorful"

// output is the default global output.
output := new_output(os.stdout)

// Output is a terminal output.
Output :: struct {
	profile:    Profile,
	w:          os.Handle,  // writer
	assume_tty: bool,
	unsafe:     bool,
	cache:      bool,
	fg_sync:    sync.Once,
	fg_color:   ^Color,
	bg_sync:    sync.Once,
	bg_color:   ^Color,
}

// new_output returns a new Output for the given writer.
new_output :: proc(w: os.Handle) -> (o: ^Output) {
	using Profile
	o = new(Output)
	o.w          = w
	o.profile    = output_env_color_profile(o)      
	o.fg_color   = new_no_color()
	o.bg_color   = new_no_color()
	o.unsafe     = false
	return
}

environ :: proc() -> []string {
	return sys.get_env_slice2()
}

get_env :: proc(key: string) -> string {
	return string(sys.get_env(strings.clone_to_cstring(key)))
}

// DefaultOutput returns the default global output.
default_output :: proc() -> ^Output {
	return output
}

// SetDefaultOutput sets the default global output.
set_default_output :: proc(o: ^Output) {
	output = o
}

// ForegroundColor returns the terminal's default foreground color.
output_fg_color :: proc(o: ^Output) -> ^Color {
	f :: proc(output: rawptr) {
		o: ^Output = auto_cast output
		if !is_tty(o) {
			return 
		}

		o.fg_color = fg_color(o)
	}

	if o.cache {
		sync.once_do_with_data(&o.fg_sync, f, o)	
	} else {
		f(o)
	}

	return o.fg_color

}

// BackgroundColor returns the terminal's default background color.
output_bg_color :: proc(o: ^Output) -> ^Color {
	f :: proc(output: rawptr) {
		o: ^Output = auto_cast output
		if !is_tty(o) {
			return
		}

		o.bg_color = bg_color(o)
	}

	if o.cache {
		sync.once_do_with_data(&o.bg_sync, f, o)
	} else {
		f(o)
	}

	return o.bg_color
}

// HasDarkBackground returns whether terminal uses a dark-ish background.
output_has_dark_bg :: proc(o: ^Output) -> bool {
	c := convert_to_hex(output_bg_color(o))
	_, _, l := colorful.hsl(c)
	return l < 0.5
}

// Writer returns the underlying writer. This may be of type io.Writer,
// io.ReadWriter, or ^os.File.
writer :: proc(o: ^Output) -> os.Handle {
	return o.w
}

write :: proc(o: ^Output, r: []u8) -> (int, os.Errno) {
	return os.write(o.w, r)
}

// WriteString writes the given string to the output.
write_string :: proc(o: ^Output, s: string) -> (int, os.Errno) {
	return os.write_string(o.w, s)
}
