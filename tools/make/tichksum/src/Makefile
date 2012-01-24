CC = gcc
LD = ld
CFLAGS = -W -Wall -O2
PROGS = tichksum
OBJS += ckmain.o cksum.o

all: $(OBJS)
	$(CC) -o tichksum $(OBJS)

clean:
	rm -f $(PROGS) $(OBJS)

ckmain.c: cksum.h
cksum.c:  cksum.h


.PHONY: all clean
