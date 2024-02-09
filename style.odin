package karvi

import "core:fmt"
import "core:strings"

import wc "deps/wcwidth"

// Sequence definitions.
RESET_SEQ     := string("0")
BOLD_SEQ      := string("1")
FAINT_SEQ     := string("2")
ITALIC_SEQ    := string("3")
UNDERLINE_SEQ := string("4")
BLINK_SEQ     := string("5")
REVERSE_SEQ   := string("7")
CROSSOUT_SEQ  := string("9")
OVERLINE_SEQ  := string("53")

// Style is a string that various rendering styles can be applied to.
Style :: struct {
	profile: Profile,
	str    : string,
	styles : [dynamic]string,
}

// new_style returns a new Style.
new_style :: proc(s: string, p := Profile.ANSI) -> (style: ^Style) {
	style = new(Style)
	style.profile = p
	style.str = s
	style.styles = make([dynamic]string)
	return
}

del_style :: proc(s: ^Style) {
	delete(s.styles)
	free(s)
}

get_string :: proc(t: ^Style) -> string {
	return styled(t, t.str)
}

set_bold :: proc(s: string) -> string {
	style := new_style(s)
	defer del_style(style)
	enable_bold(style)
	return get_string(style)
}

set_faint :: proc(s: string) -> string {
	style := new_style(s)
	defer del_style(style)
	enable_faint(style)
	return get_string(style)
}

set_italic :: proc(s: string) -> string {
	style := new_style(s)
	defer del_style(style)
	enable_italic(style)
	return get_string(style)
}

set_underline :: proc(s: string) -> string {
	style := new_style(s)
	defer del_style(style)
	enable_underline(style)
	return get_string(style)
}

set_crossout :: proc(s: string) -> string {
	style := new_style(s)
	defer del_style(style)
	enable_crossout(style)
	return get_string(style)
}

set_foreground :: proc(s: string, fg: ^Color) -> string {
	style := new_style(s)
	defer del_style(style)
	set_style_foreground(style, fg)
	return get_string(style)	
}

set_background :: proc(s: string, bg: ^Color) -> string {
	style := new_style(s)
	defer del_style(style)
	set_style_background(style, bg)
	return get_string(style)	
}

set_foreground_background :: proc(s: string, fg, bg: ^Color) -> string {
	style := new_style(s)
	defer del_style(style)
	set_style_foreground(style, fg)
	set_style_background(style, bg)
	return get_string(style)	
}

// foreground sets a foreground color.
set_style_foreground :: proc(t: ^Style, c: ^Color) {
	append(&t.styles, sequence(c, false))
}

// background sets a background color.
set_style_background :: proc(t: ^Style, c: ^Color) {
	append(&t.styles, sequence(c, true))
}

render_style :: proc(t: ^Style) -> string {
	return styled(t, t.str)
}

// styled renders s with all applied styles.
styled :: proc(t: ^Style, s: string) -> string {
	using Profile
	if t.profile == Ascii {
		return s
	}
	if len(t.styles) == 0 {
		return s
	}

	seq := strings.join(t.styles[:], ";")
	if seq == "" {
		return s
	}

	str := strings.concatenate([]string{CSI, RESET_SEQ})
	return fmt.tprintf("%s%sm%s%sm", CSI, seq, s, str)
}

// bold enables bold rendering.
enable_bold :: proc(t: ^Style) {
	append(&t.styles, BOLD_SEQ)
}

// faint enables faint rendering.
enable_faint :: proc(t: ^Style) {
	append(&t.styles, FAINT_SEQ)
}

// italic enables italic rendering.
enable_italic :: proc(t: ^Style) {
	append(&t.styles, ITALIC_SEQ)
}

// underline enables underline rendering.
enable_underline :: proc(t: ^Style) {
	append(&t.styles, UNDERLINE_SEQ)
}

// overline enables overline rendering.
enable_overline :: proc(t: ^Style) {
	append(&t.styles, OVERLINE_SEQ)
}

// blink enables blink mode.
enable_blink :: proc(t: ^Style) {
	append(&t.styles, BLINK_SEQ)
}

// reverse enables reverse color mode.
enable_reverse :: proc(t: ^Style) {
	append(&t.styles, REVERSE_SEQ)
}

// cross_out enables crossed-out rendering.
enable_crossout :: proc(t: ^Style) {
	append(&t.styles, CROSSOUT_SEQ)
}

// width returns the width required to print all runes in Style.
width :: proc(t: ^Style) -> int {
	return wc.string_width(t.str)
}
