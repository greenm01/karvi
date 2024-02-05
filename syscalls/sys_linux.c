#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <termios.h>

// https://man7.org/linux/man-pages/man7/environ.7.html
extern char **environ;
extern unsigned long echo = ECHO;
extern unsigned long icanon = ICANON;

// https://www.gnu.org/software/libc/manual/html_node/Waiting-for-I_002fO.html
int wait_data(int fd, long wait) {
  fd_set rfds;
  struct timeval tv;

  FD_ZERO(&rfds);
  FD_SET(STDIN_FILENO, &rfds);

  tv.tv_sec = 1;
  tv.tv_usec = wait;

  return select(FD_SETSIZE, &rfds, NULL, NULL, &tv);
}

char* get_env(char* s) {
  return getenv(s);  
}

int get_ioctl(int fd, unsigned long request, int *value) {
  return ioctl(fd, request, value);
}

int get_getpgid(int pid) {
  return getpgid(pid);
}

// https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html
int get_termios(struct termios *t) {
  return tcgetattr(STDOUT_FILENO, t);
}

int set_termios(struct termios *t) {
  return tcsetattr(STDOUT_FILENO, TCSAFLUSH, t);
}

struct termios orig_termios;

void disable_raw_mode() {
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
}

void enable_raw_mode() {
  tcgetattr(STDIN_FILENO, &orig_termios);
  //atexit(disable_raw_mode);
  struct termios raw = orig_termios;
  raw.c_lflag &= ~(ECHO | ICANON);
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}
