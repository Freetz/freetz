/*
 * ./bash_cv_getenv_redef && echo 'yes' || echo 'no'
 */

#define HAVE_UNISTD_H 1
#ifdef HAVE_UNISTD_H
#  include <unistd.h>
#endif
#ifndef __STDC__
#  ifndef const
#    define const
#  endif
#endif
char *
getenv (name)
#if defined (__linux__) || defined (__bsdi__) || defined (convex)
     const char *name;
#else
     char const *name;
#endif /* !__linux__ && !__bsdi__ && !convex */
{
return "42";
}
main()
{
char *s;
/* The next allows this program to run, but does not allow bash to link
   when it redefines getenv.  I'm not really interested in figuring out
   why not. */
#if defined (NeXT)
exit(1);
#endif
s = getenv("ABCDE");
exit(s == 0);	/* force optimizer to leave getenv in */
}
