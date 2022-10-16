OPT = -O2
override CFLAGS += -W -Wall $(OPT)

SRCS = ckmain.c cksum.c
OBJS = $(SRCS:%.c=%.o)

tichksum: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

$(SRCS): cksum.h

clean:
	rm -f tichksum *.o

.PHONY: clean
