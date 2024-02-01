package syscalls

import "core:fmt"
import "core:runtime"
import "core:c/libc"
import "core:strings"

when ODIN_OS == .Linux do foreign import sys "sys.a"

foreign sys {
   get_environ :: proc() -> []cstring ---
}

get_env :: proc(key: string) -> string {
   env := cstring(libc.getenv(strings.clone_to_cstring(key)))
   return string(env)
}

get_env_slice :: proc() -> []string {
   environ := get_environ()
   defer delete(environ)
   e := make([dynamic]string)
   defer delete(e)
   for i in 0 ..= len(environ) {
      if environ[i] == nil do break
      append(&e, cast(string) environ[i])
   }
   return e[:]
}

get_env_slice2 :: proc() -> (env_strs: []string) {
   #no_bounds_check env: [^]cstring = &runtime.args__[len(runtime.args__) + 1]
   length: int
   for ; env[length] != nil; length +=1 {}
   env_strs = make([]string, length)
   for &env_str, i in env_strs {
      env_str = string(env[i])
   }
   return
}

main :: proc() {
   env := get_env_slice()
   for e in env do fmt.println(e)

   fmt.println("****************************")
   fmt.println("****************************")
   fmt.println("****************************")

   env = get_env_slice2()
   for e in env do fmt.println(e)
   
}
