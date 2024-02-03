package karvi

import "core:strings"

// Notify triggers a notification using OSC777.
notify :: proc(title, body: string) {
	output_notify(output, title, body)
}

// Notify triggers a notification using OSC777.
output_notify :: proc(o: ^Output, title, body: string) {
	write_string(o, strings.concatenate([]string{OSC, "777;notify;", title, ";", body, ST}))
}
