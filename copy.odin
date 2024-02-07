package karvi

import "core:fmt"
import "core:strings"
import "core:os"

import "osc52"

stderr: os.Handle = os.stderr

// Copy copies text to system clipboard using OSC 52 escape sequence.
output_copy :: proc(fd := stderr, str: string) {
	s := osc52.new_sequence(str)
	if strings.has_prefix(get_env("TERM"), "screen") {
		osc52.set_screen(s)
	}
	osc52.write_to(s, fd)
}

// CopyPrimary copies text to primary clipboard (X11) using OSC 52 escape
// sequence.
output_copy_primary :: proc(fd := stderr, str: string) {
	s := osc52.new_sequence(str)
	osc52.set_primary(s)
	if strings.has_prefix(get_env("TERM"), "screen") {
		osc52.set_screen(s)
	}
	osc52.write_to(s, fd)
}

// Copy copies text to system clipboard using OSC 52 escape sequence.
copy :: proc(str: string) {
	output_copy(str = str)
}

// CopyPrimary copies text to primary clipboard (X11) using OSC 52 escape
// sequence.
copy_primary :: proc(str: string) {
	output_copy_primary(str = str)
}
