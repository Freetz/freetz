override CFLAGS     += -fPIC
override CPPFLAGS   += -D_GNU_SOURCE
         LDFLAGS     = -shared
         LIBS        = -ldl
         LIB_VERSION = 0.0.0

all: libctlmgr.so.$(LIB_VERSION)
	ln -sf libctlmgr.so.$(LIB_VERSION) libctlmgr.so

libctlmgr.so.$(LIB_VERSION): libctlmgr.o
	$(CC) $(LDFLAGS) -o $@ $< $(LIBS)

clean:
	$(RM) libctlmgr.o libctlmgr.so*
