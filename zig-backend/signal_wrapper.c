#include <signal.h>

int set_sigchld_ign(void) {
    return (int)(long)signal(SIGCHLD, SIG_IGN);
}
