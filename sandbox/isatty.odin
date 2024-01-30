package atty

foreign import libc "system:c"

import "core:c"
import "core:fmt"
import "core:os"

foreign libc {
   isatty :: proc(fd: c.int) -> c.int ---
}
   
main :: proc() {
	fmt.println("isatty", isatty(c.int(os.stdout)))
}

