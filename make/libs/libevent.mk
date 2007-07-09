LIBEVENT_VERSION:=1.3b
LIBEVENT_LIB_VERSION:=1.0.3
LIBEVENT_SOURCE:=libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_SITE:=http://www.monkey.org/~provos
LIBEVENT_MAKE_DIR:=$(MAKE_DIR)/libs
LIBEVENT_DIR:=$(SOURCE_DIR)/libevent-$(LIBEVENT_VERSION)
LIBEVENT_BINARY:=$(LIBEVENT_DIR)/.libs/libevent-$(LIBEVENT_VERSION).so.$(LIBEVENT_LIB_VERSION)
LIBEVENT_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent-$(LIBEVENT_VERSION).so.$(LIBEVENT_LIB_VERSION)
LIBEVENT_TARGET_DIR:=root/usr/lib
LIBEVENT_TARGET_BINARY:=$(LIBEVENT_TARGET_DIR)/libevent-$(LIBEVENT_VERSION).so.$(LIBEVENT_LIB_VERSION)

$(DL_DIR)/$(LIBEVENT_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LIBEVENT_SITE)/$(LIBEVENT_SOURCE)

$(LIBEVENT_DIR)/.unpacked: $(DL_DIR)/$(LIBEVENT_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBEVENT_SOURCE)
	for i in $(LIBEVENT_MAKE_DIR)/patches/*.libevent.patch; do \
		patch -d $(LIBEVENT_DIR) -p0 < $$i; \
	done
	touch $@

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

$(LIBEVENT_BINARY): $(LIBEVENT_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBEVENT_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		libevent.la

$(LIBEVENT_STAGING_BINARY): $(LIBEVENT_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBEVENT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-strip

$(LIBEVENT_TARGET_BINARY): $(LIBEVENT_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*.so* $(LIBEVENT_TARGET_DIR)/
	$(TARGET_STRIP) $@

libevent: $(LIBEVENT_STAGING_BINARY)

libevent-precompiled: uclibc libevent $(LIBEVENT_TARGET_BINARY)

libevent-source: $(LIBEVENT_DIR)/.unpacked

libevent-clean:
	-$(MAKE) -C $(LIBEVENT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libevent*

libevent-uninstall:
	rm -f $(LIBEVENT_TARGET_DIR)/libevent*.so*

libevent-dirclean:
	rm -rf $(LIBEVENT_DIR)
