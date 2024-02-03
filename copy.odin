package karvi

import "core:strings"

import "osc52"

// Copy copies text to clipboard using OSC 52 escape sequence.
output_copy :: proc(o: ^Output, str: string) {
	s := osc52.new_sequence(str)
	if strings.has_prefix(getenv("TERM"), "screen") {
		osc52.set_screen(s)
	}
	// TODO: Fix later
	//osc52.write_to(s, o)
}

// CopyPrimary copies text to primary clipboard (X11) using OSC 52 escape
// sequence.
output_copy_primary :: proc(o: ^Output, str: string) {
	s := osc52.new_sequence(str)
	osc52.set_primary(s)
	if strings.has_prefix(getenv("TERM"), "screen") {
		osc52.set_screen(s)
	}
	// TODO: Fix later
	//osc52.write_to(s, o)
}

// Copy copies text to clipboard using OSC 52 escape sequence.
copy :: proc(str: string) {
	output_copy(output, str)
}

// CopyPrimary copies text to primary clipboard (X11) using OSC 52 escape
// sequence.
copy_primary :: proc(str: string) {
	output_copy_primary(output, str)
}
