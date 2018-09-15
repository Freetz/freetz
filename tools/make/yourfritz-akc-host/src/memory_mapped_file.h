// vi: set tabstop=4 syntax=c :
#ifndef MEMORY_MAPPED_FILE_H
#define MEMORY_MAPPED_FILE_H

#include <stdbool.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/fcntl.h>

#include <sys/mman.h>

struct memoryMappedFile
{
	const char *		fileName;
	const char *		fileDescription;
	int					fileDescriptor;
	struct stat			fileStat;
	void *				fileBuffer;
	bool				fileMapped;
};

bool openMemoryMappedFile(struct memoryMappedFile *file, const char *fileName, const char *fileDescription, int openFlags, int prot, int flags);
void closeMemoryMappedFile(struct memoryMappedFile *file);

#endif
