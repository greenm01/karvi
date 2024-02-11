package event

import "core:fmt"

import kv "../"

main :: proc() {

	kv.init()
	defer kv.close()

	kv.enable_mouse(kv.output)
	kv.enable_mouse_cell_motion(kv.output)	
	start_listener()

	loop: for {
		// a blocking read. create a thread not to block
		event, err := read()
		switch e in event.type {
			case Key:
				if e.code == Escape do break loop
				fmt.println(key_string(e))
			case Mouse:
				fmt.println(e.kind, "x =", e.x, "y =", e.y)
		}
	}

	stop_listener()
	kv.disable_mouse_cell_motion(kv.output)	
	kv.disable_mouse(kv.output)
}
