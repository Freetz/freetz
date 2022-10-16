#include <fcntl.h>
#include <stdio.h>

int main(int argc, char** argv) {
	struct flock lock = { 1, 2, 3, 4, 5 };
	if (lock.l_start == 1 && lock.l_len == 2 && lock.l_type == 4 && lock.l_whence == 5) {
		printf("flock_type=bsd\n");
		return 0;
	}
	if (lock.l_type == 1 && lock.l_whence == 2 && lock.l_start == 3 && lock.l_len == 4) {
		printf("flock_type=linux\n");
		return 0;
	}
	printf("flock_type=unknown\n");
	return 1;
}
