// vi: set tabstop=4 syntax=c :
/***********************************************************************
 *                                                                     *
 *                                                                     *
 * Copyright (C) 2016-2017 P.Hämmerlein (http://www.yourfritz.de)      *
 * Modified by Eugene Rudoy (https://github.com/er13)                  *
 *                                                                     *
 * This program is free software; you can redistribute it and/or       *
 * modify it under the terms of the GNU General Public License         *
 * as published by the Free Software Foundation; either version 2      *
 * of the License, or (at your option) any later version.              *
 *                                                                     *
 * This program is distributed in the hope that it will be useful,     *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of      *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       *
 * GNU General Public License for more details.                        *
 *                                                                     *
 * You should have received a copy of the GNU General Public License   *
 * along with this program, please look for the file COPYING.          *
 *                                                                     *
 ***********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

#include <libfdt.h>

#include "lib_avm_kernel_config.h"
#include "memory_mapped_file.h"

void usage()
{
	fprintf(stderr, "avm_kernel_config.extract - extract (binary copy of) kernel config area from AVM's kernel\n\n");
	fprintf(stderr, "(C) 2016-2017 P. Hämmerlein (http://www.yourfritz.de)\n");
	fprintf(stderr, "Modified by Eugene Rudoy for Freetz project (https://freetz.github.io)\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "Licensed under GPLv2, see LICENSE file from source repository.\n\n");
	fprintf(stderr, "Usage:\n\n");
	fprintf(stderr, "avm_kernel_config.extract [ -s <size in KByte> ] [ -l <kernel load address> ] <unpacked_kernel> [<dtb_file>]\n");
	fprintf(stderr, "\nThe unpacked kernel is searched for the specified DTB content (a compiled");
	fprintf(stderr, "\ndevice tree BLOB). The position it's found at is assumed to be within the");
	fprintf(stderr, "\noriginal kernel config area.\n");
	fprintf(stderr, "\nIf the DTB file is omitted the kernel is searched for the FDT signature");
	fprintf(stderr, "\n(0xD00DFEED in BE) and some checks are performed to guess the correct");
	fprintf(stderr, "\nlocation.\n");
	fprintf(stderr, "\nThe output is written to STDOUT, so you have to redirect it to a proper");
	fprintf(stderr, "\nlocation.\n");
	fprintf(stderr, "\nThe size of the embedded configuration area depends on the system type");
	fprintf(stderr, "\nof the box and the firmware version. This tool implements a heuristic");
	fprintf(stderr, "\ntrying to detect the proper size automatically. If it however fails");
	fprintf(stderr, "\nthe option -s could be used to specify it explicitly.\n");
	fprintf(stderr, "\nFor kernels loaded at addresses not aligned at 4K boundaries (GRX5 boxes)");
	fprintf(stderr, "\n-l option must be used to make guessing the config area location possible.\n");
}

void * findConfigArea(void *kernelBuffer, size_t kernelBufferSize, void *dtbLocation, uint32_t kernelLoadAddr /* target address space */, size_t *size)
{
	if (kernelBuffer < dtbLocation && size != NULL)
	{
		uint32_t kernelSegmentStart = determineConfigAreaKernelSegment(kernelLoadAddr + (uint32_t)((char *)dtbLocation - (char *)kernelBuffer)); // target address space
		void *configArea = targetPtr2HostPtr(kernelSegmentStart, kernelLoadAddr, kernelBuffer); // host address space

		uint32_t configAreaOffset = (uint32_t)((char *)configArea - (char *)kernelBuffer);

		if (configAreaOffset < kernelBufferSize) {
			if (*size == 0) { // 0 means guess / try to autodetect
				size_t potentialSize;
				for (potentialSize = 16 * 1024; potentialSize <= 1024 * 1024; potentialSize += 16 * 1024) {
					if (isConsistentConfigArea(configArea, (kernelBufferSize - configAreaOffset), potentialSize, NULL, NULL)) {
						*size = potentialSize; // return detected size to the caller
						return configArea;
					}
				}
			} else {
				// we intentionally pass *size, *size here as we want to be able to create shorter / less padded dumps
				if (isConsistentConfigArea(configArea, *size, *size, NULL, NULL))
					return configArea;
			}
		}
	}

	return NULL;
}

void * findDeviceTreeImage(void *haystack, size_t haystackSize, void *needle, size_t needleSize)
{
	void *		location = NULL;
	size_t		toSearch = haystackSize / sizeof(uint32_t);
	size_t		offsetMatched = 0;
	bool		matchedSoFar = false;
	uint32_t *	resetSliding;
	size_t		resetToSearch;

	if (toSearch > 0)
	{
		uint32_t *	sliding = haystack;
		uint32_t *	lookFor = needle;

		while (toSearch > 0)
		{
			while (*sliding != *lookFor)
			{
				toSearch--;
				sliding++;
				if (toSearch == 0) break;
			}

			if (toSearch > 0) // match found for first uint32
			{
				matchedSoFar = true;
				resetToSearch = --toSearch;
				resetSliding = ++sliding;
				offsetMatched = sizeof(uint32_t);

				if ((needleSize - offsetMatched) > sizeof(uint32_t))
				{
					while (offsetMatched < needleSize)
					{
						if (*(lookFor + (offsetMatched / sizeof(uint32_t))) != *sliding) // difference found, reset match
						{
							matchedSoFar = false;
							sliding = resetSliding;
							toSearch = resetToSearch;
							break;
						}

						offsetMatched += sizeof(uint32_t);
						sliding++;
						toSearch--;

						if (toSearch == 0) break; // end of kernel reached, DTB isn't expected at the very end
						if ((needleSize - offsetMatched) < sizeof(uint32_t)) break;
					}
				}

				if (matchedSoFar) // compare remaining bytes
				{
					uint8_t *	remHaystack = (uint8_t *) sliding;
					uint8_t *	remNeedle = (uint8_t *)needle + offsetMatched;
					size_t		remSize = needleSize - offsetMatched;

					while (remSize > 0)
					{
						if (*remHaystack != *remNeedle) // difference found
						{
							matchedSoFar = false;
							sliding = resetSliding;
							toSearch = resetToSearch;
							break;
						}

						remHaystack++;
						remNeedle++;
						remSize--;
					}

					if (remSize == 0) // match completed
					{
						location = (void *) --resetSliding;
						break;
					}
				}
			}
		}
	}

	return location;
}

void * locateDeviceTreeSignature(void *kernelBuffer, size_t kernelSize)
{
	for (char *ptr = (char *)kernelBuffer; ptr < (char *)kernelBuffer + kernelSize; ptr+=4)
	{
		if ((fdt_magic(ptr) == FDT_MAGIC) && (fdt_check_header(ptr) == 0))
			return ptr;
	}

	return NULL;
}

int main(int argc, char * argv[])
{
	int						returnCode = 1;
	struct memoryMappedFile	kernel;
	struct memoryMappedFile	dtb;
	void *					dtbLocation = NULL;
	uint32_t				kernelLoadAddr = 0;
	size_t					size = 0; // 0 means guess
	int						i = 1;

	/* no reason to use a getopt implementation for our simple calling convention */
	while (i < argc)
	{
		int shortS = (strcmp(argv[i], "-s") == 0);
		int longS  = (strncmp(argv[i], "--size=", 7) == 0);
		int shortL = (strcmp(argv[i], "-l") == 0);
		int longL  = (strncmp(argv[i], "--loadaddr=", 11) == 0);
		char * optParamString = NULL;

		if (shortS || shortL)
		{
			if (i + 1 < argc)
			{
				optParamString = argv[i + 1];
				i += 2;
			}
			else
			{
				fprintf(stderr, "Missing numeric value after option '%s'.\n", argv[i]);
				exit(2);
			}
		}
		else if (longS || longL)
		{
			optParamString = strchr(argv[i], '=');
			optParamString++; /* skip equal sign */
			i += 1;
		}

		if (shortS || longS)
		{
			int				newSize;

			newSize = atoi(optParamString);
			if (newSize == 0)
			{
				fprintf(stderr, "Missing or invalid numeric value for size option.\n");
				exit(2);
			}
			if (newSize < 16 || newSize > 1024)
			{
				fprintf(stderr, "Size value should be between 16 and 1024 - change source files, if your size is really valid.\n");
				exit(2);
			}
			if ((newSize & 0x0F) > 0)
			{
				fprintf(stderr, "Size value should be a multiple of 16 - change source files, if your size is really valid.\n");
				exit(2);
			}
			size = newSize * 1024;
		}
		else if (shortL || longL)
		{
			char *firstInvalidChar;

			kernelLoadAddr = strtoul(optParamString, &firstInvalidChar, 0);
			if (*optParamString=='\0' || *firstInvalidChar != '\0')
			{
				fprintf(stderr, "Missing or invalid numeric value for loadaddr option. Load address is expected to be a 32-bit hexadecimal or decimal value.\n");
				exit(2);
			}
		}
		else
		{
			// neither size nor loadaddr option
			break;
		}
	}

	if (!(1 <= (argc - i) && (argc - i) <= 2))
	{
		usage();
		exit(1);
	}

	if (openMemoryMappedFile(&kernel, argv[i], "unpacked kernel", O_RDONLY | O_SYNC, PROT_READ, MAP_SHARED))
	{
		if (i + 1 < argc)
		{
			if (openMemoryMappedFile(&dtb, argv[i + 1], "device tree BLOB", O_RDONLY | O_SYNC, PROT_READ, MAP_SHARED))
			{
				if (fdt_check_header(dtb.fileBuffer) == 0)
				{
					if ((dtbLocation = findDeviceTreeImage(kernel.fileBuffer, kernel.fileStat.st_size, dtb.fileBuffer, dtb.fileStat.st_size)) == NULL)
					{
						fprintf(stderr, "The specified device tree BLOB was not found in the kernel image.\n");
					}
				}
				else
				{
					fprintf(stderr, "The specified device tree BLOB file '%s' seems to be invalid.\n", dtb.fileName);
				}
			}
			closeMemoryMappedFile(&dtb);
		}
		else
		{
			if ((dtbLocation = locateDeviceTreeSignature(kernel.fileBuffer, kernel.fileStat.st_size)) == NULL)
			{
				fprintf(stderr, "Unable to locate the config area in the specified kernel image.\n");
			}
		}

		if (dtbLocation != NULL)
		{
			void *configArea = findConfigArea(kernel.fileBuffer, kernel.fileStat.st_size, dtbLocation, kernelLoadAddr, &size);

			if (configArea != NULL)
			{
				ssize_t written = write(1, configArea, size);

				if (written == (ssize_t)size)
				{
					returnCode = 0;
				}
				else
				{
					fprintf(stderr, "Error %d writing config area content.\n", errno);
				}
			}
			else
			{
				fprintf(stderr, "Unexpected config area content found, extraction aborted.\n");
			}
		}
		closeMemoryMappedFile(&kernel);
	}

	exit(returnCode);
}

