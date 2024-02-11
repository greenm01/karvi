package event

import "core:fmt"

import kv "../"

main :: proc() {

	kv.init()
	defer kv.close()

	kv.enable_mouse(kv.output)
	kv.enable_mouse_cell_motion(kv.output)	
	start_listener()

	fmt.println("start pressing keys and click mouse")
	loop: for {
		// a blocking read. create a thread not to block
		event, err := read()
		switch e in event.type {
			case Key:
				if e.code == Escape do break loop
				fmt.println(key_string(e))
			case Mouse:
				fmt.print(e.kind, "x =", e.x, "y =", e.y)
				if (e.modifiers & Mouse_Modifiers.Alt) == Mouse_Modifiers.Alt {
					fmt.print(" modifier =", Mouse_Modifiers.Alt)
				}
				if (e.modifiers & Mouse_Modifiers.Ctrl) == Mouse_Modifiers.Ctrl {
					fmt.print(" modifier =", Mouse_Modifiers.Ctrl)
				}
				if (e.modifiers & Mouse_Modifiers.Drag) == Mouse_Modifiers.Drag {
					fmt.print(" modifier =", Mouse_Modifiers.Drag)
				}
				fmt.println()

		}
	}

	stop_listener()
	kv.disable_mouse_cell_motion(kv.output)	
	kv.disable_mouse(kv.output)
}
