/*
 * Usage: ./ac_cv_func_printf_unix98 && echo "yes" || echo "no"
 */

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char** argv) {
  char buffer[128];

  sprintf (buffer, "%2$d %3$d %1$d", 1, 2, 3);
  if (strcmp ("2 3 1", buffer) == 0)
    exit (0);
  exit (1);
}
