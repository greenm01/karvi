#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <termios.h>
#include <signal.h>
#include <errno.h>
#include <string.h>

// https://man7.org/linux/man-pages/man7/environ.7.html
extern char **environ;
extern unsigned long echo = ECHO;
extern unsigned long icanon = ICANON;

#define OK                   0
#define TTY_EVENT            1
#define RESIZE_EVENT         2
#define ERR                  -1
#define ERR_NO_EVENT         -2
#define ERR_RESIZE_PIPE      -3
#define ERR_RESIZE_SIGACTION -4
#define ERR_POLL             -5

struct global_t {
  int resize_pipefd[2];
  int last_errno;
};

static struct global_t global = {0};

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

int tc_flush(int fd) {
  tcflush(fd, TCIOFLUSH);  
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

struct winsize get_screen_size(int fd) {
    struct winsize ws;
    ioctl(fd, TIOCGWINSZ, &ws);
    return ws;
}

unsigned short get_screen_width(int fd) {
    struct winsize ws = get_screen_size(fd);
    return ws.ws_col;
}

unsigned short get_screen_height(int fd) {
    struct winsize ws = get_screen_size(fd);
    return ws.ws_row;
}

static int init_global(void) {
  memset(&global, 0, sizeof(global));
  global.resize_pipefd[0] = -1;
  global.resize_pipefd[1] = -1;
  return OK;
}

// write resize events to pipe
static void handle_resize(int sig) {
    int errno_copy = errno;
    write(global.resize_pipefd[1], &sig, sizeof(sig));
    errno = errno_copy;
}

int init_event_handler() {
    init_global();
  
    if (pipe(global.resize_pipefd) < 0) {
        global.last_errno = errno;
        return ERR_RESIZE_PIPE;
    }
    
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_resize;
    if (sigaction(SIGWINCH, &sa, NULL) != 0) {
        global.last_errno = errno;
        return ERR_RESIZE_SIGACTION;
    }

    return OK;
}

int close_event_handler() {
  sigaction(SIGWINCH, &(struct sigaction){.sa_handler = SIG_DFL}, NULL);
  if (global.resize_pipefd[0] >= 0) close(global.resize_pipefd[0]);
  if (global.resize_pipefd[1] >= 0) close(global.resize_pipefd[1]);
  return OK;
}

// wait for system events. timeout in ms
int wait_event(int timeout) {
  fd_set fds;
  struct timeval tv;
  tv.tv_sec = timeout / 1000;
  tv.tv_usec = (timeout - (tv.tv_sec * 1000)) * 1000;
  
  do {
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds);
    FD_SET(global.resize_pipefd[0], &fds);

    int maxfd = global.resize_pipefd[0] > STDIN_FILENO 
                        ? global.resize_pipefd[0]
                        : STDIN_FILENO;

    int select_rv =
        select(maxfd + 1, &fds, NULL, NULL, (timeout < 0) ? NULL : &tv);

    if (select_rv < 0) {
        // Let EINTR/EAGAIN bubble up
        global.last_errno = errno;
        return ERR_POLL;
    } else if (select_rv == 0) {
        return ERR_NO_EVENT;
    }

    int resize_has_events = (FD_ISSET(global.resize_pipefd[0], &fds));
    int tty_has_events = (FD_ISSET(STDIN_FILENO, &fds));

    if (tty_has_events) {
      return TTY_EVENT;
    }

    if (resize_has_events) {
        int ignore = 0;
        read(global.resize_pipefd[0], &ignore, sizeof(ignore));
        return RESIZE_EVENT;
    }
    
  } while (timeout == -1);

  return ERR;
  
}
