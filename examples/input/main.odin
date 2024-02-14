package input

import "core:fmt"

import kv "../../"
import ev "../../event"

main :: proc() {

	kv.enable_raw_mode()
	defer kv.disable_raw_mode()

	kv.enable_mouse(kv.output)
	kv.enable_mouse_cell_motion(kv.output)	
	ev.start_listener()

	kv.write("start pressing keys and the click mouse. ESC to quit.\n")
	fmt.println("screen size =", kv.window_size())

	using ev.Mouse_Modifiers

	loop: for {
		// a blocking read. create a thread not to block
		event, err := ev.read()
		switch e in event.type {
			case ev.Key:
				if e.code == ev.Escape do break loop
				fmt.println(ev.key_string(e))
			case ev.Mouse:
				fmt.print(e.kind, "x =", e.x, "y =", e.y)
				if (e.modifiers & Alt) == Alt {
					fmt.print(" modifier =", Alt)
				}
				if (e.modifiers & Ctrl) == Ctrl {
					fmt.print(" modifier =", Ctrl)
				}
				if (e.modifiers & Drag) == Drag {
					fmt.print(" modifier =", Drag)
				}
				fmt.println()
			case ev.Resize:
				fmt.println("window resize")
				fmt.println("width =", e.width, "height =", e.height)
				fmt.println("delta x =", e.delta_width, "delta y =", e.delta_height)
		}
	}

	ev.stop_listener()
	kv.disable_mouse_cell_motion(kv.output)	
	kv.disable_mouse(kv.output)
}
