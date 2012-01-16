override CFLAGS     += -fPIC
         LDFLAGS     = -shared
         LIB_VERSION = 0.0.0

all: libfreetz.so.$(LIB_VERSION)
	ln -sf libfreetz.so.$(LIB_VERSION) libfreetz.so

libfreetz.so.$(LIB_VERSION): libfreetz.o
	$(CC) $(LDFLAGS) $(LIBS) -o $@ $<

clean:
	$(RM) libfreetz.o libfreetz.so*
