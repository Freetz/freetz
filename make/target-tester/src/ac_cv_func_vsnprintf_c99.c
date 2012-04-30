/*
 * Usage: ./ac_cv_func_vsnprintf_c99 && echo "yes" || echo "no"
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

int doit(char * s, ...) {
  char buffer[32];
  va_list args;
  int r;

  va_start(args, s);
  r = vsnprintf(buffer, 5, s, args);
  va_end(args);

  if (r != 7)
    exit(1);

  /* AIX 5.1 and Solaris seems to have a half-baked vsnprintf()
     implementation. The above will return 7 but if you replace
     the size of the buffer with 0, it borks! */
  va_start(args, s);
  r = vsnprintf(buffer, 0, s, args);
  va_end(args);

  if (r != 7)
    exit(1);

  exit(0);
}

int main(int argc, char** argv) {
  doit("1234567");
  exit(1);
}
