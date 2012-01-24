/*
 * Copyright (c) 2002 
 *      Texas Instruments.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by Texas Instruments. 
 * 4. Neither the name of the Company nor of the product may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* -*- Mode: C; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
 * File: cfgmgr_ckmain.c
 *
 * Created: Wed Aug 14 18:24:53 2002
 *
 * $Id: ckmain.c,v 1.1.1.1 2003/11/07 18:51:55 weix Exp $
 */

#include "cksum.h"

int main(int argc, char **argv)
{
  FILE *fp;
  unsigned int sum = 0;
  unsigned int res = 0;

  if(argc != 2)
  {
    printf("Usage: cfgmgr_cksum filename\n\n");
    return 1;
  }

  fp = fopen(argv[1], "rw+");

  if(!cs_is_tagged(fp))
  {
    printf("File doesn't contain the checksum, adding\n");
    if(cs_calc_sum(fp, &sum, 0))
    {
      printf("Calculated checksum is %X\n", sum);
      if(cs_set_sum(fp, sum, 0))
        printf("Added successfully\n");
      else
        printf("Adding failed\n");
    }
  }
  else
  {
    printf("File already contains the checksum, verifying\n");
    if(cs_calc_sum(fp, &sum, 1))
    {
      printf("Calculated checksum is %X\n", sum);
      cs_get_sum(fp, &res);
      printf("Saved checksum is %X\n", res);
      if(sum != res)
        printf("Checksum validation failed!\n");
      else
        printf("Checksum validation successful!\n");
    }
  }

  fclose(fp);

  return 0;
}
