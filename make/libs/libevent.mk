PACKAGE_LC:=libevent
PACKAGE_UC:=LIBEVENT
$(PACKAGE_UC)_VERSION:=1.3e
$(PACKAGE_INIT_LIB)
LIBEVENT_LIB_VERSION:=1.0.3
LIBEVENT_SOURCE:=libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_SITE:=http://www.monkey.org/~provos
LIBEVENT_BINARY:=$(LIBEVENT_DIR)/.libs/libevent-$(LIBEVENT_VERSION).so.$(LIBEVENT_LIB_VERSION)
LIBEVENT_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent-$(LIBEVENT_VERSION).so.$(LIBEVENT_LIB_VERSION)
LIBEVENT_TARGET_BINARY:=$(LIBEVENT_TARGET_DIR)/libevent-$(LIBEVENT_VERSION).so.$(LIBEVENT_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(LIBEVENT_DIR)/.configured: $(LIBEVENT_DIR)/.unpacked
	( cd $(LIBEVENT_DIR); rm -f config.status; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-XCClinker -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		ac_cv_func_epoll_ctl=no \
		ac_cv_header_sys_epoll_h=no \
		./configure \
		  --target=$(GNU_TARGET_NAME) \
		  --host=$(GNU_TARGET_NAME) \
		  --build=$(GNU_HOST_NAME) \
		  --program-prefix="" \
		  --program-suffix="" \
		  --prefix=/usr \
		  --exec-prefix=/usr \
		  --bindir=/usr/bin \
		  --datadir=/usr/share \
		  --includedir=/usr/include \
		  --infodir=/usr/share/info \
		  --libdir=/usr/lib \
		  --libexecdir=/usr/lib \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --sbindir=/usr/sbin \
		  --sysconfdir=/etc \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --enable-shared \
		  --disable-static \
	);
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(LIBEVENT_DIR)

$(LIBEVENT_STAGING_BINARY): $(LIBEVENT_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBEVENT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-strip
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libevent.la

$(LIBEVENT_TARGET_BINARY): $(LIBEVENT_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*.so* $(LIBEVENT_TARGET_DIR)/
	$(TARGET_STRIP) $@

libevent: $(LIBEVENT_STAGING_BINARY)

libevent-precompiled: uclibc libevent $(LIBEVENT_TARGET_BINARY)

libevent-clean:
	-$(MAKE) -C $(LIBEVENT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*

libevent-uninstall:
	rm -f $(LIBEVENT_TARGET_DIR)/libevent*.so*

$(PACKAGE_FINI)
