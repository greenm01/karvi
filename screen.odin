package karvi

import "core:fmt"
import "core:strings"

concat :: strings.concatenate

/* Sequence definitions */

// Cursor positioning.
CursorUpSeq              :: "%dA"
CursorDownSeq            :: "%dB"
CursorForwardSeq         :: "%dC"
CursorBackSeq            :: "%dD"
CursorNextLineSeq        :: "%dE"
CursorPreviousLineSeq    :: "%dF"
CursorHorizontalSeq      :: "%dG"
CursorPositionSeq        :: "%d;%dH"
EraseDisplaySeq          :: "%dJ"
EraseLineSeq             :: "%dK"
ScrollUpSeq              :: "%dS"
ScrollDownSeq            :: "%dT"
SaveCursorPositionSeq    :: "s"
RestoreCursorPositionSeq :: "u"
ChangeScrollingRegionSeq :: "%d;%dr"
InsertLineSeq            :: "%dL"
DeleteLineSeq            :: "%dM"

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
SetWindowTitleSeq     := concat([]string{"2;%s", BELL})
SetForegroundColorSeq := concat([]string{"10;%s", BELL})
SetBackgroundColorSeq := concat([]string{"11;%s", BELL})
SetCursorColorSeq     := concat([]string{"12;%s", BELL})
ShowCursorSeq         :: "?25h"
HideCursorSeq         :: "?25l"

// Reset the terminal to its default style, removing any active styles.
reset :: proc(o: Output) {
	str := concat([]string{CSI, RESET_SEQ})
	fmt.fprint(o.w, str, "m")
}

// SetForegroundColor sets the default foreground color.
set_goreground_color :: proc(o: Output, color: Color) {
	str := concat([]string{OSC, SetForegroundColorSeq})
	fmt.fprintf(o.w, str, color)
}

// SetBackgroundColor sets the default background color.
set_background_color :: proc(o: Output, color: Color) {
	str := concat([]string{OSC, SetBackgroundColorSeq})
	fmt.fprintf(o.w, str, color)
}

// SetCursorColor sets the cursor color.
set_cursor_color :: proc(o: Output, color: Color) {
	str := concat([]string{OSC, SetCursorColorSeq})
	fmt.fprintf(o.w, str, color)
}

// RestoreScreen restores a previously saved screen state.
restore_screen :: proc(o: Output) {
	str := concat([]string{CSI, RestoreScreenSeq})
	fmt.fprint(o.w, str)
}

// SaveScreen saves the screen state.
save_screen :: proc(o: Output) {
	str := concat([]string{CSI, SaveScreenSeq})
	fmt.fprint(o.w, str)
}

// AltScreen switches to the alternate screen buffer. The former view can be
// restored with ExitAltScreen().
alt_screen :: proc(o: Output) {
	str := concat([]string{CSI, AltScreenSeq})
	fmt.fprint(o.w, str)
}

// ExitAltScreen exits the alternate screen buffer and returns to the former
// terminal view.
exit_alt_screen :: proc(o: Output) {
	str := concat([]string{CSI, ExitAltScreenSeq})
	fmt.fprint(o.w, str)
}

// ClearScreen clears the visible portion of the terminal.
clear_screen :: proc(o: Output) {
	str := concat([]string{CSI, EraseDisplaySeq})
	fmt.fprintf(o.w, str, 2)
	move_cursor(o, 1, 1)
}

// MoveCursor moves the cursor to a given position.
move_cursor :: proc(o: Output, row, column: int) {
	str := concat([]string{CSI, CursorPositionSeq})
	fmt.fprintf(o.w, str, row, column)
}

// HideCursor hides the cursor.
hide_cursor :: proc(o: Output) {
	str := concat([]string{CSI, HideCursorSeq})
	fmt.fprint(o.w, str)
}

// ShowCursor shows the cursor.
show_cursor :: proc(o: Output) {
	str := concat([]string{CSI, ShowCursorSeq})
	fmt.fprint(o.w, str)
}

// SaveCursorPosition saves the cursor position.
save_cursor_position :: proc(o: Output) {
	str := concat([]string{CSI, SaveCursorPositionSeq})
	fmt.fprint(o.w, str)
}

// RestoreCursorPosition restores a saved cursor position.
restore_cursor_position :: proc(o: Output) {
	str := concat([]string{CSI, RestoreCursorPositionSeq})
	fmt.fprint(o.w, str)
}

// CursorUp moves the cursor up a given number of lines.
cursor_up :: proc(o: Output, n: int) {
	str := concat([]string{CSI, CursorUpSeq})
	fmt.fprintf(o.w, str, n)
}

// CursorDown moves the cursor down a given number of lines.
cursor_down :: proc(o: Output, n: int) {
	str := concat([]string{CSI, CursorDownSeq})
	fmt.fprintf(o.w, str, n)
}

// CursorForward moves the cursor up a given number of lines.
cursor_forward :: proc(o: Output, n: int) {
	str := concat([]string{CSI, CursorForwardSeq})
	fmt.fprintf(o.w, str, n)
}

// CursorBack moves the cursor backwards a given number of cells.
cursor_back :: proc(o: Output, n: int) {
	str := concat([]string{CSI, CursorBackSeq})
	fmt.fprintf(o.w, str, n)
}

// CursorNextLine moves the cursor down a given number of lines and places it at
// the beginning of the line.
cursor_nextLine :: proc(o: Output, n: int) {
	str := concat([]string{CSI, CursorNextLineSeq})
	fmt.fprintf(o.w, str, n)
}

// CursorPrevLine moves the cursor up a given number of lines and places it at
// the beginning of the line.
cursor_prev_line :: proc(o: Output, n: int) {
	str := concat([]string{CSI, CursorPreviousLineSeq})
	fmt.fprintf(o.w, str, n)
}

// ClearLine clears the current line.
clear_line :: proc(o: Output) {
	str := concat([]string{CSI, EraseEntireLineSeq})
	fmt.fprint(o.w, str)
}

// ClearLineLeft clears the line to the left of the cursor.
clear_line_left :: proc(o: Output) {
	str := concat([]string{CSI, EraseLineLeftSeq})
	fmt.fprint(o.w, str)
}

// ClearLineRight clears the line to the right of the cursor.
clear_line_right :: proc(o: Output) {
	str := concat([]string{CSI, EraseLineRightSeq})
	fmt.fprint(o.w, str)
}

// ClearLines clears a given number of lines.
clear_lines :: proc(o: Output, n: int) {
	str := concat([]string{CSI, EraseLineSeq})
	clear_line := fmt.tprintf(str, 2)
	str = concat([]string{CSI, CursorUpSeq})
	cursor_up := fmt.tprintf(str, 1)
	str = concat([]string{cursor_up, clear_line})
	str = concat([]string{clear_line, strings.repeat(str, n)})
	fmt.fprint(o.w, str)
}

// ChangeScrollingRegion sets the scrolling region of the terminal.
change_scrolling_region :: proc(o: Output, top, bottom: int) {
	str := concat([]string{CSI, ChangeScrollingRegionSeq})
	fmt.fprintf(o.w, str, top, bottom)
}

// InsertLines inserts the given number of lines at the top of the scrollable
// region, pushing lines below down.
insert_lines :: proc(o: Output, n: int) {
	str := concat([]string{CSI, InsertLineSeq})
	fmt.fprintf(o.w, str, n)
}

// DeleteLines deletes the given number of lines, pulling any lines in
// the scrollable region below up.
delete_lines :: proc(o: Output, n: int) {
	str := concat([]string{CSI, DeleteLineSeq})
	fmt.fprintf(o.w, str, n)
}

// EnableMousePress enables X10 mouse mode. Button press events are sent only.
enable_mouse_press :: proc(o: Output) {
	str := concat([]string{CSI, EnableMousePressSeq})
	fmt.fprint(o.w, str)
}

// DisableMousePress disables X10 mouse mode.
disable_mouse_press :: proc(o: Output) {
	str := concat([]string{CSI, DisableMousePressSeq})
	fmt.fprint(o.w, str)
}

// EnableMouse enables Mouse Tracking mode.
enable_mouse :: proc(o: Output) {
	str := concat([]string{CSI, EnableMouseSeq})
	fmt.fprint(o.w, str)
}

// DisableMouse disables Mouse Tracking mode.
disable_mouse :: proc(o: Output) {
	str := concat([]string{CSI, DisableMouseSeq})
	fmt.fprint(o.w, str)
}

// EnableMouseHilite enables Hilite Mouse Tracking mode.
enable_mouse_hilite :: proc(o: Output) {
	str := concat([]string{CSI, EnableMouseHiliteSeq})
	fmt.fprint(o.w, str)
}

// DisableMouseHilite disables Hilite Mouse Tracking mode.
disable_mouse_hilite :: proc(o: Output) {
	str := concat([]string{CSI, DisableMouseHiliteSeq})
	fmt.fprint(o.w, str)
}

// EnableMouseCellMotion enables Cell Motion Mouse Tracking mode.
enable_mouse_cell_motion :: proc(o: Output) {
	str := concat([]string{CSI, EnableMouseCellMotionSeq})
	fmt.fprint(o.w, str)
}

// DisableMouseCellMotion disables Cell Motion Mouse Tracking mode.
disable_mouse_cell_motion :: proc(o: Output) {
	str := concat([]string{CSI, DisableMouseCellMotionSeq})
	fmt.fprint(o.w, str)
}

// EnableMouseAllMotion enables All Motion Mouse mode.
enable_mouse_all_motion :: proc(o: Output) {
	str := concat([]string{CSI, EnableMouseAllMotionSeq})
	fmt.fprint(o.w, str)
}

// DisableMouseAllMotion disables All Motion Mouse mode.
disable_mouse_all_motion :: proc(o: Output) {
	str := concat([]string{CSI, DisableMouseAllMotionSeq})
	fmt.fprint(o.w, str)
}

// EnableMouseExtendedMotion enables Extended Mouse mode (SGR). This should be
// enabled in conjunction with EnableMouseCellMotion, and EnableMouseAllMotion.
enable_mouse_extended_mode :: proc(o: Output) {
	str := concat([]string{CSI, EnableMouseExtendedModeSeq})
	fmt.fprint(o.w, str)
}

// DisableMouseExtendedMotion disables Extended Mouse mode (SGR).
disable_mouse_extended_mode :: proc(o: Output) {
	str := concat([]string{CSI, DisableMouseExtendedModeSeq})
	fmt.fprint(o.w, str)
}

// EnableMousePixelsMotion enables Pixel Motion Mouse mode (SGR-Pixels). This
// should be enabled in conjunction with EnableMouseCellMotion, and
// EnableMouseAllMotion.
enable_mouse_pixels_mode :: proc(o: Output) {
	str := concat([]string{CSI, EnableMousePixelsModeSeq})
	fmt.fprint(o.w, str)
}

// DisableMousePixelsMotion disables Pixel Motion Mouse mode (SGR-Pixels).
disable_mouse_pixels_mode :: proc(o: Output) {
	str := concat([]string{CSI, DisableMousePixelsModeSeq})
	fmt.fprint(o.w, str)
}

// SetWindowTitle sets the terminal window title.
set_window_title :: proc(o: Output, title: string) {
	str := concat([]string{OSC, SetWindowTitleSeq})
	fmt.fprintf(o.w, str, title)
}

// EnableBracketedPaste enables bracketed paste.
enable_bracketed_paste :: proc(o: Output) {
	str := concat([]string{CSI, EnableBracketedPasteSeq})
	fmt.fprintf(o.w, str)
}

// DisableBracketedPaste disables bracketed paste.
disable_bracketed_paste :: proc(o: Output) {
	str := concat([]string{CSI, DisableBracketedPasteSeq})
	fmt.fprintf(o.w, str)
}
