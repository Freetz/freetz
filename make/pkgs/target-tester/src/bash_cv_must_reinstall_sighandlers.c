/*
 * ./bash_cv_must_reinstall_sighandlers && echo 'no' || echo 'yes'
 */

#include <signal.h>
#include <unistd.h>

#define RETSIGTYPE void
typedef RETSIGTYPE sigfunc();

int nsigint;

#define HAVE_POSIX_SIGNALS 1
#ifdef HAVE_POSIX_SIGNALS
sigfunc *
set_signal_handler(sig, handler)
     int sig;
     sigfunc *handler;
{
  struct sigaction act, oact;
  act.sa_handler = handler;
  act.sa_flags = 0;
  sigemptyset (&act.sa_mask);
  sigemptyset (&oact.sa_mask);
  sigaction (sig, &act, &oact);
  return (oact.sa_handler);
}
#else
#define set_signal_handler(s, h) signal(s, h)
#endif

RETSIGTYPE
sigint(s)
int s;
{
  nsigint++;
}

main()
{
	nsigint = 0;
	set_signal_handler(SIGINT, sigint);
	kill((int)getpid(), SIGINT);
	kill((int)getpid(), SIGINT);
	exit(nsigint != 2);
}
