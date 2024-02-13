package event

import kv "../"
import sys "../syscalls"

// the default window size
window_size := new_window_size()

// Resize reports window resize events
Resize :: struct {
	using event:  ^Event,
	width:        int,
	height:       int,
	delta_width:  int,
	delta_height: int,
}

new_resize :: proc(ws: ^Window_Size) -> ^Event {
	event := new(Event)
	w := ws.width
	h := ws.height
	dw := ws.prev_width - w
	dh := ws.prev_height - h
	event.type = Resize{event, w, h, dw, dh}
	return event
}

// Tracks window size changes
Window_Size :: struct {
	init_width:  int,
	init_height: int,
	prev_width:  int,
	prev_height: int,
	width:       int,
	height:      int,
}

new_window_size :: proc() -> (ws: ^Window_Size) {
	ws = new(Window_Size)
	width, height := sys.window_size(kv.output.w)
	ws.init_width = width
	ws.init_height = height
	ws.prev_width = width
	ws.prev_height = height
	ws.width = width
	ws.height = height
	return	
}

update_window_size :: proc(ws: ^Window_Size, width, height: int) {
	ws.prev_width = ws.width
	ws.prev_height = ws.height
	ws.width = width
	ws.height = height
}
