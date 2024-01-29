package karvi

import "core:fmt"

main :: proc() {
   color := new_ansi_color(2)
   fmt.println("compile success")
   fmt.println("Ansi color =", color.c)
}
