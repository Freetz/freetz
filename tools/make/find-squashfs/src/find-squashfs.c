#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>

#include <errno.h>

#ifndef BYTE_ORDER
#error "byte order not defined"
#endif

static void usage(name)
char name[];
{
	fprintf(stderr,"Usage: %s [-any|-be|-le] kernel.image\n",name);
	exit(1);
}

void
write_file (const char *fn, void *start, size_t len)
{
	int fd;
	ssize_t ret;

	fd = open(fn, O_WRONLY|O_CREAT, 0666);
	if ( fd < 0 )
	{
		fprintf(stderr, "Create %s: %s\n", fn, strerror (errno));
		exit(99);
	}
	ret = write(fd, start, len);
	if (ret != (ssize_t)len)
	{
		fprintf (stderr, "Write %s: short write %ld of %ld\n", fn, (long)ret, (long)len);
		exit (99);
	}
	ret = close(fd);
	if (ret < 0)
	{
		fprintf (stderr, "Close %s: %s\n", fn, strerror (errno));
		exit (99);
	}
	fprintf(stderr, "Created %s\n", fn);
}

int main(argc,argv)
int argc;
char **argv;
{
	int fd;
	long size, count;
	ssize_t ret;
	int i;
	uint32_t *start,*point;
	/* start signature of squashfs */
	uint32_t search_be = ntohl (0x73717368);
	uint32_t search_le = ntohl (0x68737173);
	enum { MODE_BE = 1 << 0, MODE_LE = 1 << 1, MODE_ANY = MODE_BE | MODE_LE} mode = MODE_ANY;
	const char *fn;


	for (i = 1; i < argc; i++)
	{
		if (argv[i][0] != '-')
			break;
		if (!strcasecmp (argv[i] + 1, "any"))
			mode = MODE_ANY;
		else if (!strcasecmp (argv[i] + 1, "be"))
			mode = MODE_BE;
		else if (!strcasecmp (argv[i] + 1, "le"))
			mode = MODE_LE;
		else
			usage(argv[0]);
	}
	if ( argc - i != 1 )
		usage(argv[0]);
	fn = argv[i];
	fd = open(fn, O_RDONLY);
	if ( fd < 0 )
	{
		fprintf(stderr,"Open <%s>: %s\n",fn,strerror(errno));
		exit(99);
	}
	/* get size */
	size = lseek(fd, 0L, SEEK_END);
	fprintf(stderr,"Size is %ld\n", size);
	lseek(fd, 0L, SEEK_SET);

	start=(uint32_t *)malloc(size);

	ret = read(fd, start, size);
	if (ret != (ssize_t)size) {
		fprintf (stderr, "Short read %ld of %ld\n", ret, size);
		exit (99);
	}
	close(fd);

	for ( count=0,point=start; count < size; count+=sizeof(uint32_t),++point)
	{
		if ( (mode & MODE_BE) && *point == search_be)
		{
			fprintf(stderr,"Big endian squashfs signature found at %ld\n",count);
			break;
		}
		if ( (mode & MODE_LE) && *point == search_le )
		{
			fprintf(stderr,"Little endian squashfs signature found at %ld\n",count);
			break;
		}
	}
	if ( count >= size )
	{
		fprintf(stderr,"Strange, no squashfs signature found...\n");
		exit(99);
	}
	write_file ("kernel.raw", start, count);
	write_file ("kernelsquashfs.raw", point, size - count);

	free(start);
	exit(0);
}
