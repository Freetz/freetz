/*
 * Copyright (C) 2015 freetz.org, Licensed under GPLv2
 */

#include <stdlib.h>
#include <stdio.h>

#include "privatekeypassword.h"

int main(int argc, char ** argv) {
	char password[32] = { 0 };
	int n = get_private_key_password(password, sizeof(password));
	if (!(n > 0)) {
		return EXIT_FAILURE;
	}

	fprintf(stdout, "%s", password);
	fflush(stdout);

	return EXIT_SUCCESS;
}
