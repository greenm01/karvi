package event

import "core:os"
import "core:c"

import sys "../syscalls"

// discards any data written to the terminal 
restore_input :: proc() -> Errno {
	return Errno(sys.tc_flush(c.int(con)))	
}

init_input :: proc() -> Errno {
	err := sys.check_terminal(stdin)
	if err == -1 {
		return Errno(err)
	}
	con = stdin
	return Errno(err)
}

open_input_tty :: proc() -> (os.Handle, Errno) {
	f, err := os.open("/dev/tty")
	if err != 0 {
		// 2 is stderr on posix
		return 2, Errno(err)
	}
	return f, 0
}
