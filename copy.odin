package karvi

import "core:fmt"
import "core:strings"

import "osc52"

// Copy copies text to system clipboard using OSC 52 escape sequence.
output_copy :: proc(o: ^Output, str: string) {
	s := osc52.new_sequence(str)
	if strings.has_prefix(get_env("TERM"), "screen") {
		osc52.set_screen(s)
	}
	osc52.write_to(s, o.e)
}

// CopyPrimary copies text to primary clipboard (X11) using OSC 52 escape
// sequence.
output_copy_primary :: proc(o: ^Output, str: string) {
	s := osc52.new_sequence(str)
	osc52.set_primary(s)
	if strings.has_prefix(get_env("TERM"), "screen") {
		osc52.set_screen(s)
	}
	osc52.write_to(s, o.e)
}

// Copy copies text to system clipboard using OSC 52 escape sequence.
copy :: proc(str: string) {
	output_copy(output, str)
}

// CopyPrimary copies text to primary clipboard (X11) using OSC 52 escape
// sequence.
copy_primary :: proc(str: string) {
	output_copy_primary(output, str)
}
