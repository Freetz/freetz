/*
    eva2bzimage
    Copyright (C) 2017  Sebastian Frei <sebastian@familie-frei.net>
    derived from eva2lzma, derived from
    lzma2eva - convert lzma-compressed file to AVM EVA bootloader format
    Copyright (C) 2007  Enrik Berkhan <Enrik.Berkhan@inka.de>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
*/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

void
usage(void)
{
  fprintf(stderr, "usage: eva2bzimage <evafile> <bzimagefile>\n");
  exit(1);
}

void
pexit(const char *msg)
{
  perror(msg);
  exit(1);
}

int
main(int argc, char *argv[])
{

  FILE *in = NULL, *out = NULL;
  uint8_t buf;

  uint32_t magic = 0xfeed1281L;
  uint32_t reclength = 0;
  uint32_t loadaddress = 0;
  uint32_t checksum = 0;
  uint32_t checksum_calc = 0;
  uint32_t compsize = 0;

  uint32_t zero = 0;
  uint32_t entry = 0;

  if (argc != 3)
    usage();

  /* "parse" command line */
  in = fopen(argv[1], "rb");
  if (!in)
    pexit("fopen");
  out = fopen(argv[2], "w+b");
  if (!out)
    pexit("fopen");

  /* read EVA header */
  if (1 != fread(&magic, sizeof magic, 1, in))
    pexit("fread");
  printf("MAGIC=0x%X\n", magic);
  if (1 != fread(&reclength, sizeof reclength, 1, in))
    pexit("fread");
  printf("RECLENGHT=0x%X\n", reclength);
  if (1 != fread(&loadaddress, sizeof loadaddress, 1, in))
    pexit("fread");
  printf("LOADADDR=0x%X\n",loadaddress);

  checksum_calc = reclength + loadaddress;

  /* copy data, calculate crc32 */
  while (compsize < reclength) {
    if (1 != fread(&buf, sizeof buf, 1, in))
      pexit("fread");
    compsize++;
    if (1 != fwrite(&buf, sizeof buf, 1, out))
      pexit("fwrite");
    checksum_calc += buf;
  }

  checksum_calc = ~checksum_calc + 1;
  printf("CHECKSUM_CALC=0x%X\n", checksum_calc);

  if (1 != fread(&checksum, sizeof checksum, 1, in))
    pexit("fread");
  printf("CHECKSUM=0x%X\n", checksum);

  if (1 != fread(&zero, sizeof zero, 1, in))
    pexit("fread");
  printf("ZERO=0x%X\n", zero);
  if (1 != fread(&entry, sizeof entry, 1, in))
    pexit("fread");
  printf("ENTRY=0x%X\n", entry);

  fclose(in);

  if (fclose(out))
    pexit("fclose");

  return 0;
}
