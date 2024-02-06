// OSC52 is a terminal escape sequence that allows copying text to the clipboard.
//
// The sequence consists of the following:
//
//	OSC 52 ; Pc ; Pd BEL
//
// Pc is the clipboard choice:
//
//	c: clipboard
//	p: primary
//	q: secondary (not supported)
//	s: select (not supported)
//	0-7: cut-buffers (not supported)
//
// Pd is the data to copy to the clipboard. This string should be encoded in
// base64 (RFC-4648).
//
// If Pd is "?", the terminal replies to the host with the current contents of
// the clipboard.
//
// If Pd is neither a base64 string nor "?", the terminal clears the clipboard.
//
// See https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Operating-System-Commands
// where Ps = 52 => Manipulate Selection Data.
//
// Examples:
//
//	// copy "hello world" to the system clipboard
//  seq := osc52.new_sequence("hello world")
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
//
//	// copy "hello world" to the primary Clipboard
//	seq := osc52.new_sequence("hello world")
//	osc52.set_primary(seq)
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
//
//	// limit the size of the string to copy 10 bytes
//	seq := osc52.new_sequence("0123456789")
//	osc52.set_limit(seq, 10)
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
//
//	// escape the OSC52 sequence for screen using DCS sequences
//	seq := osc52.new_sequence("hello world")
//	osc52.set_screen(seq)
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
//
//	// escape the OSC52 sequence for Tmux
//	seq := osc52.new_sequence("hello world")
//	osc52.set_tmux(seq)
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
//
//	// query the system Clipboard
//	seq := osc52.new_query()
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
//
//	// query the primary clipboard
//	seq := osc52.new_query()
//  osc52.set_primary(seq)
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
//
//	// clear the system Clipboard
//	seq := osc52.new_clear()
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
//
//	// clear the primary Clipboard
//	seq := osc52.new_clear()
//  osc52.set_primary(seq)
//	fmt.fprintf(os.stderr, osc52.get_string(seq))
package osc52

import "core:encoding/base64"
import "core:fmt"
import "core:bufio"
import "core:os"
import "core:strings"

// Clipboard is the clipboard buffer to use.
Clipboard :: rune

// System_Clipboard is the system clipboard buffer.
System_Clipboard: Clipboard = 'c'
// Primary_Clipboard is the primary clipboard buffer (X11).
Primary_Clipboard: Clipboard = 'p'

// Mode is the mode to use for the OSC52 sequence.
Mode :: enum {
	// Default_Mode is the default OSC52 sequence mode.
	Default_Mode, 
	// Screen_Mode escapes the OSC52 sequence for screen using DCS sequences.
	Screen_Mode,
	// Tmux_Mode escapes the OSC52 sequence for tmux. Not needed if tmux
	// clipboard is set to `set-clipboard on`
	Tmux_Mode,
}

// Operation is the OSC52 operation.
Operation :: enum {
	// Set_Operation is the copy operation.
	Set_Operation,
	// Query_Operation is the query operation.
	Query_Operation,
	// Clear_Operation is the clear operation.
	Clear_Operation,
}

// Sequence is the OSC52 sequence.
Sequence :: struct {
	str:       string,
	limit:     int,
	op:        Operation,
	mode:      Mode,
	clipboard: Clipboard,
}

// String returns the OSC52 sequence.
get_string :: proc(s: ^Sequence) -> string {
	using Mode
	using Operation
	
	seq: strings.Builder
	// mode escape sequences start
	strings.write_string(&seq, seq_start(s))
	// actual OSC52 sequence start
	strings.write_string(&seq, fmt.tprintf("\x1b]52;%c;", s.clipboard))
	switch s.op {
	case Set_Operation:
		str := s.str
		if s.limit > 0 && len(str) > s.limit {
			return ""
		}
		b64 := base64.encode(transmute([]u8)str)
		#partial switch s.mode {
		case Screen_Mode:
			// Screen doesn't support OSC52 but will pass the contents of a DCS
			// sequence to the outer terminal unchanged.
			//
			// Here, we split the encoded string into 76 bytes chunks and then
			// join the chunks with <end-dsc><start-dsc> sequences. Finally,
			// wrap the whole thing in
			// <start-dsc><start-osc52><joined-chunks><end-osc52><end-dsc>.
			// s := strings.SplitN(b64, "", 76)
			s := make([dynamic]string)
			defer delete(s)
			for i := 0; i < len(b64); i += 76 {
				end := i + 76
				if end > len(b64) {
					end = len(b64)
				}
				append(&s, b64[i:end])
			}
			strings.write_string(&seq, strings.join(s[:], "\x1b\\\x1bP"))
		case:
			strings.write_string(&seq, b64)
		}
	case Query_Operation:
		// OSC52 queries the clipboard using "?"
		strings.write_string(&seq, "?")
	case Clear_Operation:
		// OSC52 clears the clipboard if the data is neither a base64 string nor "?"
		// we're using "!" as a default
		strings.write_string(&seq, "!")
	}
	// actual OSC52 sequence end
	strings.write_string(&seq, "\x07")
	// mode escape end
	strings.write_string(&seq, seq_end(s))
	return strings.to_string(seq)
}

// WriteTo writes the OSC52 sequence to the system hangle.
write_to :: proc(s: ^Sequence, h: os.Handle) -> (int, os.Errno) {
	n, err := os.write_string(h, get_string(s))
	return n, err
}

// mode sets the mode for the OSC52 sequence.
set_mode :: proc(s: ^Sequence, m: Mode) {
	s.mode = m
}

// Tmux sets the mode to Tmux_Mode.
// Used to escape the OSC52 sequence for `tmux`.
//
// Note: this is not needed if tmux clipboard is set to `set-clipboard on`. If
// Tmux_Mode is used, tmux must have `allow-passthrough on` set.
//
// This is a syntactic sugar for s.Mode(Tmux_Mode).
set_tmux :: proc(s: ^Sequence) {
	set_mode(s, .Tmux_Mode)
}

// Screen sets the mode to Screen_Mode.
// Used to escape the OSC52 sequence for `screen`.
//
// This is a syntactic sugar for s.Mode(Screen_Mode).
set_screen :: proc(s: ^Sequence) {
	set_mode(s, .Screen_Mode)
}

// Clipboard sets the clipboard buffer for the OSC52 sequence.
set_clipboard :: proc(s: ^Sequence, c: Clipboard) {
	s.clipboard = c
}

// Primary sets the clipboard buffer to Primary_Clipboard.
// This is the X11 primary clipboard.
set_primary :: proc(s: ^Sequence) {
	set_clipboard(s, Primary_Clipboard)
}

// Limit sets the limit for the OSC52 sequence.
// The default limit is 0 (no limit).
//
// Strings longer than the limit get ignored. Settting the limit to 0 or a
// negative value disables the limit. Each terminal defines its own escapse
// sequence limit.
set_limit :: proc(s: ^Sequence, l: int) {
	if l < 0 {
		s.limit = 0
	} else {
		s.limit = l
	}
}

// Operation sets the operation for the OSC52 sequence.
// The default operation is Set_Operation.
set_operation :: proc(s: ^Sequence, o: Operation) {
	s.op = o
}

// Clear sets the operation to Clear_Operation.
// This clears the clipboard.
set_clear :: proc(s: ^Sequence) {
	set_operation(s, .Clear_Operation)
}

// Query sets the operation to Query_Operation.
// This queries the clipboard contents.
set_query :: proc(s: ^Sequence) {
	set_operation(s, .Query_Operation)
}

// SetString sets the string for the OSC52 sequence. Strings are joined with a
// space character.
set_string :: proc(s: ^Sequence, strs: ..string) {
	s.str = strings.join(strs, " ")
}

// New creates a new OSC52 sequence with the given string(s). Strings are
// joined with a space character.
new_sequence :: proc(strs: ..string) -> (s: ^Sequence) {
	using Mode
	using Operation
	
	s =           new(Sequence)
	s.str =       strings.join(strs, " ")
	s.limit =     0
	s.mode =      Default_Mode
	s.clipboard = System_Clipboard
	s.op =        Set_Operation
	return 
}

// Query creates a new OSC52 sequence with the Query_Operation.
// This returns a new OSC52 sequence to query the clipboard contents.
new_query :: proc() -> (s: ^Sequence) {
	s = new_sequence()
	set_query(s)
	return
}

// Clear creates a new OSC52 sequence with the Clear_Operation.
// This returns a new OSC52 sequence to clear the clipboard.
//
// This is a syntactic sugar for New().Clear().
new_clear :: proc() -> (s: ^Sequence) {
	s = new_sequence()
	set_clear(s)
	return
}

seq_start :: proc(s: ^Sequence) -> string {
	using Mode
	
	#partial switch s.mode {
	case Tmux_Mode:
		// Write the start of a tmux DCS escape sequence.
		return "\x1bPtmux;\x1b"
	case Screen_Mode:
		// Write the start of a DCS sequence.
		return "\x1bP"
	case:
		return ""
	}
}

seq_end :: proc(s: ^Sequence) -> string {
	using Mode
	#partial switch s.mode {
	case Tmux_Mode, Screen_Mode:
		// Terminate the DCS escape sequence.
		return "\x1b\\"
	case:
		return ""
	}
}
