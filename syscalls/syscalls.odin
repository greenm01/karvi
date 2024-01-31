package syscalls

import "core:fmt"

when ODIN_OS == .Linux do foreign import sys "sys.a"

foreign sys {
   get_environ :: proc() -> []cstring ---
}

main :: proc() {
   environ := get_environ()
   defer delete(environ)

   for i in 0 ..= len(environ) {
      if environ[i] == nil do break
      fmt.println(environ[i])
   }

}
