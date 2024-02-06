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
      environ: []cstring
      echo: c.ulong
      icanon: c.ulong
      isatty           :: proc(fd: c.int) -> c.int ---
      wait_data        :: proc(fd: c.int, wait: c.long) -> c.int ---
      get_ioctl        :: proc(fd: c.int, request: c.ulong, value: ^c.int) -> c.int ---
      get_getpgid      :: proc(pid: c.int) -> c.int ---
      get_termios      :: proc(t: ^Termios) -> c.int ---
      set_termios      :: proc(t: ^Termios) -> c.int ---
      enable_raw_mode  :: proc() ---
      disable_raw_mode :: proc() ---
      get_env          :: proc(cstring) -> cstring ---
   }

   is_atty :: proc(fd: os.Handle) -> int {
      return int(isatty(c.int(fd)))
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

   get_env_slice :: proc() -> []string {
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
      //env := get_env_slice()
      //for e in env do fmt.println(e)

      env := get_env_slice2()
      for e in env do fmt.println(e)

      enable_raw_mode()
      defer disable_raw_mode()
      
      fmt.print("query terminal and wait for response...")
      // query the cursor position
      fd := os.stdout
      fmt.fprintf(fd, "\e[6n")
      wait: time.Duration = time.Second
      wait_for_data(int(fd), wait)
      fmt.println("done!")

      fmt.println("COLORFGBG = ", get_env(cstring("COLORFGBG")))

      fmt.println("is atty?", (is_atty(os.stdout) == 1 ? "yes" : "no"))

   }
}
