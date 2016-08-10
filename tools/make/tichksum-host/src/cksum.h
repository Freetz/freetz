#ifndef CKSUM_H
#define CKSUM_H

#include <stdint.h>
#include <sys/types.h>

int cs_is_tagged  (int fd, uint32_t *saved_sum, off_t *payload_length);
int cs_add_sum    (int fd, uint32_t *calculated_sum);
int cs_verify_sum (int fd, uint32_t *calculated_sum, uint32_t *saved_sum);
int cs_remove_sum (int fd, uint32_t *saved_sum);

#endif
