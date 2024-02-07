package karvi

import "core:fmt"
import "core:strings"
import "core:os"

concat :: strings.concatenate

/* Sequence definitions */

// Cursor positioning.
CursorUpSeq              :: "A"
CursorDownSeq            :: "B"
CursorForwardSeq         :: "C"
CursorBackSeq            :: "D"
CursorNextLineSeq        :: "E"
CursorPreviousLineSeq    :: "F"
CursorHorizontalSeq      :: "G"
CursorPositionSeq        :: "H"
EraseDisplaySeq          :: "J"
EraseLineSeq             :: "K"
ScrollUpSeq              :: "S"
ScrollDownSeq            :: "T"
SaveCursorPositionSeq    :: "s"
RestoreCursorPositionSeq :: "u"
ChangeScrollingRegionSeq :: "r"
InsertLineSeq            :: "L"
DeleteLineSeq            :: "M"

// Explicit values for EraseLineSeq.
EraseLineRightSeq  :: "0K"
EraseLineLeftSeq   :: "1K"
EraseEntireLineSeq :: "2K"

// Mouse.
EnableMousePressSeq         :: "?9h"    // press only (X10)
DisableMousePressSeq        :: "?9l"
EnableMouseSeq              :: "?1000h" // press, release, wheel
DisableMouseSeq             :: "?1000l"
EnableMouseHiliteSeq        :: "?1001h" // highlight
DisableMouseHiliteSeq       :: "?1001l"
EnableMouseCellMotionSeq    :: "?1002h" // press, release, move on pressed, wheel
DisableMouseCellMotionSeq   :: "?1002l"
EnableMouseAllMotionSeq     :: "?1003h" // press, release, move, wheel
DisableMouseAllMotionSeq    :: "?1003l"
EnableMouseExtendedModeSeq  :: "?1006h" // press, release, move, wheel, extended coordinates
DisableMouseExtendedModeSeq :: "?1006l"
EnableMousePixelsModeSeq    :: "?1016h" // press, release, move, wheel, extended pixel coordinates
DisableMousePixelsModeSeq   :: "?1016l"

// Screen.
RestoreScreenSeq :: "?47l"
SaveScreenSeq    :: "?47h"
AltScreenSeq     :: "?1049h"
ExitAltScreenSeq :: "?1049l"

// Bracketed paste.
// https://en.wikipedia.org/wiki/Bracketed-paste
EnableBracketedPasteSeq  :: "?2004h"
DisableBracketedPasteSeq :: "?2004l"
StartBracketedPasteSeq   :: "200~"
EndBracketedPasteSeq     :: "201~"

// Session.
SetWindowTitleSeq     :: "2;"
SetForegroundColorSeq :: "10;"
SetBackgroundColorSeq :: "11;"
SetCursorColorSeq     :: "12;"
ShowCursorSeq         :: "?25h"
HideCursorSeq         :: "?25l"

// Reset the terminal to its default style, removing any active styles.
reset :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, RESET_SEQ, "m"})
	os.write_string(o.w, str)
}

// SetForegroundColor sets the default foreground color.
set_foreground_color :: proc(o: ^Output, c: ^Color) {
	str := strings.concatenate([]string{OSC, SetForegroundColorSeq, c.color, BEL})
	os.write_string(o.w, str)
}

// SetBackgroundColor sets the default background color.
set_background_color :: proc(o: ^Output, c: ^Color) {
	str := strings.concatenate([]string{OSC, SetBackgroundColorSeq, c.color, BEL})
	os.write_string(o.w, str)
}

// SetCursorColor sets the cursor color.
set_cursor_color :: proc(o: ^Output, c: ^Color) {
	str := strings.concatenate([]string{OSC, SetCursorColorSeq, c.color, BEL})
	os.write_string(o.w, str)
}

// RestoreScreen restores a previously saved screen state.
restore_screen :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, RestoreScreenSeq})
	os.write_string(o.w, str)
}

// SaveScreen saves the screen state.
save_screen :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, SaveScreenSeq})
	os.write_string(o.w, str)
}

// AltScreen switches to the alternate screen buffer. The former view can be
// restored with ExitAltScreen().
alt_screen :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, AltScreenSeq})
	os.write_string(o.w, str)
}

// ExitAltScreen exits the alternate screen buffer and returns to the former
// terminal view.
exit_alt_screen :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, ExitAltScreenSeq})
	os.write_string(o.w, str)
}

// ClearScreen clears the visible portion of the terminal.
clear_screen :: proc(o: ^Output) {
	n := int_to_string(2)
	str := strings.concatenate([]string{CSI, n, EraseDisplaySeq})
	os.write_string(o.w, str)
	move_cursor(o, 1, 1)
}

// MoveCursor moves the cursor to a given position.
move_cursor :: proc(o: ^Output, row, column: int) {
	row := int_to_string(row)
	column := int_to_string(column)
	str := strings.concatenate([]string{CSI, row, ";", column, CursorPositionSeq})
	os.write_string(o.w, str)
}

// HideCursor hides the cursor.
hide_cursor :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, HideCursorSeq})
	os.write_string(o.w, str)
}

// ShowCursor shows the cursor.
show_cursor :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, ShowCursorSeq})
	os.write_string(o.w, str)
}

// SaveCursorPosition saves the cursor position.
save_cursor_position :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, SaveCursorPositionSeq})
	os.write_string(o.w, str)
}

// RestoreCursorPosition restores a saved cursor position.
restore_cursor_position :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, RestoreCursorPositionSeq})
	os.write_string(o.w, str)
}

// CursorUp moves the cursor up a given number of lines.
cursor_up :: proc(o: ^Output, n: int) {
	n := int_to_string(n)
	str := strings.concatenate([]string{CSI, n, CursorUpSeq})
	os.write_string(o.w, str)
}

// CursorDown moves the cursor down a given number of lines.
cursor_down :: proc(o: ^Output, n: int) {
	n := int_to_string(n)
	str := strings.concatenate([]string{CSI, n, CursorDownSeq})
	os.write_string(o.w, str)
}

// CursorForward moves the cursor up a given number of lines.
cursor_forward :: proc(o: ^Output, n: int) {
	n := int_to_string(n)
	str := strings.concatenate([]string{CSI, n, CursorForwardSeq})
	os.write_string(o.w, str)
}

// CursorBack moves the cursor backwards a given number of cells.
cursor_back :: proc(o: ^Output, n: int) {
	n := int_to_string(n)
	str := strings.concatenate([]string{CSI, n, CursorBackSeq})
	os.write_string(o.w, str)
}

// CursorNextLine moves the cursor down a given number of lines and places it at
// the beginning of the line.
cursor_next_line :: proc(o: ^Output, n: int) {
	n := int_to_string(n)
	str := strings.concatenate([]string{CSI, n, CursorNextLineSeq})
	os.write_string(o.w, str)
}

// CursorPrevLine moves the cursor up a given number of lines and places it at
// the beginning of the line.
cursor_prev_line :: proc(o: ^Output, n: int) {
	n := int_to_string(n)
	str := strings.concatenate([]string{CSI, n, CursorPreviousLineSeq})
	os.write_string(o.w, str)
}

// ClearLine clears the current line.
clear_line :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EraseEntireLineSeq})
	os.write_string(o.w, str)
}

// ClearLineLeft clears the line to the left of the cursor.
clear_line_left :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EraseLineLeftSeq})
	os.write_string(o.w, str)
}

// ClearLineRight clears the line to the right of the cursor.
clear_line_right :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EraseLineRightSeq})
	os.write_string(o.w, str)
}

// ClearLines clears a given number of lines.
clear_lines :: proc(o: ^Output, n: int) {
	x := int_to_string(2); y := int_to_string(1)
	clear_line := strings.concatenate([]string{CSI, x, EraseLineSeq})
	cursor_up := strings.concatenate([]string{CSI, y, CursorUpSeq})
	str := strings.concatenate([]string{cursor_up, clear_line})
	str = strings.concatenate([]string{clear_line, strings.repeat(str, n)})
	os.write_string(o.w, str)
}

// ChangeScrollingRegion sets the scrolling region of the terminal.
change_scrolling_region :: proc(o: ^Output, top, bottom: int) {
	top := int_to_string(top)
	bottom := int_to_string(bottom)
 	str := strings.concatenate([]string{CSI, top, ";", bottom, ChangeScrollingRegionSeq})
	os.write_string(o.w, str)
}

// InsertLines inserts the given number of lines at the top of the scrollable
// region, pushing lines below down.
insert_lines :: proc(o: ^Output, n: int) {
	n := int_to_string(n)
	str := strings.concatenate([]string{CSI, n, InsertLineSeq})
	os.write_string(o.w, str)
}

// DeleteLines deletes the given number of lines, pulling any lines in
// the scrollable region below up.
delete_lines :: proc(o: ^Output, n: int) {
	n := int_to_string(n)
	str := strings.concatenate([]string{CSI, n, DeleteLineSeq})
	os.write_string(o.w, str)
}

// EnableMousePress enables X10 mouse mode. Button press events are sent only.
enable_mouse_press :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EnableMousePressSeq})
	os.write_string(o.w, str)
}

// DisableMousePress disables X10 mouse mode.
disable_mouse_press :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, DisableMousePressSeq})
	os.write_string(o.w, str)
}

// EnableMouse enables Mouse Tracking mode.
enable_mouse :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EnableMouseSeq})
	os.write_string(o.w, str)
}

// DisableMouse disables Mouse Tracking mode.
disable_mouse :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, DisableMouseSeq})
	os.write_string(o.w, str)
}

// EnableMouseHilite enables Hilite Mouse Tracking mode.
enable_mouse_hilite :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EnableMouseHiliteSeq})
	os.write_string(o.w, str)
}

// DisableMouseHilite disables Hilite Mouse Tracking mode.
disable_mouse_hilite :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, DisableMouseHiliteSeq})
	os.write_string(o.w, str)
}

// EnableMouseCellMotion enables Cell Motion Mouse Tracking mode.
enable_mouse_cell_motion :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EnableMouseCellMotionSeq})
	os.write_string(o.w, str)
}

// DisableMouseCellMotion disables Cell Motion Mouse Tracking mode.
disable_mouse_cell_motion :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, DisableMouseCellMotionSeq})
	os.write_string(o.w, str)
}

// EnableMouseAllMotion enables All Motion Mouse mode.
enable_mouse_all_motion :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EnableMouseAllMotionSeq})
	os.write_string(o.w, str)
}

// DisableMouseAllMotion disables All Motion Mouse mode.
disable_mouse_all_motion :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, DisableMouseAllMotionSeq})
	os.write_string(o.w, str)
}

// EnableMouseExtendedMotion enables Extended Mouse mode (SGR). This should be
// enabled in conjunction with EnableMouseCellMotion, and EnableMouseAllMotion.
enable_mouse_extended_mode :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EnableMouseExtendedModeSeq})
	os.write_string(o.w, str)
}

// DisableMouseExtendedMotion disables Extended Mouse mode (SGR).
disable_mouse_extended_mode :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, DisableMouseExtendedModeSeq})
	os.write_string(o.w, str)
}

// EnableMousePixelsMotion enables Pixel Motion Mouse mode (SGR-Pixels). This
// should be enabled in conjunction with EnableMouseCellMotion, and
// EnableMouseAllMotion.
enable_mouse_pixels_mode :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EnableMousePixelsModeSeq})
	os.write_string(o.w, str)
}

// DisableMousePixelsMotion disables Pixel Motion Mouse mode (SGR-Pixels).
disable_mouse_pixels_mode :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, DisableMousePixelsModeSeq})
	os.write_string(o.w, str)
}

// SetWindowTitle sets the terminal window title.
set_window_title :: proc(o: ^Output, title: string) {
	str := strings.concatenate([]string{OSC, SetWindowTitleSeq, title, BEL})
	os.write_string(o.w, str)
}

// EnableBracketedPaste enables bracketed paste.
enable_bracketed_paste :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, EnableBracketedPasteSeq})
	os.write_string(o.w, str)
}

// DisableBracketedPaste disables bracketed paste.
disable_bracketed_paste :: proc(o: ^Output) {
	str := strings.concatenate([]string{CSI, DisableBracketedPasteSeq})
	os.write_string(o.w, str)
}
