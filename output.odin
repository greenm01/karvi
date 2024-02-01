package karvi

import "core:io"
import "core:os"
import "core:sync"
import "core:unicode/utf8"

import sys "syscalls"
import "colorful"

// output is the default global output.
output := new_output(os.stdout)

// Output_Option sets an option on Output.
Output_Option :: proc(^Output)

// Output is a terminal output.
Output :: struct {
	profile: Profile,
	w:       os.Handle,
	environ: Environ,

	assume_tty: bool,
	unsafe:     bool,
	cache:      bool,
	fg_sync:    sync.Once,
	fg_color:   ^Color,
	bg_sync:    sync.Once,
	bg_color:   ^Color,
}

// Environ is an interface for getting environment variables.
Environ :: struct {
	environ: proc() -> []string,
	get_env: proc(string) -> string,
}

new_environ :: proc() -> Environ {
	return Environ{environ, getenv}
}

environ :: proc() -> []string {
	return sys.get_env_slice2()
}

getenv :: proc(key: string) -> string {
	return sys.get_env(key)
}

// DefaultOutput returns the default global output.
default_output :: proc() -> ^Output {
	return output
}

// SetDefaultOutput sets the default global output.
set_default_output :: proc(o: ^Output) {
	output = o
}

// new_output returns a new Output for the given writer.
new_output :: proc(w: os.Handle, opts: ..Output_Option) -> ^Output {
	using Profile
	o := new(Output)
	o.w        = w
	o.environ  = new_environ()
	o.profile  = Undefined      
	o.fg_color = new_no_color()
	o.bg_color = new_no_color()

	for opt in opts {
		opt(o)
	}
	if o.profile == Undefined {
		o.profile = output_env_color_profile(o)
	}

	return o
}

/*
// WithEnvironment returns a new Output_Option for the given environment.
with_environment :: proc(environ: Environ) -> Output_Option {
	return proc(o: ^Output) {
		o.environ = environ
	}
}

// WithProfile returns a new Output_Option for the given profile.
with_profile :: proc(profile: Profile) -> Output_Option {
	return proc(o: ^Output) {
		o.profile = profile
	}
}

// WithColorCache returns a new Output_Option with fore- and background color values
// pre-fetched and cached.
with_color_cache :: proc(v: bool) -> Output_Option {
	return proc(o: ^Output) {
		o.cache = v

		// cache the values now
		_ = foreground_color(o)
		_ = background_color(o)
	}
}

// WithTTY returns a new Output_Option to assume whether or not the output is a TTY.
// This is useful when mocking console output.
with_tty :: proc(v: bool) -> Output_Option {
	return proc(o: ^Output) {
		o.assume_tty = v
	}
}
*/
// WithUnsafe returns a new Output_Option with unsafe mode enabled. Unsafe mode doesn't
// check whether or not the terminal is a TTY.
//
// This option supersedes WithTTY.
//
// This is useful when mocking console output and enforcing ANSI escape output
// e.g. on SSH sessions.
with_unsafe :: proc() -> Output_Option {
	return proc(o: ^Output) {
		o.unsafe = true
	}
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
	c := convert_to_rgb(output_bg_color(o))
	_, _, l := colorful.hsl(c)
	return l < 0.5
}

/*
// TTY returns the terminal's file descriptor. This may be nil if the output is
// not a terminal.
//
// Deprecated: Use Writer() instead.
tty :: proc(o: Output) -> File {
	if f, ok := o.w.(File); ok {
		return f
	}
	return nil
}
*/

// Writer returns the underlying writer. This may be of type io.Writer,
// io.ReadWriter, or ^os.File.
writer :: proc(o: ^Output) -> os.Handle {
	return o.w
}

write :: proc(o: ^Output, r: []rune) -> (int, Error) {
   return 0, .No_Error
	//return write(o.w, r)
}

// WriteString writes the given string to the output.
write_string :: proc(o: ^Output, s: string) -> (int, Error) {
	return write(o, utf8.string_to_runes(s))
}
