/*
 * Shared library intended to be loaded via LD_PRELOAD.
 * Overrides some uClibc functions to eliminate
 * deficiencies of AVM's user & permission management.
 *
 * (C) 2011 Oliver Metz, Ralf Friedl
 *     2013-2019 cuma
 *
 */

// #define DEBUG

#include <dlfcn.h>      // dlopen, dlsym
#include <stdarg.h>     // vprintf
#include <stdio.h>      // printf, fprintf, rename...
#include <string.h>

#include <limits.h>
#include <stdlib.h>     // exit, system
#include <stdint.h>
#include <unistd.h>

#define xstr(s) str(s)
#define str(s) #s

#ifndef LIBC_LOCATION
#if defined(__UCLIBC__)
#define LIBC_LOCATION "/lib/libc.so." xstr(__UCLIBC_MAJOR__)
#endif
#endif

static void debug_printf(char *fmt, ...) {
#ifdef DEBUG
	va_list ap;
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fflush(stderr);
#endif
}

static int (*real_chmod)(const char *pathname, mode_t mode) = NULL;
static int (*real_rename)(const char *, const char *) = NULL;

static void _libctlmgr_init (void) __attribute__((constructor));
static void _libctlmgr_init (void)
{
	const char *err;

#if defined(RTLD_NEXT) && 0
  /*
   * TODO: doesn't work because of a uClibc bug fixed by the following commit
   *       http://git.uclibc.org/uClibc/commit/ldso/libdl/libdl.c?id=df3a5fcc8d1c3402289375c92df705e978fab58d
   */
	void *libc_handle = RTLD_NEXT;
#else
	void *libc_handle = dlopen(LIBC_LOCATION, RTLD_LOCAL | RTLD_LAZY);
#endif
	if (!libc_handle || NULL != (err = dlerror())) {
		fprintf(stderr, "ctlmgr: libctlmgr unable to get libc-handle: %s\n", err);
		exit(1);
	}

	real_rename = dlsym(libc_handle, "rename");
	if (!real_rename || NULL != (err = dlerror ())) {
		fprintf(stderr, "ctlmgr: libctlmgr unable to get rename-handle: %s\n", err);
		exit(1);
	}

	real_chmod = dlsym(libc_handle, "chmod");
	if (!real_chmod || NULL != (err = dlerror ())) {
		fprintf(stderr, "ctlmgr: libctlmgr unable to get chmod-handle: %s\n", err);
		exit(1);
	}

}

int rename(const char *old, const char *new) {
	debug_printf("ctlmgr: rename() %s --> %s ", old, new);

#ifdef D_RENAME
	if (strcmp(old, "/var/tmp/passwd.tmp")==0) {
		debug_printf("(rejected)\n");
		system("/usr/bin/modusers load");
		return 0;
	}
#endif

	debug_printf("(allowed)\n");
	return real_rename(old, new);
}

int chmod(const char *pathname, mode_t mode) {
	debug_printf("ctlmgr: chmod() %s ", pathname);

#ifdef D_CHMOD
	char* fullpath = realpath(pathname, NULL);
	if(fullpath == NULL) {
		debug_printf("<NULL> ");
	} else {
		debug_printf("--> %s ",fullpath);
		if (strcmp(fullpath, "/var/tmp")==0) {
			debug_printf("(rejected)\n");
			free(fullpath);
			return 0;
		}
		free(fullpath);
	}
#endif

	debug_printf("(allowed)\n");
	return real_chmod(pathname, mode);
}

