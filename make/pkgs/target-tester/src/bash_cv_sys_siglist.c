/*
 * ./bash_cv_sys_siglist && echo 'yes' || echo 'no'
 */

#include <sys/types.h>
#include <signal.h>
#include <unistd.h>
#ifndef SYS_SIGLIST_DECLARED
extern char *sys_siglist[];
#endif
main()
{
char *msg = sys_siglist[2];
exit(msg == 0);
}
