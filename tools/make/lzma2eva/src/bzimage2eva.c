/*
    bzimage2eva
    Copyright (C) 2017  Sebastian Frei <sebastian@familie-frei.net>
    derived from

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
  fprintf(stderr, "usage: bzimage2eva <loadadddr> <entry> <bzimagefile> <evafile>\n");
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

  const char *infile, *outfile;
  FILE *in, *out;
  uint8_t buf[4096];
  size_t elems;

  uint32_t magic = 0xfeed8112L;
  uint32_t reclength = 0;
  fpos_t reclengthpos;
  uint32_t loadaddress = 0;
  uint32_t checksum = 0;

  uint32_t compsize = 0;

  uint32_t zero = 0;
  uint32_t entry = 0;

  if (argc != 5)
    usage();

  /* "parse" command line */
  loadaddress = strtoul(argv[1], 0, 0);
  entry = strtoul(argv[2], 0, 0);
  infile = argv[3];
  outfile = argv[4];

  in = fopen(infile, "rb");
  if (!in)
    pexit("fopen");
  out = fopen(outfile, "w+b");
  if (!out)
    pexit("fopen");

  /* write EVA header */
  if (1 != fwrite(&magic, sizeof magic, 1, out))
    pexit("fwrite");
  if (fgetpos(out, &reclengthpos))
    pexit("fgetpos");
  if (1 != fwrite(&reclength, sizeof reclength, 1, out))
    pexit("fwrite");
  if (1 != fwrite(&loadaddress, sizeof loadaddress, 1, out))
    pexit("fwrite");

  /* copy compressed data */
  while (0 < (elems = fread(&buf, sizeof buf[0], sizeof buf, in))) {
    compsize += elems;
    if (elems != fwrite(&buf, sizeof buf[0], elems, out))
      pexit("fwrite");
  }
  if (ferror(in))
    pexit("fread");
  fclose(in);

  /* re-write record length */
  reclength = compsize;
  if (fsetpos(out, &reclengthpos))
    pexit("fsetpos");
  if (1 != fwrite(&reclength, sizeof reclength, 1, out))
    pexit("fwrite");

  /* calculate record checksum */
  checksum += reclength;
  checksum += loadaddress;
  if (fseek(out, 4, SEEK_CUR)) // skip loadaddress
    pexit("fseek");
  while (0 < (elems = fread(&buf, sizeof buf[0], sizeof buf, out))) {
    size_t i;
    for (i = 0; i < elems; ++i)
      checksum += buf[i];
  }
  if (ferror(out))
    pexit("fread");
  if (fseek(out, 0, SEEK_CUR))
    pexit("fseek");

  checksum = ~checksum + 1;
  if (1 != fwrite(&checksum, sizeof checksum, 1, out))
    pexit("fwrite");

  /* write entry record */
  if (1 != fwrite(&zero, sizeof zero, 1, out))
    pexit("fwrite");
  if (1 != fwrite(&entry, sizeof entry, 1, out))
    pexit("fwrite");

  if (fclose(out))
    pexit("fclose");

  return 0;
}
