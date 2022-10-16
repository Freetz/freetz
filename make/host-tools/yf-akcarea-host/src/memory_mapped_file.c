// vi: set tabstop=4 syntax=c :
/***********************************************************************
 *                                                                     *
 *                                                                     *
 * Copyright (C) 2016 P.Hämmerlein (http://www.yourfritz.de)           *
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
#include <fcntl.h>
#include <unistd.h>

#include "memory_mapped_file.h"

bool openMemoryMappedFile(struct memoryMappedFile *file, const char *fileName, const char *fileDescription, int openFlags, int prot, int flags)
{
	bool			result = false;

	file->fileMapped = false;
	file->fileBuffer = NULL;
	file->fileName = fileName;
	file->fileDescription = fileDescription;

	if ((file->fileDescriptor = open(file->fileName, openFlags)) != -1)
	{
		if (fstat(file->fileDescriptor, &file->fileStat) != -1)
		{
			if ((file->fileBuffer = (void *) mmap(NULL, file->fileStat.st_size, prot, flags, file->fileDescriptor, 0)) != MAP_FAILED)
			{
				file->fileMapped = true;
				result = true;
			}
			else fprintf(stderr, "Error %d mapping %u bytes of %s file '%s' to memory.\n", errno, (int) file->fileStat.st_size, file->fileDescription, file->fileName);
		}
		else fprintf(stderr, "Error %d getting file stats for '%s'.\n", errno, file->fileName);

		if (result == false)
		{
			close(file->fileDescriptor);
			file->fileDescriptor = -1;
		}
	}
	else fprintf(stderr, "Error %d opening %s file '%s'.\n", errno, file->fileDescription, file->fileName);

	return result;
}

void closeMemoryMappedFile(struct memoryMappedFile *file)
{
	if (file->fileMapped)
	{
		munmap(file->fileBuffer, file->fileStat.st_size);
		file->fileBuffer = NULL;
		file->fileMapped = false;
	}

	if (file->fileDescriptor != -1)
	{
		close(file->fileDescriptor);
		file->fileDescriptor = -1;
	}
}
