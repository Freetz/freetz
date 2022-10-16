#include "cksum.h"

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

#ifndef O_BINARY
#define O_BINARY 0
#endif

int
main (int argc, char **argv)
{
  int fd;
  int fn_ind = 1;
  char const *fn;

  uint32_t calculated_sum = 0;
  uint32_t saved_sum = 0;

  enum action {
    ACT_DEFAULT,
    ACT_ADD,
    ACT_ADD_FORCIBLE,
    ACT_VERIFY,
    ACT_REMOVE,
    ACT_ERR,
  } act = ACT_DEFAULT;

  int rc = CS_FAILURE;

  if (argc > 1 && argv[1][0] == '-') {
    switch (argv[1][1]) {
    case 'a':
      act = (argv[1][2] == 'a') ? ACT_ADD_FORCIBLE : ACT_ADD;
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
    printf ("Usage: %s [-a|-aa|-v|-r|--] filename\n", argv[0]);
    return CS_FAILURE;
  }

  fn = argv[fn_ind];
  fd = open (fn, act == ACT_VERIFY ? O_RDONLY|O_BINARY : O_RDWR|O_BINARY);
  if (fd < 0) {
    perror (fn);
    return CS_TECHNICAL_ERROR;
  }

  if (act == ACT_DEFAULT) {
    if (cs_is_tagged (fd, NULL, NULL) == FALSE) {
      printf ("File doesn't contain the checksum, adding\n");
      act = ACT_ADD;
    } else {
      printf ("File already contains the checksum, verifying\n");
      act = ACT_VERIFY;
    }
  }

  switch (act) {
  case ACT_ADD:
  case ACT_ADD_FORCIBLE:
    rc = cs_add_sum (fd, &calculated_sum, act == ACT_ADD_FORCIBLE);
    if (rc == CS_SUCCESS) {
      printf ("Calculated checksum is 0x%08X\n", calculated_sum);
      printf ("Added successfully\n");
    } else {
      if (rc == CS_FAILURE) {
        printf ("File already contains the checksum\n");
      }
      printf ("Adding failed\n");
    }
    break;

  case ACT_VERIFY:
    rc = cs_verify_sum (fd, &calculated_sum, &saved_sum);
    if (rc != CS_TECHNICAL_ERROR && (calculated_sum != 0 || saved_sum !=0)) {
      printf ("Calculated checksum is 0x%08X\n", calculated_sum);
      printf ("Saved checksum is 0x%08X\n", saved_sum);
    }
    if (rc == CS_SUCCESS) {
      printf ("Checksum validation successful\n");
    } else {
      printf ("Checksum validation failed\n");
    }
    break;

  case ACT_REMOVE:
    rc = cs_remove_sum (fd, NULL);
    if (rc == CS_SUCCESS) {
      printf ("Checksum remove successful\n");
    } else {
      printf ("Checksum remove failed\n");
    }
    break;

  default:
    rc = CS_FAILURE;
    break;
  }

  close (fd);

  return rc;
}
