package event

import "core:os"
import "core:fmt"

Errno :: distinct int

windows_stdin :: os.Handle
con: os.Handle
stdin := os.stdin
input_tty: os.Handle

//mock_channel := make(chan: Key)
mocking: bool

start_listener :: proc() -> Errno {
	err := init_input()
	if err != 0 do return err

	if mocking do return 0

	// TODO: check for raw mode?
	
	input_tty, err = open_input_tty()
	if err != 0 do return err

	return 0
}

stop_listener :: proc() -> Errno {
	return restore_input()
}
