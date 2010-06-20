#define _REENTRANT

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
//#include <sys/uio.h>
#include <sys/un.h>
#include <wchar.h>

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <poll.h>
#include <sys/poll.h>

#include <errno.h>
#include <time.h>
#include <sys/time.h>

#include <dirent.h>
#ifndef PATH_MAX
#define PATH_MAX 1024
#endif

#define TEXT "This is the test message -- "

#include <netinet/in.h>
#include <netdb.h>
#include <arpa/nameser.h>
#include <resolv.h>

#include <pwd.h>

#include <string.h>
#include <strings.h>
//#include <snprintf.h>

#include <sys/syscall.h>
#include <unistd.h>


int ac_cv_c_c99_format() {
	char buf[64];
	if (sprintf(buf, "%lld%hhd%jd%zd%td", (long long int)1, (char)2, (intmax_t)3, (size_t)4, (ptrdiff_t)5) != 5)
		return 1;
	else if (strcmp(buf, "12345"))
		return 2;
	return 0;
}

int ac_cv_fread_reads_directories() {
	char c;
	FILE *f = fopen(".", "r");
	return f && fread(&c, 1, 1, f);
}

#include "stdarg.h"
int test_vsnprintf(char *str, size_t maxsize, const char *format, ...) {
	int ret;
	va_list ap;
	va_start(ap, format);
	ret = vsnprintf(str, maxsize, format, ap);
	va_end(ap);
	return ret;
}

int ac_cv_snprintf_returns_bogus() {
	char buf[6];
	if (test_vsnprintf(buf, 3, "%s", "12345") != 5 || strcmp(buf, "12"))
		return 1;
	if (snprintf(buf, 3, "%s", "12345") != 5 || strcmp(buf, "12"))
		return 1;
	return 0;
}


struct cookiedata {
    __off64_t pos;
};
__ssize_t reader(void *cookie, char *buffer, size_t size) { return size; }
__ssize_t writer(void *cookie, const char *buffer, size_t size) { return size; }
int closer(void *cookie) { return 0; }
int seeker(void *cookie, __off64_t *position, int whence) { ((struct cookiedata*)cookie)->pos = *position; return 0; }


int find_stack_direction() {
    static char *addr = 0;
    auto char dummy;
    if (addr == 0) {
        addr = &dummy;
	return find_stack_direction();
    }
    else
	return (&dummy > addr) ? 1 : -1;
}


int main(int argc, char** argv) {
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

	{
	    struct stat x;
	    FILE *fp;

	    fp = fopen("/dev/null", "w");
	    if (fp != NULL) {
		printf("sizeof(stat_st_size)=%d\n", sizeof(x.st_size));
		fclose(fp);
	    }
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

#ifdef __cplusplus
	{
	    printf("cv_type_of_bool=");
    	    bool x = true;
	    if ((bool)(-x) >= 0)
		printf("unsigned ");
	    if (sizeof(x) == sizeof(int))
		printf("int\n");
	    else if (sizeof(x) == sizeof(char))
		printf("char\n");
	    else if (sizeof(x) == sizeof(short))
		printf("short\n");
	    else if (sizeof(x) == sizeof(long))
		printf("long\n");
	}
#endif

	{
	    struct pollfd myfds;
	    int code;
	    myfds.fd = 0;
	    myfds.events = POLLIN;
	    code = poll(&myfds, 1, 100);
	    printf("cf_cv_working_poll=%s\n", (code>=0) ? "yes" : "no");
	}

	{
	    struct timespec ts1, ts2;
	    int code;
	    ts1.tv_sec  = 0;
	    ts1.tv_nsec = 750000000;
	    ts2.tv_sec  = 0;
	    ts2.tv_nsec = 0;
	    errno = 0;
	    code = nanosleep(&ts1, &ts2); /* on failure errno is ENOSYS. */
	    printf("cf_cv_func_nanosleep=%s\n", (code==0) ? "yes" : "no");
	}

	{
	    int n = write(1, TEXT, sizeof(TEXT)-1);
	    printf("\nac_cv_write_stdout=%s\n", (n == sizeof(TEXT)-1) ? "yes" : "no");
	}

#ifdef __cplusplus
	{
	    cookie_io_functions_t funcs = {reader, writer, seeker, closer};
	    struct cookiedata g = { 0 };
	    FILE *fp = fopencookie(&g, "r", funcs);
	    printf("cookie_io_functions_use_off64_t=%s\n", (fp && fseek(fp, 8192, SEEK_SET) == 0 && g.pos == 8192) ? "yes" : "no");
	}
#endif

	{
	    struct stat s, t;
	    int code =
#if 1
	    0;
#else
	    // doesn't compile so no
	    (
		stat ("conftestdata", &s) == 0
		&& utime("conftestdata", (long *)0) == 0
		&& stat("conftestdata", &t) == 0
		&& t.st_mtime >= s.st_mtime
		&& t.st_mtime - s.st_mtime < 120
	    );
#endif
	    printf("ac_cv_func_utime_null=%s\n", code ? "yes" : "no");
	}

	printf("ac_cv_c_stack_direction=%d\n", find_stack_direction());

	{
	    DIR *dir;
	    char entry[sizeof(struct dirent)+PATH_MAX];
	    struct dirent *pentry = (struct dirent *) &entry;
	    int code;

	    dir = opendir("/");
	    code = dir && (readdir_r(dir, (struct dirent *) entry, &pentry) == 0);
	    printf("ac_cv_what_readdir_r=%s\n", code ? "POSIX" : "none");
	}

#if 0
	{
	    char c0 = 0x40, c1 = 0x80, c2 = 0x81;
	    int code = memcmp(&c0, &c2, 1) < 0 && memcmp(&c1, &c2, 1) < 0;
	    printf("ac_cv_func_memcmp_clean=%s\n", code ? "yes" : "no");
	}
#endif

#if 0
	// doesn't compile so no
	int foo = res_ninit(NULL);
#endif

	{
	    int code = getgroups(0, 0) != -1;
	    printf("ac_cv_func_getgroups_works=%s\n", code ? "yes" : "no");
	}

	{
	    struct stat sbuf;
	    int code = (stat("", &sbuf) == 0);
	    printf("ac_cv_func_stat_empty_string_bug=%s\n", code ? "yes" : "no");
	}

	{
	    struct stat sbuf;
	    int code = (lstat("", &sbuf) == 0);
	    printf("ac_cv_func_lstat_empty_string_bug=%s\n", code ? "yes" : "no");
	}

	{
	    struct stat sbuf;
	    int code = (lstat("conftest.sym/", &sbuf) == 0);
	    printf("ac_cv_func_lstat_dereferences_slashed_symlink=%s (you should do 'echo > conftest.file && ln -s conftest.file conftest.sym' before running this test)\n", code ? "yes" : "no");
	}

	{
	    char buffer[10000];
	    struct passwd pwd;
	    struct passwd* pwdp = &pwd;
	    int error = getpwuid_r(0, &pwd, (char*)&buffer, sizeof(buffer), &pwdp);
	    int code = (errno != ENOSYS);
	    printf("ac_cv_func_getpwuid_r=%s\n", code ? "yes" : "no");
	}

	{
	    int sfd = socket(AF_UNIX, SOCK_STREAM, 0);
	    int code = (sfd >= 0);
	    if (code)
		close(sfd);
	    printf("wi_cv_unix_domain_sockets=%s\n", code ? "yes" : "no");
	}

	{
	    struct hostent *hp1, *hp2;
	    int code = 0;
	    hp1 = gethostbyname("ftp.ncftp.com");
	    if (hp1 == (struct hostent *)0) {
		hp2 = gethostbyname("www.ibm.com");
		if (hp2 == (struct hostent *)0)
		    code = 1;
	    }
	    printf("wi_cv_look_for_resolv=%s\n", code ? "yes" : "no");
	}

	{
	    char s[16];
	    int i, result, code;

	    for (i=0; i<(int)(sizeof(s)/sizeof(char)); i++)
		s[i] = 'x';
	    result = (int)snprintf(s + 1, 10, "%s %s!", "hello", "world");
	    if (s[10] != '\0')
		code = 1; /* did not force termination! */
	    else if (s[11] != 'x')
		code = 2; /* overflow! */
	    else if (s[0] != 'x')
		code = 3; /* underflow! */
	    else
		code = 0;

	    printf("wi_cv_snprintf_terminates=%s\n", (code==0) ? "yes" : "no");
	}

	{
	    char s[8];
	    int result = (int)snprintf(s, sizeof(s) - 1, "%d", 22);
	    printf("wi_cv_snprintf_returns_ptr=%s\n", (result == 2) ? "no" : "yes");
	}

#if 0
	{
	    //doesn't compile -> no
	    int test_SYS = SYS_ioprio_set;
	    int test_NR = _NR_ioprio_set;
	}
#endif

	{
	    /* The string "%2$d %1$d", with dollar characters protected from the shell's
	    dollar expansion (possibly an autoconf bug). */
	    static char format[] = { '%', '2', '$', 'd', ' ', '%', '1', '$', 'd', '\0' };
	    static char buf[100];
	    int code;

	    sprintf(buf, format, 33, 55);
	    code = (strcmp (buf, "55 33") == 0);
	    printf("gt_cv_func_printf_posix=%s\n", code ? "yes" : "no");
	}

	{
	    int code = ac_cv_c_c99_format();
	    printf("ac_cv_c_c99_format=%s\n", code==0 ? "yes" : "no");
	}

	{
	    int code = ac_cv_fread_reads_directories();
	    printf("ac_cv_fread_reads_directories=%s\n", code ? "yes" : "no");
	}

	{
	    int code = ac_cv_snprintf_returns_bogus();
	    printf("ac_cv_snprintf_returns_bogus=%s\n", code ? "yes" : "no");
	}

	{
		uint64_t i0;
		uint64_t i1;
		uint8_t c[8];
		double d;

		d = 8.642135e130;
		memcpy ((void *) &i0, (void *) &d, 8);

		i1 = i0;
		memcpy ((void *) c, (void *) &i1, 8);

		int code = (
			(c[0] == 0x2f) && (c[1] == 0x25)
			&& (c[2] == 0xc0) && (c[3] == 0xc7)
			&& (c[4] == 0x43) && (c[5] == 0x2b)
			&& (c[6] == 0x1f) && (c[7] == 0x5b)
		);

		printf("c_cv_fp_layout_need_nothing=%s\n", code ? "yes" : "no");
	}

}
