/*
 * ./bash_cv_printf_a_format && echo 'yes' || echo 'no'
 */

#include <stdio.h>
#include <string.h>

int
main()
{
	double y = 0.0;
	char abuf[1024];

	sprintf(abuf, "%A", y);
	exit(strchr(abuf, 'P') == (char *)0);
}
