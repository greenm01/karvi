package event

import "core:os"
import "core:c"
import "core:fmt"

import sys "../syscalls"

init_input :: proc() -> Errno {
	err := sys.check_terminal(stdin)
	if err == -1 {
		return Errno(err)
	}
	con = stdin

	// init the resize hander
	if err := init_event_handler(); err != 0 {
		return err
	}

	return Errno(err)
}

// discards any data written to the terminal 
close_input :: proc() -> Errno {
	// TODO: better error handling
	close_event_handler()
	return Errno(sys.tc_flush(c.int(con)))	
}

open_input_tty :: proc() -> (os.Handle, Errno) {
	f, err := os.open("/dev/tty")
	if err != 0 {
		// 2 is stderr on posix
		return 2, Errno(err)
	}
	return f, 0
}

init_event_handler :: proc() -> Errno {
	if err := sys.init_event_handler(); err != 0 {
		return Errno(err)
	}
	return 0
}	

close_event_handler :: proc() -> Errno {
	if err := sys.close_event_handler(); err != 0 {
		return Errno(err)
	}
	return 0
}
