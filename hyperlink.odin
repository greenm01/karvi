package karvi

import "core:strings"

// Hyperlink creates a hyperlink using OSC8.
hyperlink :: proc(link, name: string) -> string {
	return strings.concatenate([]string{OSC, "8;;", link, ST, name, OSC, "8;;", ST})
}
