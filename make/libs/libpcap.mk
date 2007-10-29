PACKAGE_LC:=libpcap
PACKAGE_UC:=LIBPCAP
$(PACKAGE_UC)_VERSION:=0.9.6
$(PACKAGE_INIT_LIB)
LIBPCAP_LIB_VERSION:=$(LIBPCAP_VERSION)
LIBPCAP_SOURCE:=libpcap-$(LIBPCAP_VERSION).tar.gz
LIBPCAP_SITE:=http://www.tcpdump.org/release/
LIBPCAP_BINARY:=$(LIBPCAP_DIR)/libpcap.so.$(LIBPCAP_LIB_VERSION)
LIBPCAP_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap.so.$(LIBPCAP_LIB_VERSION)
LIBPCAP_TARGET_BINARY:=$(LIBPCAP_TARGET_DIR)/libpcap.so.$(LIBPCAP_LIB_VERSION)


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(LIBPCAP_DIR)/.configured: $(LIBPCAP_DIR)/.unpacked
	( cd $(LIBPCAP_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		ac_cv_linux_vers=2.6.13.1 \
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
		--with-pcap=linux \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_LZO) \
		--enable-shared \
		--enable-static \
		--disable-pthread \
		--enable-debug \
		--disable-plugins \
		--disable-management \
		--disable-socks \
		--disable-http \
		--enable-password-save \
		--enable-small \
		--enable-shared \
		--enable-static \
		--disable-yydebug \
		--with-build-cc="$(HOSTCC)" \
	);
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBPCAP_DIR) all \
		CCOPT="-fPIC $(TARGET_CFLAGS)"

$(LIBPCAP_STAGING_BINARY): $(LIBPCAP_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBPCAP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(LIBPCAP_TARGET_BINARY): $(LIBPCAP_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap*.so* $(LIBPCAP_TARGET_DIR)/
	$(TARGET_STRIP) $@

libpcap: $(LIBPCAP_STAGING_BINARY)

libpcap-precompiled: uclibc libpcap $(LIBPCAP_TARGET_BINARY)

libpcap-clean:
	-$(MAKE) -C $(LIBPCAP_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap*

libpcap-uninstall:
	rm -f $(LIBPCAP_TARGET_DIR)/libpcap*.so*

$(PACKAGE_FINI)