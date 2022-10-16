/*
 * ./bash_cv_wcwidth_broken && echo 'yes' || echo 'no'
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include <locale.h>
#include <wchar.h>

main(c, v)
int     c;
char    **v;
{
        int     w;

        setlocale(LC_ALL, "en_US.UTF-8");
        w = wcwidth (0x0301);
        exit (w == 0);  /* exit 0 if wcwidth broken */
}
