#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <strings.h>

int main(int argc, char** argv) {
	int i, nullAs2ndArg = (strncasecmp(argv[0] + strlen(argv[0]) - 6, "nonull", 6) != 0);
	for (i=1; i<argc; ++i) {
		char buf[PATH_MAX+1];
		char* resolved_path = realpath(argv[i], nullAs2ndArg ? NULL : buf);
		if (resolved_path) {
			printf("%s\n-> %s\n", argv[i], resolved_path);
			if (nullAs2ndArg)
				free(resolved_path);
		}
	}
	return 0;
}
