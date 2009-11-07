#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
//#include <sys/uio.h>
#include <wchar.h>

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>


int main(int argc, char** argv) {
	struct stat x;
	FILE *fp;

	printf("sizeof(__int16_t)=%d\n", sizeof(__int16_t));
	printf("sizeof(__int32_t)=%d\n", sizeof(__int32_t));
	printf("sizeof(__int64_t)=%d\n", sizeof(__int64_t));
	//printf("sizeof(cell_t)=%d\n", sizeof(cell_t));
	printf("sizeof(char)=%d\n", sizeof(char));
	printf("sizeof(char_p)=%d\n", sizeof(char*));
	printf("sizeof(dev_t)=%d\n", sizeof(dev_t));
	printf("sizeof(double)=%d\n", sizeof(double));
	printf("sizeof(float)=%d\n", sizeof(float));
	printf("sizeof(fpos_t)=%d\n", sizeof(fpos_t));
	printf("sizeof(int16_t)=%d\n", sizeof(int16_t));
	printf("sizeof(int32_t)=%d\n", sizeof(int32_t));
	printf("sizeof(int64_t)=%d\n", sizeof(int64_t));
	printf("sizeof(int8_t)=%d\n", sizeof(int8_t));
	printf("sizeof(int)=%d\n", sizeof(int));
	printf("sizeof(intmax_t)=%d\n", sizeof(intmax_t));
	printf("sizeof(intptr_t)=%d\n", sizeof(intptr_t));
	printf("sizeof(long)=%d\n", sizeof(long));
	printf("sizeof(long double)=%d\n", sizeof(long double));
	printf("sizeof(long long)=%d\n", sizeof(long long));
	printf("sizeof(long long int)=%d\n", sizeof(long long int));
	printf("sizeof(mode_t)=%d\n", sizeof(mode_t));
#ifdef INCLUDE_LFS_ONLY_TYPES
	printf("sizeof(off64_t)=%d\n", sizeof(off64_t));
#endif
	printf("sizeof(off_t)=%d\n", sizeof(off_t));
	printf("sizeof(pid_t)=%d\n", sizeof(pid_t));
	printf("sizeof(ptrdiff_t)=%d\n", sizeof(ptrdiff_t));
	printf("sizeof(short)=%d\n", sizeof(short));
	printf("sizeof(signed char)=%d\n", sizeof(signed char));
	printf("sizeof(size_t)=%d\n", sizeof(size_t));
	printf("sizeof(socklen_t)=%d\n", sizeof(socklen_t));
	printf("sizeof(ssize_t)=%d\n", sizeof(ssize_t));
	fp = fopen("/dev/null", "w");
	if (fp != NULL) {
	    printf("sizeof(stat_st_size)=%d\n", sizeof(x.st_size));
	    fclose(fp);
	}
	//printf("sizeof(struct_iovec)=%d\n", sizeof(struct_iovec));
	printf("sizeof(time_t)=%d\n", sizeof(time_t));
	printf("sizeof(uint16_t)=%d\n", sizeof(uint16_t));
	printf("sizeof(uint32_t)=%d\n", sizeof(uint32_t));
	printf("sizeof(uint64_t)=%d\n", sizeof(uint64_t));
	printf("sizeof(uint8_t)=%d\n", sizeof(uint8_t));
	printf("sizeof(uintmax_t)=%d\n", sizeof(uintmax_t));
	printf("sizeof(uintptr_t)=%d\n", sizeof(uintptr_t));
	printf("sizeof(unsigned char)=%d\n", sizeof(unsigned char));
	printf("sizeof(unsigned int)=%d\n", sizeof(unsigned int));
	printf("sizeof(unsigned long)=%d\n", sizeof(unsigned long));
	printf("sizeof(unsigned short)=%d\n", sizeof(unsigned short));
	printf("sizeof(void_p)=%d\n", sizeof(void*));
	printf("sizeof(voidp)=%d\n", sizeof(void*));
	printf("sizeof(mbstate_t)=%d\n", sizeof(mbstate_t));
	printf("sizeof(__off64_t)=%d\n", sizeof(__off64_t));
}
