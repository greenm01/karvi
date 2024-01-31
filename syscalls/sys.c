#include <stdio.h>

// https://man7.org/linux/man-pages/man7/environ.7.html
extern char **environ;

char** get_environ() {
  return environ;  
}
