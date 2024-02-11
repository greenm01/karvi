package event

import "core:time"
import "core:os"
import "core:fmt"
import "core:unicode/utf8"
import "core:strconv"
import "core:bytes"

Event :: struct {
	type: Event_Type,
}

Event_Type :: union {
	Key,
	Mouse,
	//Resize,
}

// checks to see if there's an event available within the specified time
poll :: proc(poll_time: time.Duration) -> (^Event, Errno) {
	buf: []byte
	err: Errno
	
	stopwatch := time.Stopwatch{}
	time.stopwatch_start(&stopwatch)

	for time.stopwatch_duration(stopwatch) < poll_time {
		if buf, err = read_internal(); err != 0 {
			return nil, err
		}	
		if len(buf) > 0 do break
	}

	return parse_event(buf)
}


// Returns an event immediately (if available) or waits and blocks until one is
read :: proc() -> (^Event, Errno) {
	buf: []byte
	err: Errno
	
	for {
		if buf, err = read_internal(); err != 0 {
			return nil, err
		}
		if len(buf) > 0 do break
	}

	return parse_event(buf)
} 

@(private)
read_internal :: proc() -> ([]byte, Errno) {
	buf: [256]byte
	num_bytes, err := os.read(input_tty, buf[:])
	if err != 0 do return []byte{}, Errno(err)
	return bytes.clone(buf[:num_bytes]), 0
}

parse_event :: proc(buf: []byte) -> (^Event, Errno) {
	str := transmute(string)buf
	// Check for a keyboard sequence
	if k, ok := keyboard_sequences[str]; ok {
		return k, 0
	}

	// check for a mouse event
	if len(buf) >= 6 {
		kind: Mouse_Event_Kind
		// get the first two bits
		b := buf[3] - 0x20
		
		switch b & 3 {
			case 0:
				kind = ((b & 64) != 0) ? .Wheel_Up : .Left_Button  
			case 1:
				kind = ((b & 64) != 0) ? .Wheel_Down : .Middle_Button
			case 2:
				kind = .Right_Button
			case 3:
				kind = .Release
			case:
				return nil, -1
		}

		// Mouse modifiers
		mod := Mouse_Modifiers.None
		// Drag mouse
		if ((b & 32) != 0) do mod |= .Drag
		// Control key pressed
		if ((b & 16) != 0) do mod |= .Ctrl
		// Alt key pressed
		if ((b & 8) != 0) do mod |= .Alt
			
		x := int(buf[4] - 0x21)
		y := int(buf[5] - 0x21)

		return new_mouse(kind, x, y, mod), 0
	}

	// TODO: check for a resize event
	
	// check for a hex code
	hex := fmt.tprintf("%x", buf)
	if k, ok := hex_codes[hex]; ok {
		return k, 0
	}

	// Check if the alt key is pressed.
	if len(buf) > 1 && buf[0] == 0x1b {
		// Remove the initial escape sequence
		c, _ := utf8.decode_rune(buf[1:])
		if !utf8.valid_rune(c) do return nil, 1

		return new_key(code = RuneKey, alt_pressed = true, runes = []rune{c}), 0
	}

	runes: [dynamic]rune

	// Translate stdin into runes.
	for i, w := 0, 0; i < len(buf); i += w { 
		r, width := utf8.decode_rune(buf[i:])
		if !utf8.valid_rune(r) do return nil, 2
		append(&runes, r)
		w = width
	}

	if len(runes) == 0 {
		return nil, 3
	} else if len(runes) > 1 {
		return new_key(code = RuneKey, runes = runes[:]), 0
	}

	r := Key_Code(runes[0])
	if len(buf) == 1 && r <= KeyUnitSeparator || r == KeyDelete {
		return new_key(code = r), 0
	}

	if runes[0] == ' ' do return new_key(code = Space, runes = runes[:]), 0

	return new_key(code = RuneKey, runes = runes[:]), 0
}
