#ifndef CKSUM_H
#define CKSUM_H

#include <stdint.h>
#include <sys/types.h>

int cs_is_tagged (int fd, uint32_t *sum, off_t *length);
int cs_add_sum (int fd, uint32_t *sum);
int cs_verify_sum (int fd, uint32_t *sum, uint32_t *res);
int cs_remove_sum (int fd, uint32_t *res);

#endif
