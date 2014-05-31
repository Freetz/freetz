/*
 * (c) 2014 freetz.org
 *
 * libfakefile is a library intended to be used for faking the content of text files. Only read-only mode is supported.
 *
 * Usage:
 *   FAKE_FILE_NAME="path-to-file-as-used-in-open-call-in-binary-to-fool" FAKE_FILE_CONTENT="faked-content" LD_PRELOAD="/path/to/libfakefile.so" binary-to-fool
 */

//#define DEBUG

#include <dlfcn.h>      // dlopen, dlsym
#include <stdarg.h>     // vprintf
#include <stdio.h>      // printf, fprintf, rename...
#include <string.h>
#include <errno.h>

#include <limits.h>
#include <stdlib.h>     // exit, system
#include <stdint.h>
#include <unistd.h>

#include <sys/types.h>  // open
#include <sys/stat.h>
// TODO: find a way to #include fcntl.h instead of redefining required symbols
// The problem is uClibc' __REDIRECT macro "redirecting" (i.e. renaming at assembly level) open to open64
#if !defined(__UCLIBC__)
#include <fcntl.h>
#else
#warning redefining required symbols instead of #including <fcntl.h>
#define O_CREAT          0x0100
#define O_RDONLY             00
#endif

#ifndef LIBC_LOCATION
#define LIBC_LOCATION "/lib/libc.so.0"
//#define LIBC_LOCATION "/lib/x86_64-linux-gnu/libc.so.6"
#endif

#ifdef DEBUG
static FILE *debug_stream = NULL;
#endif

static int (*real_open)(const char *, int, ...) = NULL;
static int (*real_open64)(const char *, int, ...) = NULL;

static int (*real___libc_open)(const char *, int, ...) = NULL;
static int (*real___libc_open64)(const char *, int, ...) = NULL;

static char *filename = NULL;
static char *filecontent = NULL;

static void debug_printf(char *fmt, ...);

static void *dlsym_fail_on_error(void *handle, const char *symbol);
static char *getenv_fail_on_error(const char *name);

static int get_readonly_fd_pointing_to(const char *membuf);

static void _libfakefile_init (void) __attribute__((constructor));
static void _libfakefile_init (void) {
	const char *err;

#if defined(RTLD_NEXT) && !defined(__UCLIBC__)
  /*
   * TODO: doesn't work because of a uClibc bug fixed by the following commit
   *       http://git.uclibc.org/uClibc/commit/ldso/libdl/libdl.c?id=df3a5fcc8d1c3402289375c92df705e978fab58d
   */
	void *libc_handle = RTLD_NEXT;
#else
	void *libc_handle = dlopen(LIBC_LOCATION, RTLD_LOCAL | RTLD_LAZY);
#endif
	if (!libc_handle || NULL != (err = dlerror())) {
		fprintf(stderr, "[libfakefile] unable to get libc-handle: %s\n", err);
		exit(EXIT_FAILURE);
	}

	real_open = dlsym_fail_on_error(libc_handle, "open");
	real_open64 = dlsym_fail_on_error(libc_handle, "open64");
	real___libc_open = dlsym_fail_on_error(libc_handle, "__libc_open");
	real___libc_open64 = dlsym_fail_on_error(libc_handle, "__libc_open64");

	filename = getenv_fail_on_error("FAKE_FILE_NAME");
	filecontent = getenv_fail_on_error("FAKE_FILE_CONTENT");

#ifdef DEBUG
	char *FAKE_FILE_DEBUG_TO = getenv("FAKE_FILE_DEBUG_TO");
	if (!FAKE_FILE_DEBUG_TO || strcmp(FAKE_FILE_DEBUG_TO, "stderr") == 0) {
		debug_stream = stderr;
	} else {
		debug_stream = fopen(FAKE_FILE_DEBUG_TO, "a");
		if (!debug_stream) {
			char errmsgbuf[BUFSIZ];
			fprintf(stderr, "[libfakefile] unable to open debug stream for writing errno=%i, msg=%s\n", errno, strerror_r(errno, errmsgbuf, BUFSIZ));
			exit(EXIT_FAILURE);
		}
	}
#endif

	debug_printf("[libfakefile] initialization done.\n");
}

static void debug_printf(char *fmt, ...) {
#ifdef DEBUG
	va_list ap;
	va_start(ap, fmt);
	vfprintf(debug_stream, fmt, ap);
	va_end(ap);
	fflush(debug_stream);
#endif
}

static void *dlsym_fail_on_error(void *handle, const char *symbol) {
	const char *err;
	void *symbol_handle = dlsym(handle, symbol);
	if (!symbol_handle || NULL != (err = dlerror ())) {
		fprintf(stderr, "[libfakefile] unable to get \"%s\"-handle: %s\n", symbol, err);
		exit(EXIT_FAILURE);
	}
	return symbol_handle;
}

static char *getenv_fail_on_error(const char *name) {
	char *value = getenv(name);
	if (!value) {
		fprintf(stderr, "[libfakefile] failed to initialize, %s is not set.\n", name);
		exit(EXIT_FAILURE);
	}
	return value;
}

/*
 * fmemopen-based solution doesn't work as fmemopen
 * returns a stream with no file descriptor associated.
 */
static int get_readonly_fd_pointing_to(const char *membuf) {
	char errmsgbuf[BUFSIZ];
	int pipefd[2];
	pid_t pid;

	if (pipe(pipefd) == -1) {
		fprintf(stderr, "[libfakefile] pipe call failed with errno=%i, msg=\"%s\"\n", errno, strerror_r(errno, errmsgbuf, BUFSIZ));
		exit(EXIT_FAILURE);
	}

	pid = fork();
	if (pid < (pid_t)0) {
		fprintf(stderr, "[libfakefile] fork call failed with errno=%i, msg=\"%s\"\n", errno, strerror_r(errno, errmsgbuf, BUFSIZ));
		exit(EXIT_FAILURE);
	}

	/* child process */
	if (pid == (pid_t)0) {
		close(pipefd[0]);    /* close unused read end */
		write(pipefd[1], membuf, strlen(membuf));
		close(pipefd[1]);    /* reader will see EOF */
		exit(EXIT_SUCCESS);  /* man pipe uses _exit */
	}

	/* parent process */
	close(pipefd[1]);            /* close unused write end */
	wait(NULL);                  /* wait for child */
	return pipefd[0];
}

#define OPEN_ALIAS(sym) \
int sym(char const *, int, ...) __attribute__ ((alias("libfakefile_" #sym)));

#define OPEN_FCT(sym) \
int libfakefile_##sym(const char *pathname, int flags, ...) { \
	mode_t mode = 0; \
	if (flags & O_CREAT) { \
		va_list arg; \
		va_start(arg, flags); \
		mode = va_arg(arg, mode_t); \
		va_end(arg); \
	} \
\
	debug_printf("[libfakefile] " #sym "(%s, %i, %u)\n", pathname, flags, mode); \
\
	if (filename && filecontent && flags == O_RDONLY && strcmp(pathname, filename) == 0) { \
		debug_printf("[libfakefile] faking content of \"%s\"\n", pathname); \
		return get_readonly_fd_pointing_to(filecontent); \
	} \
\
	return real_##sym(pathname, flags, mode); \
} \
OPEN_ALIAS(sym)

OPEN_FCT(open)
OPEN_FCT(open64)
OPEN_FCT(__libc_open)
OPEN_FCT(__libc_open64)
