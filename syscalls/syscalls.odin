package syscalls

import "core:os"
import "core:fmt"
import "core:runtime"
import "core:c"
import "core:c/libc"
import "core:strings"
import "core:time"

when ODIN_OS == .Linux {

   foreign import system "sys_linux.a"

   foreign system {
      get_envs :: proc() -> []cstring ---
      wait_data   :: proc(fd: c.int, wait: c.long) -> c.int --- 
   }

   wait_for_data :: proc(fd: int, wait: time.Duration) -> int {
      usec := time.duration_microseconds(wait)
      return int(wait_data(c.int(fd), c.long(usec)))
   }

   get_env :: proc(key: string) -> string {
      env := cstring(libc.getenv(strings.clone_to_cstring(key)))
      return string(env)
   }

   get_env_slice :: proc() -> []string {
      environ := get_envs()
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

      fmt.print("waiting for terminal data (press Enter)...")
      wait: time.Duration = time.Second * 10
      wait_for_data(int(os.stdin), wait)
      fmt.println("done!")

   }

}
