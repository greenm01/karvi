package event

import "core:strings"
import "core:unicode/utf8"
import "core:fmt"

// Key_Code is an integer representation of a non-rune key, such as Escape, Enter, etc.
// All other keys are represented by a rune and have the KeyCode: RuneKey.
Key_Code :: distinct int

// Key contains information about a keypress.
Key :: struct {
	using event: ^Event,
	code:        Key_Code,
	runes:       []rune, // Runes that the key produced. Most key pressed produce one single rune.
	alt_pressed: bool,   // True when alt is pressed while the key is typed.
}

new_key :: proc(code: Key_Code, runes := []rune{}, alt_pressed := false) -> ^Event {
	event := new(Event)
	event.type = Key{event, code, runes, alt_pressed}
	return event
}

// key_string returns a string representation of the key.
// (e.g. "a", "B", "alt+a", "enter", "ctrl+c", "shift-down", etc.)
key_string :: proc(k: Key) -> (str: string) {
	if k.alt_pressed {
		str = "alt+"
		str = strings.concatenate([]string{str, write_rune(k.runes[0])})
		return
	}
	if k.code == RuneKey {
		str = transmute(string)k.runes
		return
	} else if s, ok := key_names[k.code]; ok {
		str = s
		return
	}
	return
}

write_rune :: proc(r: rune) -> string {
	builder := strings.builder_make()
	strings.write_rune(&builder, r)  
	return strings.to_string(builder) 
}

// key_code_string returns the string representation of a key_code
key_code_string :: proc(k: Key_Code) -> string {
	if s, ok := key_names[k]; ok {
		return s
	}
	return ""
}

// See: https://en.wikipedia.org/wiki/C0_and_C1_control_codes
// https://theasciicode.com.ar/

KeyNull                   :: 0
KeyStartOfHeading         :: 1
KeyStartOfText            :: 2
KeyExit                   :: 3 // ctrl-c
KeyEndOfTransimission     :: 4
KeyEnquiry                :: 5
KeyAcknowledge            :: 6
KeyBELL                   :: 7
KeyBackspace              :: 8
KeyHorizontalTabulation   :: 9
KeyLineFeed               :: 10
KeyVerticalTabulation     :: 11
KeyFormFeed               :: 12
KeyCarriageReturn         :: 13
KeyShiftOut               :: 14
KeyShiftIn                :: 15
KeyDataLinkEscape         :: 16
KeyDeviceControl1         :: 17
KeyDeviceControl2         :: 18
KeyDeviceControl3         :: 19
KeyDeviceControl4         :: 20
KeyNegativeAcknowledge    :: 21
KeySynchronousIdle        :: 22
KeyEndOfTransmissionBlock :: 23
KeyCancel                 :: 24
KeyEndOfMedium            :: 25
KeySubstitution           :: 26
KeyEscape                 :: 27
KeyFileSeparator          :: 28
KeyGroupSeparator         :: 29
KeyRecordSeparator        :: 30
KeyUnitSeparator          :: 31
KeyDelete                 :: 127

// All control keys.
Null:      Key_Code: KeyNull
Break:     Key_Code: KeyExit
Enter:     Key_Code: KeyCarriageReturn
Backspace: Key_Code: KeyDelete
Tab:       Key_Code: KeyHorizontalTabulation
Esc:       Key_Code: KeyEscape
Escape:    Key_Code: KeyEscape

CtrlAt: Key_Code: KeyNull
CtrlA:  Key_Code: KeyStartOfHeading
CtrlB:  Key_Code: KeyStartOfText
CtrlC:  Key_Code: KeyExit
CtrlD:  Key_Code: KeyEndOfTransimission
CtrlE:  Key_Code: KeyEnquiry
CtrlF:  Key_Code: KeyAcknowledge
CtrlG:  Key_Code: KeyBELL
CtrlH:  Key_Code: KeyBackspace
CtrlI:  Key_Code: KeyHorizontalTabulation
CtrlJ:  Key_Code: KeyLineFeed
CtrlK:  Key_Code: KeyVerticalTabulation
CtrlL:  Key_Code: KeyFormFeed
CtrlM:  Key_Code: KeyCarriageReturn
CtrlN:  Key_Code: KeyShiftOut
CtrlO:  Key_Code: KeyShiftIn
CtrlP:  Key_Code: KeyDataLinkEscape
CtrlQ:  Key_Code: KeyDeviceControl1
CtrlR:  Key_Code: KeyDeviceControl2
CtrlS:  Key_Code: KeyDeviceControl3
CtrlT:  Key_Code: KeyDeviceControl4
CtrlU:  Key_Code: KeyNegativeAcknowledge
CtrlV:  Key_Code: KeySynchronousIdle
CtrlW:  Key_Code: KeyEndOfTransmissionBlock
CtrlX:  Key_Code: KeyCancel
CtrlY:  Key_Code: KeyEndOfMedium
CtrlZ:  Key_Code: KeySubstitution

CtrlOpenBracket:  Key_Code: KeyEscape
CtrlBackslash:    Key_Code: KeyFileSeparator
CtrlCloseBracket: Key_Code: KeyGroupSeparator
CtrlCaret:        Key_Code: KeyRecordSeparator
CtrlUnderscore:   Key_Code: KeyUnitSeparator
CtrlQuestionMark: Key_Code: KeyDelete

// Other keys.
RuneKey:        Key_Code: -1
Up:             Key_Code: -2
Down:           Key_Code: -3
Right:          Key_Code: -4
Left:           Key_Code: -5
ShiftTab:       Key_Code: -6
Home:           Key_Code: -7
End:            Key_Code: -8
PgUp:           Key_Code: -9
PgDown:         Key_Code: -10
Delete:         Key_Code: -11
Space:          Key_Code: -12
CtrlUp:         Key_Code: -13
CtrlDown:       Key_Code: -14
CtrlRight:      Key_Code: -15
CtrlLeft:       Key_Code: -16
ShiftUp:        Key_Code: -17
ShiftDown:      Key_Code: -18
ShiftRight:     Key_Code: -19
ShiftLeft:      Key_Code: -20
CtrlShiftUp:    Key_Code: -21
CtrlShiftDown:  Key_Code: -22
CtrlShiftLeft:  Key_Code: -23
CtrlShiftRight: Key_Code: -24
F1:             Key_Code: -25
F2:             Key_Code: -26
F3:             Key_Code: -27
F4:             Key_Code: -28
F5:             Key_Code: -29
F6:             Key_Code: -30
F7:             Key_Code: -31
F8:             Key_Code: -32
F9:             Key_Code: -33
F10:            Key_Code: -34
F11:            Key_Code: -35
F12:            Key_Code: -36
F13:            Key_Code: -37
F14:            Key_Code: -38
F15:            Key_Code: -39
F16:            Key_Code: -40
F17:            Key_Code: -41
F18:            Key_Code: -42
F19:            Key_Code: -43
F20:            Key_Code: -44

key_names := map[Key_Code]string {
	// Control keys.
	KeyNull =                   "ctrl+@", // also ctrl+backtick
	KeyStartOfHeading =         "ctrl+a",
	KeyStartOfText =            "ctrl+b",
	KeyExit =                   "ctrl+c",
	KeyEndOfTransimission =     "ctrl+d",
	KeyEnquiry =                "ctrl+e",
	KeyAcknowledge =            "ctrl+f",
	KeyBELL =                   "ctrl+g",
	KeyBackspace =              "ctrl+h",
	KeyHorizontalTabulation =   "tab", // also ctrl+i
	KeyLineFeed =               "ctrl+j",
	KeyVerticalTabulation =     "ctrl+k",
	KeyFormFeed =               "ctrl+l",
	KeyCarriageReturn =         "enter",
	KeyShiftOut =               "ctrl+n",
	KeyShiftIn =                "ctrl+o",
	KeyDataLinkEscape =         "ctrl+p",
	KeyDeviceControl1 =         "ctrl+q",
	KeyDeviceControl2 =         "ctrl+r",
	KeyDeviceControl3 =         "ctrl+s",
	KeyDeviceControl4 =         "ctrl+t",
	KeyNegativeAcknowledge =    "ctrl+u",
	KeySynchronousIdle =        "ctrl+v",
	KeyEndOfTransmissionBlock = "ctrl+w",
	KeyCancel =                 "ctrl+x",
	KeyEndOfMedium =            "ctrl+y",
	KeySubstitution =           "ctrl+z",
	KeyEscape =                 "esc",
	KeyFileSeparator =          "ctrl+\\",
	KeyGroupSeparator =         "ctrl+]",
	KeyRecordSeparator =        "ctrl+^",
	KeyUnitSeparator =          "ctrl+_",
	KeyDelete =                 "backspace",

	// Other keys.
	RuneKey =        "runes",
	Up =             "up",
	Down =           "down",
	Right =          "right",
	Space =          "space",
	Left =           "left",
	ShiftTab =       "shift+tab",
	Home =           "home",
	End =            "end",
	PgUp =           "pgup",
	PgDown =         "pgdown",
	Delete =         "delete",
	CtrlUp =         "ctrl+up",
	CtrlDown =       "ctrl+down",
	CtrlRight =      "ctrl+right",
	CtrlLeft =       "ctrl+left",
	ShiftUp =        "shift+up",
	ShiftDown =      "shift+down",
	ShiftRight =     "shift+right",
	ShiftLeft =      "shift+left",
	CtrlShiftUp =    "ctrl+shift+up",
	CtrlShiftDown =  "ctrl+shift+down",
	CtrlShiftLeft =  "ctrl+shift+left",
	CtrlShiftRight = "ctrl+shift+right",
	F1 =             "f1",
	F2 =             "f2",
	F3 =             "f3",
	F4 =             "f4",
	F5 =             "f5",
	F6 =             "f6",
	F7 =             "f7",
	F8 =             "f8",
	F9 =             "f9",
	F10 =            "f10",
	F11 =            "f11",
	F12 =            "f12",
	F13 =            "f13",
	F14 =            "f14",
	F15 =            "f15",
	F16 =            "f16",
	F17 =            "f17",
	F18 =            "f18",
	F19 =            "f19",
	F20 =            "f20",
}
