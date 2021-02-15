CC = gcc
CFLAGS = -W -Wall -O2
PROGS = find-squashfs
OBJS += find-squashfs.o

all: $(OBJS)
	$(CC) $(LDFLAGS) -o find-squashfs $(OBJS)

clean:
	rm -f $(PROGS) $(OBJS)


.PHONY: all clean
