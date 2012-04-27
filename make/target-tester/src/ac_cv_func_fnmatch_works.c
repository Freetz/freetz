/*
 * Usage: ./ac_cv_func_fnmatch_works && echo "yes" || echo "no"
 */

#include <stdio.h>

#include <fnmatch.h>

#define y(a, b, c) (fnmatch (a, b, c) == 0)
#define n(a, b, c) (fnmatch (a, b, c) == FNM_NOMATCH)

int main(int argc, char** argv) {
	const int t1 = y ("a*", "abc", 0);
	const int t2 = n ("d*/*1", "d/s/1", FNM_PATHNAME);
	const int t3 = y ("a\\bc", "abc", 0);
	const int t4 = n ("a\\bc", "abc", FNM_NOESCAPE);
	const int t5 = y ("*x", ".x", 0);
	const int t6 = n ("*x", ".x", FNM_PERIOD);

	fprintf(stderr, "t1=%i\n", t1);
	fprintf(stderr, "t2=%i\n", t2);
	fprintf(stderr, "t3=%i\n", t3);
	fprintf(stderr, "t4=%i\n", t4);
	fprintf(stderr, "t5=%i\n", t5);
	fprintf(stderr, "t6=%i\n", t6);

	return !(t1 && t2 && t3 && t4 && t5 && t6);
}
