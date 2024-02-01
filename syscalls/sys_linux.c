#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

// https://man7.org/linux/man-pages/man7/environ.7.html
extern char **environ;

char** get_envs() {
  return environ;  
}

// https://manpages.ubuntu.com/manpages/focal/en/man2/select.2.html
int wait_data(int fd, long wait) {
  fd_set rfds;
  struct timeval tv;

  FD_ZERO(&rfds);
  FD_SET(fd, &rfds);
  
  tv.tv_usec = wait;

  return select(fd+1, &rfds, NULL, NULL, &tv);

}
