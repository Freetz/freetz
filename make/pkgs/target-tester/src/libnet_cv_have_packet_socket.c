#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <features.h>    /* for the glibc version number */
#if __GLIBC__ >= 2 && __GLIBC_MINOR >= 1
#include <netpacket/packet.h>
#include <net/ethernet.h>     /* the L2 protocols */
#else
#include <asm/types.h>
#include <linux/if_packet.h>
#include <linux/if_ether.h>   /* The L2 protocols */
#endif

#ifndef SOL_PACKET
#define SOL_PACKET 263
#endif  /* SOL_PACKET */

int main(int argc, char **argv) {
    int fd;

    fd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    if (fd == -1) {
        if (errno == EPERM) {
            /* user's UID != 0 */
            printf("probably\n");
            exit (EXIT_FAILURE);
        }
        printf("no\n");
        exit (EXIT_FAILURE);
    }
    printf("yes\n");
    exit (EXIT_SUCCESS);
}
