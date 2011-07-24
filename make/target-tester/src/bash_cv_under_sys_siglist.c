/*
 * ./bash_cv_under_sys_siglist && echo 'yes' || echo 'no'
 */

#include <sys/types.h>
#include <signal.h>
#include <unistd.h>
#ifndef UNDER_SYS_SIGLIST_DECLARED
extern char *_sys_siglist[];
#endif
main()
{
char *msg = (char *)_sys_siglist[2];
exit(msg == 0);
}
