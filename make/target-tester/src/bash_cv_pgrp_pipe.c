/*
 * ./bash_cv_pgrp_pipe && echo "no" || echo "yes"
 */

#include <unistd.h>

#define GETPGRP_VOID 1
#ifdef GETPGRP_VOID
#  define getpgID()	getpgrp()
#else
#  define getpgID()	getpgrp(0)
#  define setpgid(x,y)	setpgrp(x,y)
#endif

main()
{
	int pid1, pid2, fds[2];
	int status;
	char ok;

	switch (pid1 = fork()) {
	  case -1:
	    exit(1);
	  case 0:
	    setpgid(0, getpid());
	    exit(0);
	}
	setpgid(pid1, pid1);

	sleep(2);	/* let first child die */

	if (pipe(fds) < 0)
	  exit(2);

	switch (pid2 = fork()) {
	  case -1:
	    exit(3);
	  case 0:
	    setpgid(0, pid1);
	    ok = getpgID() == pid1;
	    write(fds[1], &ok, 1);
	    exit(0);
	}
	setpgid(pid2, pid1);

	close(fds[1]);
	if (read(fds[0], &ok, 1) != 1)
	  exit(4);
	wait(&status);
	wait(&status);
	exit(ok ? 0 : 5);
}
