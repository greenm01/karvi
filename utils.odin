package karvi

import "core:strings"

int_to_string :: proc(i: int) -> string {
	builder := strings.builder_make()
	strings.write_int(&builder, i)
	return strings.to_string(builder)
}

write_byte_to_string :: proc(s: string, b: byte) -> string {
	builder := strings.builder_make()
	strings.write_string(&builder, s)
	strings.write_byte(&builder, b)
	return strings.to_string(builder)
}

