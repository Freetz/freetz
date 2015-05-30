/*
 * Copyright (C) 2015 freetz.org, Licensed under GPLv2
 *
 * heavily based on code provided by Peter Haemmerlein (opensource@peh-consulting.de)
 */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <limits.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>

#include "privatekeypassword.h"

#define GETPRIVKEYPASS_AVM_UTIL  "/bin/getprivkeypass"

#define GETPRIVKEYPASS_PROXY_ENV "GETPRIVKEYPASS_PROXY"
#define GETPRIVKEYPASS_PROXY     "/bin/getprivkeypass-ftpd-proxy"


/* ============ static helper functions (not part of public API) ============ */

/*
 * checks if the file specified by filename exists, is regular and is executable
 */
static int is_existing_regular_executable(const char *filename) {
	struct stat stat_buf = { 0 };
	return
		(stat(filename, &stat_buf) == 0)                          // exists
		&& S_ISREG(stat_buf.st_mode)                              // is a regular file
		&& ((stat_buf.st_mode & (S_IXUSR|S_IXGRP|S_IXOTH)) != 0); // has at least one of the eXecutable bits set
}

/*
 * invokes cmd and reads at most buf_size bytes of its output to buf (the resulting buf is zero-terminated)
 * returns number of bytes read or -1 in case of an error
 */
static int invoke_capture_stdout(const char *cmd, char *buf, size_t buf_size) {
	FILE *handle = popen(cmd, "r");
	if (!handle) {
#ifndef NDEBUG
		fprintf(stderr, "invoke_capture_stdout: popen failed\n");
#endif
		return -1;
	}

	size_t n = fread(buf, 1, buf_size - 1, handle);
	int status = pclose(handle);
	if (status == -1 || WEXITSTATUS(status) != 0) {
#ifndef NDEBUG
		fprintf(stderr, "invoke_capture_stdout: pclose failed with %d/%d\n", status, WEXITSTATUS(status));
#endif
		return -1;
	}

	buf[n] = '\0';
	return n;
}

/*
 * ROTate Left - left circular shift, implementation taken from http://en.wikipedia.org/wiki/Circular_shift
 */
static unsigned int rotl(unsigned int value, int shift) {
	return (value << shift) | (value >> (sizeof(value) * CHAR_BIT - shift));
}


/* ========================== public API functions ========================== */

/*
 * determines the password of the private key of Fritz!Box SSL-certificate
 * returns password length or -1 in case of an error
 */
int get_private_key_password(char *password_buf, size_t password_buf_size) {
	// AVM's getprivkeypass expects the calling process to contain "ftpd" in its name, check it
	if (strstr(program_invocation_short_name, "ftpd")) {
		// if so AVM's getprivkeypass could by invoked directly
		if (!is_existing_regular_executable(GETPRIVKEYPASS_AVM_UTIL)) {
#ifndef NDEBUG
			fprintf(stderr, "get_private_key_password: vendor tool '%s' is either not found or has wrong permissions\n", GETPRIVKEYPASS_AVM_UTIL);
#endif
			return -1;
		}

		// based on the open-source code from AVM's ftpd,
		// see "password_callback" function in ftpd.c
		char cmd[128] = { 0 };
		unsigned int key = (unsigned int)getpid();
		sprintf(cmd, "%s %u", GETPRIVKEYPASS_AVM_UTIL, key);
		int n = invoke_capture_stdout(cmd, password_buf, password_buf_size);

		// deobfuscate password
		for (int i = 0; i < n; i++) {
			password_buf[i] ^= ( key & 0xFF );
			key = rotl(key, 1);
		}

		return n;
	}

	// if the calling process doesn't contain "ftpd" in its name we have
	// to use a helper proxy tool (a tool containing "ftpd" in its name).
	// the name of the proxy tool could be provided using the environment
	// variable GETPRIVKEYPASS_PROXY (useful on non-freetz'ed boxes),
	// the default one will be used if the variable is not set.
	char *proxy = getenv(GETPRIVKEYPASS_PROXY_ENV);
	if (!proxy) {
		proxy = GETPRIVKEYPASS_PROXY;
	}
	if (!is_existing_regular_executable(proxy)) {
#ifndef NDEBUG
		fprintf(stderr, "get_private_key_password: proxy tool '%s' is either not found or has wrong permissions\n", proxy);
#endif
		return -1;
	}
	return invoke_capture_stdout(proxy, password_buf, password_buf_size);
}
