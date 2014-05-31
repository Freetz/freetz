override CFLAGS     += -fPIC
override CPPFLAGS   += -D_GNU_SOURCE
         LDFLAGS     = -shared
         LIBS        = -ldl
         LIB_VERSION = 0.0.0

all: libmultid.so.$(LIB_VERSION)
	ln -sf libmultid.so.$(LIB_VERSION) libmultid.so

libmultid.so.$(LIB_VERSION): libmultid.o
	$(CC) $(LDFLAGS) -o $@ $< $(LIBS)

clean:
	$(RM) libmultid.o libmultid.so*
