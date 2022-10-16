#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>

unsigned char a[5] = { 1, 2, 3, 4, 5 };
int main(int argc, char **argv) {
	unsigned int i;
	pid_t pid;
	int status;
	/* avoid "core dumped" message */
	pid = fork();
	if (pid <  0) {
		exit(2);
	}
	if (pid > 0) {
		/* parent */
		pid = waitpid(pid, &status, 0);
		if (pid < 0) {
			exit(3);
		}
                exit(!WIFEXITED(status));
	}
	/* child */
	i = *(unsigned int *)&a[1];
	printf("%d\n", i);
	exit(0);
}
