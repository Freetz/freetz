/*
eva2lzma derived from
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
//#include <zlib.h> /* crc32 */
#include <elf.h>

#define checksum_add32(csum, data) \
  csum += ((uint8_t *)&data)[0]; \
  csum += ((uint8_t *)&data)[1]; \
  csum += ((uint8_t *)&data)[2]; \
  csum += ((uint8_t *)&data)[3];

void
usage(void)
{
  fprintf(stderr, "usage: eva2lzma <evafile> <lzmafile> [headerfile]\n");
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

  FILE *in = NULL, *out = NULL, *out_optional = NULL;
  uint8_t buf[4096];
  size_t elems;
  Elf32_Ehdr e;
  Elf32_Phdr p;

  uint8_t properties;
  uint32_t dictsize;
  uint64_t datasize;

  uint32_t magic = 0xfeed1281L;
  uint32_t reclength = 0;
  fpos_t reclengthpos;
  fpos_t reclengthpos2;
  uint32_t loadaddress = 0;
  uint32_t type = 0x075a0201L; /* might be 7Z 2.1? */
  uint32_t checksum = 0;

  uint32_t compsize = 0;
  uint32_t compsize2 = 0;
  fpos_t compsizepos;
  uint32_t datasize32 = 0;
  uint32_t datacrc32 = 0; // crc32(0, 0, 0);

  uint32_t zero = 0;
  uint32_t entry = 0;

  if (argc != 3 && argc != 4)
    usage();

  // prepare elf header
  e.e_ident[0]=0x7F;
  e.e_ident[1]='E';
  e.e_ident[2]='L';
  e.e_ident[3]='F';
  e.e_ident[4]=1;
  e.e_ident[5]=1;
  e.e_ident[6]=1;
  e.e_ident[7]=0;

  e.e_ident[8]=0;
  e.e_ident[9]=0;
  e.e_ident[10]=0;
  e.e_ident[11]=0;
  e.e_ident[12]=0;
  e.e_ident[13]=0;
  e.e_ident[14]=0;
  e.e_ident[15]=0;
  e.e_type=1;
  e.e_machine=8;
  e.e_version=1;
  e.e_entry=0; // will be changed
  e.e_phoff=0x34;
  e.e_shoff=0; // simplified
  e.e_flags=0x50001001;
  e.e_ehsize=0x34;
  e.e_phentsize=0x20;
  e.e_phnum=1;
  e.e_shentsize=0; // simplified
  e.e_shnum=0; // simplified
  e.e_shstrndx=0; // simplified
  p.p_type=1;
  p.p_offset=0x1000;
  p.p_vaddr=0; // will be changed
  p.p_paddr=0; // will be changed
  p.p_filesz=0; // will be changed
  p.p_memsz=0; // simplified: will be changed to filesz+0x40000;
  p.p_flags=7;
  p.p_align=0x1000;

  /* "parse" command line */
  in = fopen(argv[1], "rb");
  if (!in)
    pexit("fopen");
  out = fopen(argv[2], "w+b");
  if (!out)
    pexit("fopen");

  if (argc >= 4) {
    out_optional = fopen(argv[3], "w+b");
    if (!out_optional)
      pexit("fopen");
  }

  /* read EVA header */
  if (1 != fread(&magic, sizeof magic, 1, in))
    pexit("fread");
  if (fgetpos(in, &reclengthpos))
    pexit("fgetpos");
  if (1 != fread(&reclength, sizeof reclength, 1, in))
    pexit("fread");
  if (1 != fread(&loadaddress, sizeof loadaddress, 1, in))
    pexit("fread");
  printf("LOADADDR=0x%X\n",loadaddress);
  p.p_vaddr=loadaddress;
  p.p_paddr=loadaddress;
  if (1 != fread(&type, sizeof type, 1, in))
    pexit("fread");
  printf("type=0x%X\n",type);

  /* read EVA LZMA header */
  if (fgetpos(in, &compsizepos))
    pexit("fgetpos");
  if (1 != fread(&compsize2, sizeof compsize2, 1, in))
    pexit("fread");
  /* XXX check length */
  if (1 != fread(&datasize32, sizeof datasize32, 1, in))
    pexit("fread");
  datasize = (uint64_t)datasize32;
  printf("datasize=%lud\n", datasize);
  p.p_filesz=datasize;
  p.p_memsz=datasize + 0x40000;
  if (1 != fread(&datacrc32, sizeof datacrc32, 1, in))
    pexit("fread");

  /* read modified LZMA header */
  if (1 != fread(&properties, sizeof properties, 1, in))
    pexit("fread");
  if (1 != fread(&dictsize, sizeof dictsize, 1, in))
    pexit("fread");
  if (1 != fread(&zero, 3, 1, in))
    pexit("fread");

  /* write LZMA header */
  if (1 != fwrite(&properties, sizeof properties, 1, out))
    pexit("fwrite");
  if (1 != fwrite(&dictsize, sizeof dictsize, 1, out))
    pexit("fwrite");
  if (fgetpos(out, &reclengthpos2))
    pexit("fgetpos");
  if (1 != fwrite(&datasize, sizeof datasize, 1, out))
    pexit("fwrite");

  /* copy compressed data, calculate crc32 */
  while (0 < (elems = fread(&buf, sizeof buf[0], sizeof buf, in))) {
    compsize += elems;
    if (elems != fwrite(&buf, sizeof buf[0], elems, out))
      pexit("fwrite");
    //datacrc32 = crc32(datacrc32, buf, elems);
  }
  if (fseek(in, compsize2-compsize, SEEK_CUR))
    pexit("fseek");

  if (1 != fread(&checksum, sizeof checksum, 1, in))
    pexit("fread");
  //printf("checksum 0x%X\n", checksum);

  /* write entry record */
  if (1 != fread(&zero, sizeof zero, 1, in))
    pexit("fread");
  //printf("zero 0x%X\n", zero);
  if (1 != fread(&entry, sizeof entry, 1, in))
    pexit("fread");
  printf("ENTRY=0x%X\n", entry);
  e.e_entry=entry;

  fclose(in);

  if (fclose(out))
    pexit("fclose");

  if (out_optional) {
    if (1 != fwrite(&e, sizeof e, 1, out_optional))
      pexit("fwrite");
    if (1 != fwrite(&p, sizeof p, 1, out_optional))
      pexit("fwrite");
    if (1 != fwrite(&zero, 1, 0x1000- sizeof e -sizeof p, out_optional))
      pexit("fwrite");

    if (fclose(out_optional))
      pexit("fclose");
  }

  return 0;
}
