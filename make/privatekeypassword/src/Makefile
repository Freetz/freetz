LIB      = privatekeypassword
LIB_SRCS = privatekeypassword.c
LIB_OBJS = $(LIB_SRCS:%.c=%.o)

LIB_PUBLIC_HDRS = privatekeypassword.h

PROXY = getprivkeypass-ftpd-proxy

CC = gcc
override CFLAGS += -Wall -std=c99
override CPPFLAGS += -DNDEBUG

AR = ar
RANLIB = ranlib

all: lib$(LIB).so lib$(LIB).a $(PROXY) $(PROXY)-static

install-lib: lib$(LIB).so lib$(LIB).a
	mkdir -p $(DESTDIR)/usr/include/$(LIB) $(DESTDIR)/usr/lib
	cp -a $(LIB_PUBLIC_HDRS) $(DESTDIR)/usr/include/$(LIB)/
	cp -a lib$(LIB).so lib$(LIB).a $(DESTDIR)/usr/lib/

lib$(LIB).so: $(LIB_OBJS)
	$(CC) -shared -o $@ $<

lib$(LIB).a: $(LIB_OBJS)
	$(RM) $@
	$(AR) rcu $@ $<
	$(RANLIB) $@

$(PROXY): $(PROXY).o | lib$(LIB).so
	$(CC) $(LDFLAGS) $(filter %.o,$<) -L. -l$(LIB) -o $@

$(PROXY)-static: $(PROXY).o lib$(LIB).a
	$(CC) $(LDFLAGS) $(filter %.o,$<) -L. -Wl,-Bstatic -l$(LIB) -Wl,-Bdynamic -o $@

$(LIB_OBJS) $(PROXY).o: %.o: %.c
$(LIB_OBJS): CFLAGS += -fPIC

clean:
	@$(RM) *.o *.a *.so $(PROXY) $(PROXY)-static
