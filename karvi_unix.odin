package karvi

import "core:time"
import "core:io"
import "core:fmt"
import "core:strings"
import "core:unicode/utf8"
import "core:strconv"
import "core:os"

import sys "syscalls"

// Linux, Darwin FreeBSD, OpenBSD 
when ODIN_OS != .Windows {

	// timeout for OSC queries
	OSC_TIMEOUT :: 5 * time.Second

	// ColorProfile returns the supported color profile:
	// Ascii, ANSI, ANSI256, or TrueColor.
	output_color_profile :: proc(o: ^Output) -> Profile {
		using Profile
		if is_tty(o) {
			return Ascii
		}

		if getenv("GOOGLE_CLOUD_SHELL") == "true" {
			return True_Color
		}

		term := getenv("TERM")
		color_term := getenv("COLORTERM")

		switch strings.to_lower(color_term) {
		case "24bit":
			fallthrough
		case "truecolor":
			if strings.has_prefix(term, "screen") {
				// tmux supports TrueColor, screen only ANSI256
				if getenv("TERM_PROGRAM") != "tmux" {
					return ANSI256
				}
			}
			return True_Color
		case "yes":
			fallthrough
		case "true":
			return ANSI256
		}

		switch term {
		case "xterm-kitty", "wezterm", "xterm-ghostty":
			return True_Color
		case "linux":
			return ANSI
		}

		if strings.contains(term, "256color") {
			return ANSI256
		}
		if strings.contains(term, "color") {
			return ANSI
		}
		if strings.contains(term, "ansi") {
			return ANSI
		}

		return Ascii
	}

	fg_color :: proc(o: ^Output) -> ^Color {
		s, err := term_status_report(o, 10)
		if err == 0 {
			c, err := xterm_color(s)
			if err == .No_Error {
				return c
			}
		}

		color_fgbg := getenv("COLORFGBG")
		if strings.contains(color_fgbg, ";") {
			c := strings.split(color_fgbg, ";")
			i := strconv.atoi(c[0])
			return new_ansi_color(i)
		}

		// default gray
		return new_ansi_color(7)
	}
 
	bg_color :: proc(o: ^Output) -> ^Color {
		using Error
		s, err := term_status_report(o, 11)
		if err == 0 {
			c, err := xterm_color(s)
			if err == .No_Error {
				return c
			}
		}

		color_fgbg := getenv("COLORFGBG")
		if strings.contains(color_fgbg, ";") {
			c := strings.split(color_fgbg, ";")
			i := strconv.atoi(c[len(c)-1])
			return new_ansi_color(i)
		}

		// default black
		return new_ansi_color(0)
	}

	wait_for_data :: proc(o: ^Output, timeout: time.Duration) -> Errno {
		fd := int(writer(o))
		return Errno(sys.wait_for_data(fd, timeout))
	}

	read_next_byte :: proc(o: ^Output) -> (byte, Errno) {
		if !o.unsafe {
			if err := wait_for_data(o, OSC_TIMEOUT); err != 0 {
				return 0, err
			}
		}

		b: [1]byte
		n, err := os.read(writer(o), b[:])
		if err != 0 {
			return 0, Errno(err)
		}

		if n == 0 {
			panic("read returned no data")
		}

		return b[0], Errno(0)
	}

	write_byte_to_string :: proc(s: string, b: byte) -> string {
		builder := strings.builder_make()
		strings.write_string(&builder, s)
		strings.write_byte(&builder, b)
		return strings.to_string(builder)
	}

	// readNextResponse reads either an OSC response or a cursor position response:
	//   - OSC response: "\x1b]11;rgb:1111/1111/1111\x1b\\"
	//   - cursor position response: "\x1b[42;1R"
	read_next_response :: proc(o: ^Output) -> (string, bool, Errno) {
		using Error
		
		start, tpe: byte
		err: Errno
		
		start, err = read_next_byte(o)
		if err != 0 do return "", false, err

		// first byte must be ESC
		for start != ESC {
			start, err = read_next_byte(o)
			if err != 0 do return "", false, err
		}

		response := write_byte_to_string("", start)

		// next byte is either '[' (cursor position response) or ']' (OSC response)
		tpe, err = read_next_byte(o)
		if err != 0 do return "", false, err

		response = write_byte_to_string(response, tpe)

		osc_response: bool
		switch tpe {
		case '[':
			osc_response = false
		case ']':
			osc_response = true
		case:
			return "", false, Errno(Err_Status_Report)
		}

		for {
			b, err := read_next_byte(o)
			if err != 0 do return "", false, err

			response = write_byte_to_string(response, b)

			if osc_response {
				// OSC can be terminated by BEL (\a) or ST (ESC)
				esc := utf8.runes_to_string([]rune{ESC})
				if b == BEL || strings.has_suffix(response, esc) {
					return response, true, Errno(0)
				}
			} else {
				// cursor position response is terminated by 'R'
				if b == 'R' {
					return response, false, Errno(0)
				}
			}

			// both responses have less than 25 bytes, so if we read more, that's an error
			if len(response) > 25 do break
			
		}

		return "", false, Errno(Err_Status_Report)
	}
	
	term_status_report :: proc(o: ^Output, sequence: int) -> (string, Errno) {
		using Error
		// screen/tmux can't support OSC, because they can be connected to multiple
		// terminals concurrently.
		term := getenv("TERM")
		if strings.has_prefix(term, "screen") || strings.has_prefix(term, "tmux") || strings.has_prefix(term, "dumb") {
			return "", Errno(Err_Status_Report)
		}

		tty := writer(o)
		if tty == 0 {
			return "", Errno(Err_Status_Report)
		}

		if !o.unsafe {
			fd := int(tty)
			// if in background, we can't control the terminal
			if !is_foreground(fd) {
				return "", Errno(Err_Status_Report)
			}

			t, err := sys.ioctl_get_termios(fd, TC_GET_ATTR)
			if err != 0 {
				return "", Errno(Err_Status_Report)
			}
			defer sys.ioctl_set_termios(fd, TC_SET_ATTR, t) //nolint:errcheck

 			noecho := t^
			noecho.c_lflag = noecho.c_lflag &~ ECHO
			noecho.c_lflag = noecho.c_lflag &~ ICANON
			if err := sys.ioctl_set_termios(fd, TC_SET_ATTR, &noecho); err != 0 {
				return "", Errno(Err_Status_Report)
			}
		}

		// first, send OSC query, which is ignored by terminal which do not support it
		str := strings.concatenate([]string{OSC, "%d;?", ST})
		fmt.fprintf(tty, "%s%v", str, sequence)

		// then, query cursor position, should be supported by all terminals
		str = strings.concatenate([]string{CSI, "6n"})
		fmt.fprintf(tty, "%s", str)

		// read the next response
		res, is_OSC, err := read_next_response(o)
		if err != 0 {
			return "", Errno(Err_Status_Report)
		}

		// if this is not OSC response, then the terminal does not support it
		if !is_OSC {
			return "", Errno(Err_Status_Report)
		}

		// read the cursor query response next and discard the result
		_, _, err = read_next_response(o)
		if err != 0 {
			return "", err
		}

		// fmt.Println("Rcvd", res[1:])
		return res, 0
	}

	// enable_virtual_terminal_processing enables virtual terminal processing on
	// Windows for w and returns a function that restores w to its previous state.
	// On non-Windows platforms, or if w does not refer to a terminal, then it
	// returns a non-nil no-op function and no error.
	enable_virtual_terminal_processing :: proc() -> (proc() -> Error, Error) {
		return proc() -> Error { return .No_Error }, .No_Error
	}

}

