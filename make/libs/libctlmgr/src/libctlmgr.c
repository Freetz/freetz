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
#if defined(D_UCLIBC)
#define LIBC_LOCATION "/lib/libc.so." xstr(__UCLIBC_MAJOR__)
#endif
#if defined(D_MUSL)
#define LIBC_LOCATION "/lib/libc.so"
#endif
#if defined(D_GLIBC)
#define LIBC_LOCATION "/lib/libc.so.6"
#endif
#endif

#ifdef DEBUG
static void debug_printf(char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fflush(stderr);
}
#endif

static int (*real_chmod)(const char *pathname, mode_t mode) = NULL;
static int (*real_rename)(const char *, const char *) = NULL;

static void _libctlmgr_init (void) __attribute__((constructor));
static void _libctlmgr_init (void) {
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
#ifdef DEBUG
	debug_printf("ctlmgr: rename() %s --> %s ", old, new);
#endif

#ifdef D_RENAME
	if (strcmp(old, "/var/tmp/passwd.tmp")==0) {
#ifdef DEBUG
		debug_printf("(rejected)\n");
#endif
		system("/usr/bin/modusers update");
		return 0;
	}
#endif

#ifdef DEBUG
	debug_printf("(allowed)\n");
#endif
	return real_rename(old, new);
}

int chmod(const char *pathname, mode_t mode) {
#ifdef DEBUG
	debug_printf("ctlmgr: chmod() %s ", pathname);
#endif

#ifdef D_CHMOD
	char* fullpath = realpath(pathname, NULL);
	if(fullpath == NULL) {
#ifdef DEBUG
		debug_printf("<NULL> ");
#endif
	} else {
#ifdef DEBUG
		debug_printf("--> %s ",fullpath);
#endif
		if (strcmp(fullpath, "/var/tmp")==0) {
#ifdef DEBUG
			debug_printf("(rejected)\n");
#endif
			free(fullpath);
			return 0;
		}
		free(fullpath);
	}
#endif

#ifdef DEBUG
	debug_printf("(allowed)\n");
#endif
	return real_chmod(pathname, mode);
}

