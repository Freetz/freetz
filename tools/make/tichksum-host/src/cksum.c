#include "cksum.h"
#include <sys/stat.h>

#define BUFLEN (1 << 16)

#define MAGIC_NUMBER 0xC453DE23

typedef struct cksum_t {
  uint8_t ck_magic[4];
  uint8_t ck_crc[4];
} cksum_t;

/*
 * Build crc table. Takes about 0.02ms on a 7170
 * Standard CRC32 Polynom: x32 + x26 + x23 + x22 + x16 + x12 + x11 + x10 + x8 + x7 + x5 + x4 + x2 + x1 + x0 = 0x104C11DB7
 */
void
crctab_init (uint32_t *crctab)
{
  uint32_t poly = (uint32_t)0x104C11DB7;
  uint32_t i;
  crctab[0] = 0;
  for (i = 1; i < 0x100; i++) {
    uint32_t prev = i / 2;
    uint32_t crc = crctab[prev];
    uint32_t c = (crc >> 31) ^ (i & 1);
    crc <<= 1;
    if (c & 1)
      crc ^= poly;
    crctab[i] = crc;
  }
}

uint32_t
get_le32 (void *p)
{
  uint8_t *cp = p;
  return (cp[0] << (0 * 8)) | (cp[1] << (1 * 8)) | (cp[2] << (2 * 8)) | (cp[3] << (3 * 8));
}

void
set_le32 (void *p, uint32_t v)
{
  uint8_t *cp = p;
  cp[0] = v >> (0 * 8);
  cp[1] = v >> (1 * 8);
  cp[2] = v >> (2 * 8);
  cp[3] = v >> (3 * 8);
}

// return 1: tagged, 0: not tagged, -1: error
int
cs_is_tagged (int fd, uint32_t *sum, off_t *length)
{
  cksum_t cksum;
  off_t len;

  len = lseek (fd, -sizeof (cksum_t), SEEK_END);
  if (len < 0)
    return -1;
  int is_tagged =
    read (fd, &cksum, sizeof (cksum_t)) == sizeof (cksum_t)
    && get_le32 (cksum.ck_magic) == MAGIC_NUMBER;
  if (is_tagged) {
    if (sum)
      *sum = get_le32 (cksum.ck_crc);
    if (length)
      *length = len;
  }
  return is_tagged;
}

#define ADD_CRC(crc, val) ({				\
uint32_t _crc = (crc);					\
uint8_t _val = (val);					\
_crc = (_crc << 8) ^ crctab[(_crc >> 24) ^ _val];	\
(crc) = _crc;						\
})

// return -1: error, 0: ok
// cksum only valig for tagged files
int
cs_calc_sum (int fd, uint32_t *sum, cksum_t *cksum)
{
  uint8_t buf[BUFLEN];
  uint32_t crc = 0;
  uint32_t crctab[0x100];
  off_t length, pos;
  struct stat st;
  long buflen;

  if (fstat (fd, &st) < 0)
    return -1;
  length = st.st_size;
  if (cksum)
    length -= sizeof (cksum_t);
  if (length < 0)
    return -1;
  if (lseek (fd, 0, SEEK_SET) != 0)
    return -1;

  crctab_init (crctab);
  for (pos = 0; pos < length; pos += buflen) {
    uint8_t *cp = buf;
    int i;
    buflen = sizeof (buf);
    if (buflen > length - pos)
      buflen = length - pos;
    if (read (fd, buf, buflen) != buflen)
      return -1;
    for (i = 0; i < buflen; ++i, ++cp)
      ADD_CRC (crc, *cp);
  }

  for (; length; length >>= 8)
    ADD_CRC (crc, length);

  crc = ~crc & 0xFFFFFFFF;

  *sum = crc;

  if (cksum) {
    if (read (fd, cksum, sizeof (cksum_t)) != sizeof (cksum_t)
       || get_le32 (cksum->ck_magic) != MAGIC_NUMBER)
      return -1;
  }

  return 0;
}

// return -1: error, 0: ok
int
cs_add_sum (int fd, uint32_t *sum)
{
  cksum_t cksum;

  if (cs_calc_sum (fd, sum, NULL))
    return -1;
  set_le32 (cksum.ck_magic, MAGIC_NUMBER);
  set_le32 (cksum.ck_crc, *sum);
  if (write (fd, &cksum, sizeof (cksum_t)) != sizeof (cksum_t))
    return -1;
  return 0;
}

// return -1: error, 0: cs bad, 1: cs good
int
cs_verify_sum (int fd, uint32_t *sum, uint32_t *res)
{
  cksum_t cksum;

  if (cs_calc_sum (fd, sum, &cksum))
    return -1;
  *res = get_le32 (cksum.ck_crc);
  return *sum == *res;
}

// return -1: error, 0: ok
int
cs_remove_sum (int fd, uint32_t *res)
{
  off_t length;

  if (cs_is_tagged (fd, res, &length) != 1)
    return -1;
  if (ftruncate (fd, length))
    return -1;
  return 0;
}
