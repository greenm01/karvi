package event

Mouse :: struct {
   using event: ^Event,
   kind:        Mouse_Event_Kind,
   x:           int,
   y:           int,
   modifiers:   Mouse_Modifiers,
}

new_mouse :: proc(kind: Mouse_Event_Kind, x, y: int, mod := NONE) -> ^Event {
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

Mouse_Modifiers :: distinct u8

SHIFT:   Mouse_Modifiers: 0b0000_0001
CONTROL: Mouse_Modifiers: 0b0000_0010
ALT:     Mouse_Modifiers: 0b0000_0100
SUPER:   Mouse_Modifiers: 0b0000_1000
HYPER:   Mouse_Modifiers: 0b0001_0000
META:    Mouse_Modifiers: 0b0010_0000
NONE:    Mouse_Modifiers: 0b0000_0000
