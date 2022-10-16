/*
 * ./bash_cv_getcwd_malloc && echo 'yes' || echo 'no'
 */

#include <stdio.h>
#include <unistd.h>

main()
{
	char	*xpwd;
	xpwd = getcwd(0, 0);
	exit (xpwd == 0);
}
