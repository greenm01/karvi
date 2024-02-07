package screen_test

import "core:testing"
import "core:fmt"
import "core:os"

import kv "../"

file_name := "karvi.tmp"

expect  :: testing.expect
log     :: testing.log
errorf  :: testing.errorf

temp_output :: proc(t: ^testing.T) -> ^kv.Output {
	f, err := os.open(file_name, os.O_CREATE | os.O_RDWR)
	if err != 0 {
		testing.fail_now(t, "failed to open file")
	}

	o := kv.new_output(f)
	o.profile = kv.Profile.True_Color

	return kv.new_output(f)
}

verify :: proc(t: ^testing.T, o: ^kv.Output, exp: string) {
	
	if _, err := os.seek(o.w, 0, 0); err != 0 {
		testing.fail_now(t, "failed to seek file")
	}

	b, err := os.read_entire_file_from_handle(o.w)
	if err != true {
		testing.fail_now(t, "failed to read file")
	}

    result := string(b)
	expect(t, result == exp, fmt.tprintf("output does not match, expected %s, got %s", exp, result))    
	
	// close handle and remove temp file
	os.close(o.w)
	os.remove(file_name)
}

@(test)
TestReset :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.reset(o)
	verify(t, o, "\x1b[0m")
}

@(test)
TestSetForegroundColor :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.set_foreground_color(o, kv.new_ansi_color(0))
	verify(t, o, "\x1b]10;#000000\a")
}

@(test)
TestSetBackgroundColor :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.set_background_color(o, kv.new_ansi_color(0))
	verify(t, o, "\x1b]11;#000000\a")
}

@(test)
TestSetCursorColor :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.set_cursor_color(o, kv.new_ansi_color(0))
	verify(t, o, "\x1b]12;#000000\a")
}

@(test)
TestRestoreScreen :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.restore_screen(o)
	verify(t, o, "\x1b[?47l")
}

@(test)
TestSaveScreen :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.save_screen(o)
	verify(t, o, "\x1b[?47h")
}

@(test)
TestAltScreen :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.alt_screen(o)
	verify(t, o, "\x1b[?1049h")
}

@(test)
TestExitAltScreen :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.exit_alt_screen(o)
	verify(t, o, "\x1b[?1049l")
}

@(test)
TestClearScreen :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.clear_screen(o)
	verify(t, o, "\x1b[2J\x1b[1;1H")
}

@(test)
TestMoveCursor :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.move_cursor(o, 16, 8)
	verify(t, o, "\x1b[16;8H")
}

@(test)
TestHideCursor :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.hide_cursor(o)
	verify(t, o, "\x1b[?25l")
}

@(test)
TestShowCursor :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.show_cursor(o)
	verify(t, o, "\x1b[?25h")
}

@(test)
TestSaveCursorPosition :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.save_cursor_position(o)
	verify(t, o, "\x1b[s")
}

@(test)
TestRestoreCursorPosition :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.restore_cursor_position(o)
	verify(t, o, "\x1b[u")
}

@(test)
TestCursorUp :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.cursor_up(o, 8)
	verify(t, o, "\x1b[8A")
}

@(test)
TestCursorDowe :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.cursor_down(o, 8)
	verify(t, o, "\x1b[8B")
}

@(test)
TestCursorForward :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.cursor_forward(o, 8)
	verify(t, o, "\x1b[8C")
}

@(test)
TestCursorBack :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.cursor_back(o, 8)
	verify(t, o, "\x1b[8D")
}

@(test)
TestCursorNextLine :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.cursor_next_line(o, 8)
	verify(t, o, "\x1b[8E")
}
@(test)
TestCursorPrevLine :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.cursor_prev_line(o, 8)
	verify(t, o, "\x1b[8F")
}

@(test)
TestClearLine :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.clear_line(o)
	verify(t, o, "\x1b[2K")
}

@(test)
TestClearLineLeft :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.clear_line_left(o)
	verify(t, o, "\x1b[1K")
}

@(test)
TestClearLineRight :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.clear_line_right(o)
	verify(t, o, "\x1b[0K")
}

@(test)
TestClearLines :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.clear_lines(o, 8)
	verify(t, o, "\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K")
}

@(test)
TestChangeScrollingRegion :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.change_scrolling_region(o, 16, 8)
	verify(t, o, "\x1b[16;8r")
}

@(test)
TestInsertLines :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.insert_lines(o, 8)
	verify(t, o, "\x1b[8L")
}

@(test)
TestDeleteLines :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.delete_lines(o, 8)
	verify(t, o, "\x1b[8M")
}

@(test)
TestEnableMousePress :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.enable_mouse_press(o)
	verify(t, o, "\x1b[?9h")
}

@(test)
TestDisableMousePress :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.disable_mouse_press(o)
	verify(t, o, "\x1b[?9l")
}

@(test)
TestEnableMouse :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.enable_mouse(o)
	verify(t, o, "\x1b[?1000h")
}

@(test)
TestDisableMouse :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.disable_mouse(o)
	verify(t, o, "\x1b[?1000l")
}

@(test)
TestEnableMouseHilite :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.enable_mouse_hilite(o)
	verify(t, o, "\x1b[?1001h")
}

@(test)
TestDisableMouseHilite :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.disable_mouse_hilite(o)
	verify(t, o, "\x1b[?1001l")
}

@(test)
TestEnableMouseCellMotion :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.enable_mouse_cell_motion(o)
	verify(t, o, "\x1b[?1002h")
}

@(test)
TestDisableMouseCellMotion :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.disable_mouse_cell_motion(o)
	verify(t, o, "\x1b[?1002l")
}

@(test)
TestEnableMouseAllMotion :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.enable_mouse_all_motion(o)
	verify(t, o, "\x1b[?1003h")
}

@(test)
TestDisableMouseAllMotion :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.disable_mouse_all_motion(o)
	verify(t, o, "\x1b[?1003l")
}

@(test)
TestEnableMouseExtendedMode :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.enable_mouse_extended_mode(o)
	verify(t, o, "\x1b[?1006h")
}

@(test)
TestDisableMouseExtendedMode :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.disable_mouse_extended_mode(o)
	verify(t, o, "\x1b[?1006l")
}

@(test)
TestEnableMousePixelsMode :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.enable_mouse_pixels_mode(o)
	verify(t, o, "\x1b[?1016h")
}

@(test)
TestDisableMousePixelsMode :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.disable_mouse_pixels_mode(o)
	verify(t, o, "\x1b[?1016l")
}

@(test)
TestSetWindowTitle :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.set_window_title(o, "test")
	verify(t, o, "\x1b]2;test\a")
}

@(test)
TestHyperlink :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.write_string(o, kv.hyperlink("http://example.com", "example"))
	verify(t, o, "\x1b]8;;http://example.com\x1b\\example\x1b]8;;\x1b\\")
}

@(test)
TestCopyClipboard :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.output_copy(o.w, "hello")
	verify(t, o, "\x1b]52;c;aGVsbG8=\a")
}

@(test)
TestCopyPrimary :: proc(t: ^testing.T) {
	o := temp_output(t)
	kv.output_copy_primary(o.w, "hello")
	verify(t, o, "\x1b]52;p;aGVsbG8=\a")
}
