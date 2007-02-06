LIBPCAP_VERSION:=0.9.5
LIBPCAP_SOURCE:=libpcap-$(LIBPCAP_VERSION).tar.gz
LIBPCAP_SITE:=http://www.tcpdump.org/release/
LIBPCAP_DIR:=$(SOURCE_DIR)/libpcap-$(LIBPCAP_VERSION)
LIBPCAP_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(LIBPCAP_SOURCE):
	wget -P $(DL_DIR) $(LIBPCAP_SITE)/$(LIBPCAP_SOURCE)

$(LIBPCAP_DIR)/.unpacked: $(DL_DIR)/$(LIBPCAP_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBPCAP_SOURCE)
	for i in $(LIBPCAP_MAKE_DIR)/patches/*.libpcap.patch; do \
		patch -d $(LIBPCAP_DIR) -p0 < $$i; \
	done
	touch $@

$(LIBPCAP_DIR)/.configured: $(LIBPCAP_DIR)/.unpacked
	( cd $(LIBPCAP_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDSHARED="$(TARGET_CC) -static-libgcc -shared -Wl,-soname,libpcap.so.0.8" \
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
	);
	touch $@

$(LIBPCAP_DIR)/.compiled: $(LIBPCAP_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBPCAP_DIR) \
		$(TARGET_CONFIGURE_OPTS) 
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap.so: $(LIBPCAP_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBPCAP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install install-shared
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
libpcap libpcap-precompiled:
	@echo 'External compiler used. Skipping libpcap...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libpcap*.so* root/usr/lib/
else
libpcap: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap.so
libpcap-precompiled: libpcap
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap*.so* root/usr/lib/
endif

libpcap-source: $(LIBPCAP_DIR)/.unpacked

libpcap-clean:
	-$(MAKE) -C $(LIBPCAP_DIR) clean

libpcap-install: libpcap-precompiled

libpcap-uninstall:
	rm -rf root/usr/lib/libpcap*.so*
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBPCAP_DIR) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" uninstall

libpcap-dirclean:
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBPCAP_DIR) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" uninstall
	rm -rf $(LIBPCAP_DIR)

