OPT = -O2
override CFLAGS += -W -Wall $(OPT)

SRCS = avm-rle-decode.c
OBJS = $(SRCS:%.c=%.o)

avm-rle-decode: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

clean:
	rm -f avm-rle-decode *.o

.PHONY: clean
