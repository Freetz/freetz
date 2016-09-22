#include "cksum.h"

#include <unistd.h>

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

int
cs_is_tagged (int fd, uint32_t *saved_sum, off_t *payload_length)
{
  cksum_t cksum;
  off_t len;

  len = lseek (fd, 0, SEEK_END);
  if (len < 0)
    return CS_TECHNICAL_ERROR;

  if (payload_length)
    *payload_length = len;

  if (len < (off_t) sizeof (cksum_t))
    return FALSE;

  len = lseek (fd, len - sizeof (cksum_t), SEEK_SET);
  if (len < 0)
    return CS_TECHNICAL_ERROR;
  if (read(fd, &cksum, sizeof (cksum_t)) != sizeof (cksum_t))
    return CS_TECHNICAL_ERROR;

  if (get_le32 (cksum.ck_magic) != MAGIC_NUMBER)
    return FALSE;

  if (saved_sum)
    *saved_sum = get_le32 (cksum.ck_crc);
  if (payload_length)
    *payload_length -= sizeof (cksum_t);

  return TRUE;
}

#define ADD_CRC(crc, val) ({				\
uint32_t _crc = (crc);					\
uint8_t _val = (val);					\
_crc = (_crc << 8) ^ crctab[(_crc >> 24) ^ _val];	\
(crc) = _crc;						\
})

#define BUFLEN (1 << 16)

static
int
cs_calc_sum (int fd, off_t payload_length, uint32_t *calculated_sum)
{
  uint8_t buf[BUFLEN];
  uint32_t crc = 0;
  uint32_t crctab[0x100];
  off_t  pos;
  long buflen;

  if (payload_length < 0 || lseek (fd, 0, SEEK_SET) != 0)
    return CS_TECHNICAL_ERROR;

  crctab_init (crctab);
  for (pos = 0; pos < payload_length; pos += buflen) {
    uint8_t *cp = buf;
    int i;
    buflen = sizeof (buf);
    if (buflen > payload_length - pos)
      buflen = payload_length - pos;
    if (read (fd, buf, buflen) != buflen)
      return CS_TECHNICAL_ERROR;
    for (i = 0; i < buflen; ++i, ++cp)
      ADD_CRC (crc, *cp);
  }

  for (; payload_length; payload_length >>= 8)
    ADD_CRC (crc, payload_length);

  crc = ~crc & 0xFFFFFFFF;

  *calculated_sum = crc;

  return CS_SUCCESS;
}

int
cs_add_sum (int fd, uint32_t *calculated_sum, int force)
{
  off_t payload_length;
  cksum_t cksum;
  int rc;

  rc = cs_is_tagged (fd, NULL, &payload_length);
  if (rc == CS_TECHNICAL_ERROR)
    return CS_TECHNICAL_ERROR;
  if (rc == TRUE) {
    if (!force)
      return CS_FAILURE;

    payload_length += sizeof (cksum_t);
  }

  rc = cs_calc_sum (fd, payload_length, calculated_sum);
  if (rc != CS_SUCCESS)
    return rc;

  set_le32 (cksum.ck_magic, MAGIC_NUMBER);
  set_le32 (cksum.ck_crc, *calculated_sum);
  if (write (fd, &cksum, sizeof (cksum_t)) != sizeof (cksum_t))
    return CS_TECHNICAL_ERROR;

  return CS_SUCCESS;
}

int
cs_verify_sum (int fd, uint32_t *calculated_sum, uint32_t *saved_sum)
{
  off_t payload_length;
  int rc;

  rc = cs_is_tagged (fd, saved_sum, &payload_length);
  if (rc == CS_TECHNICAL_ERROR)
    return CS_TECHNICAL_ERROR;
  if (rc == FALSE)
    return CS_FAILURE;

  rc = cs_calc_sum (fd, payload_length, calculated_sum);
  if (rc != CS_SUCCESS)
    return rc;

  return (*calculated_sum == *saved_sum) ? CS_SUCCESS : CS_FAILURE;
}

int
cs_remove_sum (int fd, uint32_t *saved_sum)
{
  off_t payload_length;
  int rc;

  rc = cs_is_tagged (fd, saved_sum, &payload_length);
  if (rc == CS_TECHNICAL_ERROR)
    return CS_TECHNICAL_ERROR;
  if (rc == FALSE)
    return CS_FAILURE;

  if (ftruncate (fd, payload_length))
    return CS_TECHNICAL_ERROR;

  return CS_SUCCESS;
}
