CC = gcc
LD = ld
CFLAGS = -W -Wall -O2

PROGS = tichksum
OBJS = ckmain.o cksum.o

tichksum: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

clean:
	rm -f $(PROGS) $(OBJS)

ckmain.c: cksum.h
cksum.c:  cksum.h


.PHONY: all clean
