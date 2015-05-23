/*
 * Licensed under GPLv2
 *  Copyright (C) 2014, Peter Haemmerlein (opensource@peh-consulting.de)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program, please look for the file COPYING.
 */

/*
 * - adapted from AVM's ftpd server, we should better call securestore_get from libboxlib ourself,
 *   but we'll defer this until AVM changes the behavior of getprivkeypass utility
 *
 * - the getprivkeypass utility tries to protect itself against being fooled, so we have to call
 *   it from a parent process containing a 'ftpd' string within the command line and the process
 *   image file name of 'ftpd' in /proc/$PPID/stat content too
 *
 * - in general it's a good idea to obfuscate the password a little bit, but it's useless to
 *   protect against evil guys, if they try to unveil our very own private key
 *
 * - therefore it's better to express it clear: storing the private key is *necessary* and you can't
 *   work around this security threat ... so you better do not use the same private key anywhere
 *   else and keep in mind, that the FRITZ!Box key and certificate (finally the identity of the
 *   device) are suspicious anytime
 *
 * - nevertheless using a secured connection and a consistent identity of the FRITZ!Box router is
 *   better than using an open connection and many different identities for various services,
 *   because there's a higher probability that the user gets confused while using different keys
 *
 * - having a solution to use the same private key for different services does not mean, you're
 *   obliged to use the same identity, but you get the *chance* to do so
 */

#define _BSD_SOURCE

#include <limits.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#define AVM_COMMAND "/bin/getprivkeypass"

static int is_existing_regular_executable(const char * filename) {
	struct stat stat_buf = { 0 };
	return
		(stat(filename, &stat_buf) == 0)                          // exists
		&& S_ISREG(stat_buf.st_mode)                              // is a regular file
		&& ((stat_buf.st_mode & (S_IXUSR|S_IXGRP|S_IXOTH)) != 0); // has at least one of the eXecutable bits set
}

// (left) circular shift, taken from http://en.wikipedia.org/wiki/Circular_shift
static unsigned int rotl(unsigned int value, int shift) {
	return (value << shift) | (value >> (sizeof(value) * CHAR_BIT - shift));
}

int main(int argc, char ** argv) {
	if (!strstr(argv[0], "ftpd")) {
		return EXIT_FAILURE;
	}

	if (!is_existing_regular_executable(AVM_COMMAND)) {
		return EXIT_FAILURE;
	}

	// based on the code from AVM's ftpd, see "password_callback" function in ftpd.c
	char password[32 + 1] = { 0 };

	unsigned int key = (unsigned int)getpid();
	char cmd[128] = { 0 };
	sprintf(cmd, "%s %u", AVM_COMMAND, key);

	FILE *pipe_handle = popen(cmd, "r");
	if (!pipe_handle) {
		return EXIT_FAILURE;
	}

	size_t n = fread(password, 1, sizeof(password) - 1, pipe_handle);
	pclose(pipe_handle);
	if (!(n > 0)) {
		return EXIT_FAILURE;
	}

	// de-obfuscate password
	for (int i = 0; i < n; i++) {
		password[i] ^= ( key & 0xFF );
		/*
		 * original AVM code
		 *   int bit = (key & 0x80000000);
		 *   key <<= 1;
		 *   if (bit) key |= 1;
		 * is just a (left) circular shift
		*/
		key = rotl(key, 1);
	}
	password[n] = '\0';

	fprintf(stdout, "%s", password);
	fflush(stdout);

	return EXIT_SUCCESS;
}
