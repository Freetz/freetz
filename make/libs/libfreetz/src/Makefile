CC	= gcc
CFLAGS	= -Os
LFLAGS	=
LIBS	=

all: libfreetz.so.1.0.0

libfreetz.so.1.0.0: libfreetz.o
	$(CC) -o $@ -shared $< $(LFLAGS) $(LIBS)

libfreetz.o: libfreetz.c

install:
	install libfreetz.so.1.0.0 $(DESTDIR)/lib/
	ln -sf libfreetz.so.1.0.0 $(DESTDIR)/lib/libfreetz.so.1
	ln -sf libfreetz.so.1 $(DESTDIR)/lib/libfreetz.so

clean:
	$(RM) libfreetz.o libfreetz.so*

