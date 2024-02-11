package event

Mouse :: struct {
   using event: ^Event,
   kind:        Mouse_Event_Kind,
   x:           int,
   y:           int,
   modifiers:   Mouse_Modifiers,
}

new_mouse :: proc(kind: Mouse_Event_Kind, x, y: int, mod := Mouse_Modifiers.None) -> ^Event {
   event := new(Event)
   event.type = Mouse{event, kind, x, y, mod}
   return event
}
   
Mouse_Event_Kind :: enum  {
   Left_Button,
   Middle_Button,
   Right_Button,
   Release,
   Wheel_Up,
   Wheel_Down,
}

Mouse_Modifiers :: enum u8 {
   None,
   Alt,
   Ctrl,
   Shift =  4,
   Drag = 8,
}
