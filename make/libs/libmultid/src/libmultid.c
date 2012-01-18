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

// #define DEBUG

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <dlfcn.h>
#include <errno.h>

static int (*real_bind)(int, const struct sockaddr *, socklen_t);


void _init (void)
{
#ifdef DEBUG
	printf("[_init()]\n");
#endif

	const char *err;

	// better, but this does not work because AVM messes up the symboltable in libled.so
	//void * real_bind = dlsym (RTLD_NEXT, "bind");
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

static int
change_port (u_short *pport)
{
	u_short port = ntohs (*pport);
	switch (port) {
#ifdef D_DNS
	case 53:
#endif
#ifdef D_DHCP
	case 67:
#endif
#ifdef D_LLMNR
	case 5353:
	case 5355:
#endif
		port += 50000;
		*pport = htons (port);
		return 1;
	default:
		return 0;
	}
}

int bind (int fd, const struct sockaddr *sk, socklen_t sl)
{
	switch (sk->sa_family) {
	case AF_INET: {
		struct sockaddr_in *lsk_in = (struct sockaddr_in *)sk;
#ifdef DEBUG
		char addr_buf[INET_ADDRSTRLEN];
		inet_ntop(AF_INET, &lsk_in->sin_addr, addr_buf, sizeof(addr_buf));
		printf("[libmultid::bind()] IPv4 fd=%d %s:%d\n", fd, addr_buf, ntohs (lsk_in->sin_port));
#endif
		if (change_port (&lsk_in->sin_port))
			BIND_TO_LOCAL4(lsk_in->sin_addr.s_addr);
#ifdef DEBUG
		inet_ntop(AF_INET, &lsk_in->sin_addr, addr_buf, sizeof(addr_buf));
		printf("[libmultid::bind()] IPv4 fd=%d %s:%d\n", fd, addr_buf, ntohs (lsk_in->sin_port));
#endif
		}
		break;
#ifdef D_IPV6
	case AF_INET6: {
		struct sockaddr_in6 *lsk_in6 = (struct sockaddr_in6 *)sk;
#ifdef DEBUG
		char addr_buf[INET6_ADDRSTRLEN];
		inet_ntop(AF_INET6, &lsk_in6->sin6_addr, addr_buf, sizeof(addr_buf));
		printf("[libmultid::bind()] IPv6 fd=%d [%s]:%d\n", fd, addr_buf, ntohs (lsk_in6->sin6_port));
#endif
		if (change_port (&lsk_in6->sin6_port))
			BIND_TO_LOCAL6(lsk_in6->sin6_addr);
#ifdef DEBUG
		inet_ntop(AF_INET6, &lsk_in6->sin6_addr, addr_buf, sizeof(addr_buf));
		printf("[libmultid::bind()] IPv6 fd=%d [%s]:%d\n", fd, addr_buf, ntohs (lsk_in6->sin6_port));
#endif
		}
		break;
#endif
#ifdef DEBUG
	default:
		printf("[libmultid::bind()] address family unknown af=%d fd=%d\n", sk->sa_family, fd);
		break;
#endif
	}
	return real_bind (fd, sk, sl);
}
