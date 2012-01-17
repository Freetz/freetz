/*
	Copyright (C) 2012 cuma, er13
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
	v5: libdl added: need by multid to execute onlinechanged
	v6: optimizations
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
}

#ifdef D_LOCAL
#define BIND_TO_LOCAL4(_sin4_addr)	_sin4_addr = htonl(INADDR_LOOPBACK)
#define BIND_TO_LOCAL6(_sin6_addr)	_sin6_addr = in6addr_loopback
#else
#define BIND_TO_LOCAL4(_sin4_addr)
#define BIND_TO_LOCAL6(_sin6_addr)
#endif

int bind (int fd, const struct sockaddr *sk, socklen_t sl)
{
#ifdef DEBUG
	printf("[libmultid::bind()]\n");
#endif

	struct sockaddr_in *lsk_in;
	lsk_in = (struct sockaddr_in *)sk;
#ifdef D_IPV6
	struct sockaddr_in6 *lsk_in6;
	lsk_in6 = (struct sockaddr_in6 *)sk;
#endif

#ifdef DEBUG
#ifdef D_IPV6
	char addr_buf[INET6_ADDRSTRLEN];
#else
	char addr_buf[INET_ADDRSTRLEN];
#endif
#endif

	if (lsk_in->sin_family == AF_INET) {
#ifdef DEBUG
		inet_ntop(AF_INET, &lsk_in->sin_addr, addr_buf, sizeof(lsk_in->sin_addr));
		printf("[libmultid::bind()] IPv4 fd=%d %s:%d\n", fd, addr_buf, ntohs (lsk_in->sin_port));
#endif
		if (lsk_in->sin_addr.s_addr == INADDR_ANY)
		{
			switch (ntohs(lsk_in->sin_port))
			{
#ifdef D_DNS
				case 53:
					lsk_in->sin_port = htons(53004);
					BIND_TO_LOCAL4(lsk_in->sin_addr.s_addr);
					break;
#endif
#ifdef D_DHCP
				case 67:
					lsk_in->sin_port = htons(53674);
					BIND_TO_LOCAL4(lsk_in->sin_addr.s_addr);
					break;
#endif
#ifdef D_LLMNR
				case 5353:
					lsk_in->sin_port = htons(53534);
					BIND_TO_LOCAL4(lsk_in->sin_addr.s_addr);
					break;
				case 5355:
					lsk_in->sin_port = htons(53554);
					BIND_TO_LOCAL4(lsk_in->sin_addr.s_addr);
					break;
#endif
				default:
					break;
			}

#ifdef DEBUG
			inet_ntop(AF_INET, &lsk_in->sin_addr, addr_buf, sizeof(lsk_in->sin_addr));
			printf("[libmultid::bind()] IPv4 fd=%d %s:%d\n", fd, addr_buf, ntohs (lsk_in->sin_port));
#endif
		}
	}
#ifdef D_IPV6
	else if (lsk_in6->sin6_family == AF_INET6) {
#ifdef DEBUG
		inet_ntop(AF_INET6, &lsk_in6->sin6_addr, addr_buf, sizeof(lsk_in6->sin6_addr));
		printf("[libmultid::bind()] IPv6 fd=%d [%s]:%d\n", fd, addr_buf, ntohs (lsk_in6->sin6_port));
#endif
		if (memcmp(&lsk_in6->sin6_addr, &in6addr_any, sizeof(in6addr_any)) == 0)
		{
			switch (ntohs(lsk_in6->sin6_port))
			{
#ifdef D_DNS
				case 53:
					lsk_in6->sin6_port = htons(53006);
					BIND_TO_LOCAL6(lsk_in6->sin6_addr);
					break;
#endif
#ifdef D_DHCP
				case 67:
					lsk_in6->sin6_port = htons(53676);
					BIND_TO_LOCAL6(lsk_in6->sin6_addr);
					break;
#endif
#ifdef D_LLMNR
				case 5353:
					lsk_in6->sin6_port = htons(53536);
					BIND_TO_LOCAL6(lsk_in6->sin6_addr);
					break;
				case 5355:
					lsk_in6->sin6_port = htons(53556);
					BIND_TO_LOCAL6(lsk_in6->sin6_addr);
					break;
#endif
				default:
					break;
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
