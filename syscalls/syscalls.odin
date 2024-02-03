package syscalls

import "core:os"
import "core:fmt"
import "core:runtime"
import "core:c"
import "core:c/libc"
import "core:strings"
import "core:time"
import "core:sys/unix"

when ODIN_OS == .Linux {

   SYS_ioctl :: unix.SYS_ioctl

   foreign import system "sys_linux.a"

   foreign system {
      get_envs      :: proc() -> []cstring ---
      wait_data     :: proc(fd: c.int, wait: c.long) -> c.int ---
      get_ioctl     :: proc(fd: c.int, request: c.ulong, value: ^c.int) -> c.int ---
      get_getpgid   :: proc(pid: c.int) -> c.int ---
      ioctl_termios :: proc(number: c.long, fd: c.uint, req: c.uint, arg: ^Termios) -> c.long ---
   }

   // https://github.com/openbsd/src/blob/master/sys/sys/termios.h

   Termios :: struct {
      c_iflag : c.ulong,     /* input mode flags */ 
      c_oflag : c.ulong,     /* output mode flags */
      c_cflag : c.ulong,     /* control mode flags */
      c_lflag : c.ulong,     /* local mode flags */
      c_line  : c.uchar,     /* line discipline */
      c_cc    : [19]c.uchar, /* control characters */
      c_ispeed: c.int,       /* input speed */
      c_ospeed: c.int,       /* output speed */
   }

   ioctl_set_termios :: proc(fd: int, req: int, t: ^Termios) -> (err: int) {
      err = int(ioctl_termios(c.long(SYS_ioctl), c.uint(fd), c.uint(req), t))
      return
   }
   
   ioctl_get_termios :: proc(fd: int, req: uint) -> (t: ^Termios, err: int) {
      t = new(Termios)
      err = int(ioctl_termios(c.long(SYS_ioctl), c.uint(fd), c.uint(req), t))
      return
   }   

   getpgrp :: proc() -> int {
      return int(get_getpgid(0))
   }

   ioctl :: proc(fd: int, request: uint) -> (value: int, err: int) {
      v: c.int
      err = int(get_ioctl(c.int(fd), c.ulong(request), &v))
      value = int(v)
      return 
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

      t, err := ioctl_get_termios(1, 0x5401)
      fmt.println(t, "err =", err)

   }

}
