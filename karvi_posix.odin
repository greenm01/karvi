package karvi

import sys "syscalls"
// darwin || dragonfly || freebsd || linux || netbsd || openbsd

is_foreground :: proc(fd: int) -> bool {
	TIOCGPGRP :: 0x540f
	pgrp, err := sys.ioctl(fd, TIOCGPGRP)
	if err != 0 {
		return false
	}

	return pgrp == sys.getpgrp()
}
