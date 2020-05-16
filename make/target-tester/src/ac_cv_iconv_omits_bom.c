/*
 * Usage: ./ac_cv_iconv_omits_bom && echo "no" || echo "yes"
 */

#include <stdio.h>

#include <iconv.h>

typedef char *iconv_ibp;

int main() {
	int v;
	iconv_t conv;
	char in[] = "a"; iconv_ibp pin = in;
	char out[20] = ""; char *pout = out;
	size_t isz = sizeof in;
	size_t osz = sizeof out;

	conv = iconv_open("UTF-16", "UTF-8");
	iconv(conv, &pin, &isz, &pout, &osz);
	iconv_close(conv);
	fprintf(stderr, "%s\n", out);
	v = (unsigned char)(out[0]) + (unsigned char)(out[1]);
	return (v != (0xfe + 0xff));
}
