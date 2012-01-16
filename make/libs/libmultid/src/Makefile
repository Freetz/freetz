CC	= gcc
COPTS   =
CFLAGS	= -Os
LFLAGS	=
LIBS	= -ldl

all: libmultid.so.1.0.0

libmultid.so.1.0.0: libmultid.o
	@$(CC) $(COPTS) -nostartfiles -shared -o $@ $< $(LFLAGS) $(LIBS)

libmultid.o: libmultid.c

install:
	install libmultid.so.1.0.0 $(DESTDIR)/lib/
	ln -sf libmultid.so.1.0.0 $(DESTDIR)/lib/libmultid.so.5
	ln -sf libmultid.so.5 $(DESTDIR)/lib/libmultid.so

clean:
	$(RM) libmultid.o libmultid.so*

