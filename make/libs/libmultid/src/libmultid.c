/*
	Copyright (C) 2012 cuma
	Copyright (C) 2011 Joerg Jungermann

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
*/

/*
	LD_PRELOAD library to make bind and connect to use a virtual
	IP address as local address an tpc/udp ports.

	If you remap the IP, note that you have to set up your server's
	virtual IP first.

	This version does only remaps port 53 (dns) to satisfy multid.
	So another dns-server could be used, avm's dynamic-dns updater
	and timesync are working correctly.

	Example in bash to let multid not listen at port 53:
	LD_PRELOAD=libmultid.so.1.0.0 /sbin/multid

	Compile on Linux with:
	gcc -nostartfiles -fpic -shared bind.c -o bind.so -ldl -D_GNU_SOURCE

	v1: initial
	v2: only dns remap
	v3: dhcp & llmnr remap
	v4: localhost binding
*/

// #define DEBUG

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <dlfcn.h>
#include <errno.h>

int (*real_bind)(int, const struct sockaddr *, socklen_t);
int (*real_connect)(int, const struct sockaddr *, socklen_t);

struct sockaddr_in local_sockaddr_in[] = { 0 };
#ifdef D_IPV6
struct sockaddr_in6 local_sockaddr_in6[] = { 0 };
#endif


void _init (void)
{
#ifdef DEBUG
	printf("[_init()]\n");
#endif

	const char *err;

	// better, but this does not work because AVM messes up the symboltable in libled.so
	//void * real_bind = dlsym (RTLD_NEXT, "bind");
	// AVM fix:
	void * uclibc = dlopen("/lib/libc.so.0", RTLD_LOCAL | RTLD_LAZY);
	
	real_bind = dlsym (uclibc , "bind");
	if ((err = dlerror ()) != NULL)
		fprintf (stderr, "dlsym (bind): %s\n", err);

	local_sockaddr_in->sin_family = AF_INET;
	local_sockaddr_in->sin_port = htons (0);
	inet_pton(AF_INET, "0.0.0.0", &local_sockaddr_in->sin_addr);
#ifdef D_IPV6
	local_sockaddr_in6->sin6_family = AF_INET6;
	local_sockaddr_in6->sin6_port = htons (0);
	local_sockaddr_in6->sin6_flowinfo = 0;
	inet_pton(AF_INET6, "::", &local_sockaddr_in6->sin6_addr);
#endif
}

int bind (int fd, const struct sockaddr *sk, socklen_t sl)
{
#ifdef DEBUG
	printf("[libmultid::bind()]\n");
#endif

	static struct sockaddr_in *lsk_in;
	lsk_in = (struct sockaddr_in *)sk;
#ifdef D_IPV6
	static struct sockaddr_in6 *lsk_in6;
	lsk_in6 = (struct sockaddr_in6 *)sk;
	static char addr_buf[INET6_ADDRSTRLEN];
#else
	static char addr_buf[INET_ADDRSTRLEN];
#endif

	if (lsk_in->sin_family == AF_INET) {
		inet_ntop(AF_INET, &lsk_in->sin_addr, addr_buf, sizeof(lsk_in->sin_addr));
#ifdef DEBUG
		printf("[libmultid::bind()] IPv4 fd=%d %s:%d\n", fd, addr_buf, ntohs (lsk_in->sin_port));
#endif
		if (lsk_in->sin_addr.s_addr == INADDR_ANY)
		{
#ifdef D_LOCAL
			inet_pton(AF_INET, "127.0.0.1", &lsk_in->sin_addr.s_addr);
#endif
			switch (ntohs(lsk_in->sin_port))
			{
#ifdef D_DNS
				case 53:
					lsk_in->sin_port = htons(53004);
					break;
#endif
#ifdef D_DHCP
				case 67:
					lsk_in->sin_port = htons(53674);
					break;
#endif
#ifdef D_LLMNR
				case 5353:
					lsk_in->sin_port = htons(53534);
					break;
				case 5355:
					lsk_in->sin_port = htons(53554);
					break;
#endif
				default:
					lsk_in->sin_addr.s_addr = local_sockaddr_in->sin_addr.s_addr;
			}

#ifdef DEBUG
			inet_ntop(AF_INET, &lsk_in->sin_addr, addr_buf, sizeof(lsk_in->sin_addr));
			printf("[libmultid::bind()] IPv4 fd=%d %s:%d\n", fd, addr_buf, ntohs (lsk_in->sin_port));
#endif
		}
	}
#ifdef D_IPV6
	else if (lsk_in6->sin6_family == AF_INET6) {
		inet_ntop(AF_INET6, &lsk_in6->sin6_addr, addr_buf, sizeof(lsk_in6->sin6_addr));
#ifdef DEBUG
		printf("[libmultid::bind()] IPv6 fd=%d [%s]:%d\n", fd, addr_buf, ntohs (lsk_in6->sin6_port));
#endif
		if (memcmp(&lsk_in6->sin6_addr, &in6addr_any, sizeof(in6addr_any)) == 0)
		{
#ifdef D_LOCAL
			inet_pton(AF_INET6, "::1", &lsk_in6->sin6_addr);
#endif

			switch (ntohs(lsk_in6->sin6_port))
			{
#ifdef D_DNS
				case 53:
					lsk_in6->sin6_port = htons(53006);
					break;
#endif
#ifdef D_DHCP
				case 67:
					lsk_in6->sin6_port = htons(53676);
					break;
#endif
#ifdef D_LLMNR
				case 5353:
					lsk_in6->sin6_port = htons(53536);
					break;
				case 5355:
					lsk_in6->sin6_port = htons(53556);
					break;
#endif
				default:
					lsk_in6->sin6_addr = local_sockaddr_in6->sin6_addr;
			}
			
#ifdef DEBUG
			inet_ntop(AF_INET6, &lsk_in6->sin6_addr, addr_buf, sizeof(lsk_in6->sin6_addr));
			printf("[libmultid::bind()] IPv6 fd=%d [%s]:%d\n", fd, addr_buf, ntohs (lsk_in6->sin6_port));
#endif
		}

	}
#endif
#ifdef DEBUG
	else
		printf("[libmultid::bind()] address familiy unknown IPv? af=%d fd=%d\n", fd, lsk_in->sin_family);
#endif

	return real_bind (fd, sk, sl);
}
