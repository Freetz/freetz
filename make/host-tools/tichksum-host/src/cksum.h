#ifndef CKSUM_H
#define CKSUM_H

#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>

#ifndef FALSE
#define FALSE (0)
#endif

#ifndef TRUE
#define TRUE (1)
#endif

enum {
  /* indicates technical errors like unsucessful open, seek, read, write, etc. */
  CS_TECHNICAL_ERROR = -1,

  /* indicates successful execution of the requested operation */
  CS_SUCCESS         = EXIT_SUCCESS,

  /* indicates unsuccessful execution of the requested operation */
  CS_FAILURE         = EXIT_FAILURE
};

/*
 * returns
 *   CS_TECHNICAL_ERROR, FALSE, TRUE
 */
int cs_is_tagged  (int fd, uint32_t *saved_sum, off_t *payload_length);

/*
 * returns
 *   CS_TECHNICAL_ERROR, CS_SUCCESS (adding succeeded), CS_FAILURE (file already contains the checksum)
 */
int cs_add_sum    (int fd, uint32_t *calculated_sum, int force);

/*
 * returns
 *   CS_TECHNICAL_ERROR, CS_SUCCESS (cs identical), CS_FAILURE (cs different or file doesn't contain the checksum)
 */
int cs_verify_sum (int fd, uint32_t *calculated_sum, uint32_t *saved_sum);

/*
 * returns
 *  CS_TECHNICAL_ERROR, CS_SUCCESS (cs removed), CS_FAILURE (file doesn't contain the checksum)
 */
int cs_remove_sum (int fd, uint32_t *saved_sum);

#endif
