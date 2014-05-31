override CFLAGS     += -fPIC
override CPPFLAGS   += -D_GNU_SOURCE
         LDFLAGS     = -shared
         LIBS        = -ldl
         LIB_VERSION = 0.0.0

all: libfakefile.so.$(LIB_VERSION)
	ln -sf libfakefile.so.$(LIB_VERSION) libfakefile.so

libfakefile.so.$(LIB_VERSION): libfakefile.o
	$(CC) $(LDFLAGS) -o $@ $< $(LIBS)

clean:
	$(RM) libfakefile.o libfakefile.so*
