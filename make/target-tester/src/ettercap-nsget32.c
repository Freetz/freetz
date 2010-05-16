#include <arpa/nameser.h>

int main(int argc, char **argv) {
	int i;
	char *p = "\x01\x02\x03\x04";
	NS_GET32(i, p);

	return 0;
}
