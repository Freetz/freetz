
#include "cksum.h"
#include <stdio.h>
#include <fcntl.h>
#ifndef O_BINARY
#define O_BINARY 0
#endif

int
main (int argc, char **argv)
{
  int fd;
  uint32_t sum;
  uint32_t res;
  int fn_ind = 1;
  int status;
  enum action {
    ACT_DEFAULT,
    ACT_ADD,
    ACT_VERIFY,
    ACT_REMOVE,
    ACT_ERR,
  } act = ACT_DEFAULT;
  char const *fn;

  if (argc > 1 && argv[1][0] == '-') {
    switch (argv[1][1]) {
    case 'a':
      act = ACT_ADD;
      break;
    case 'v':
      act = ACT_VERIFY;
      break;
    case 'r':
      act = ACT_REMOVE;
      break;
    case '-':
      break;
    default:
      act = ACT_ERR;
      break;
    }
    fn_ind++;
  }
  if (argc <= fn_ind || act == ACT_ERR) {
    printf ("Usage: %s [-a|-v|-r|--] filename\n", argv[0]);
    return 1;
  }
  fn = argv[fn_ind];

  fd = open (fn, act == ACT_VERIFY ? O_RDONLY|O_BINARY : O_RDWR|O_BINARY);
  if (fd < 0) {
    perror (fn);
    return 1;
  }

  if (act == ACT_DEFAULT) {
    if (!cs_is_tagged (fd, NULL, NULL)) {
      printf ("File doesn't contain the checksum, adding\n");
      act = ACT_ADD;
    }
    else {
      printf ("File already contains the checksum, verifying\n");
      act = ACT_VERIFY;
    }
  }

  switch (act) {
  case ACT_ADD:
    status = cs_add_sum (fd, &sum);
    if (status < 0)
      printf ("Adding failed\n");
    else {
      printf ("Calculated checksum is %08X\n", sum);
      printf ("Added successfully\n");
    }
    break;
  case ACT_VERIFY:
    status = cs_verify_sum (fd, &sum, &res);
    if (status >= 0) {
      printf ("Calculated checksum is %08X\n", sum);
      printf ("Saved checksum is %X\n", res);
    }
    if (status > 0)
      printf ("Checksum validation successful\n");
    else
      printf ("Checksum validation failed\n");
    break;
  case ACT_REMOVE:
    status = cs_remove_sum (fd, NULL);
    if (status < 0)
      printf ("Checksum remove failed\n");
    else
      printf ("Checksum remove successful\n");
    break;
    
  default:
    status = 3;
    break;
  }
  close (fd);

  return status;
}
