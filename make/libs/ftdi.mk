FTDI_VERSION:=0.7
FTDI_LIB_VERSION:=0.7.0
FTDI_SOURCE:=libftdi-$(FTDI_VERSION).tar.gz
FTDI_SITE:=http://www.intra2net.com/de/produkte/opensource/ftdi/TGZ
FTDI_MAKE_DIR:=$(MAKE_DIR)/libs
FTDI_DIR:=$(SOURCE_DIR)/libftdi-$(FTDI_VERSION)
FTDI_BINARY:=$(FTDI_DIR)/.libs/libFTDI.so.$(FTDI_LIB_VERSION)
FTDI_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi.so.$(FTDI_LIB_VERSION)
FTDI_TARGET_DIR:=root/usr/lib
FTDI_TARGET_BINARY:=$(FTDI_TARGET_DIR)/libftdi.so.$(FTDI_LIB_VERSION)

$(DL_DIR)/$(FTDI_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(FTDI_SITE)/$(FTDI_SOURCE)

$(FTDI_DIR)/.unpacked: $(DL_DIR)/$(FTDI_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FTDI_SOURCE)
	#for i in $(FTDI_MAKE_DIR)/patches/*.ftdi.patch; do \
	#	$(PATCH_TOOL) $(FTDI_DIR) $$i; \
	#done
	touch $@

$(FTDI_DIR)/.configured: $(FTDI_DIR)/.unpacked
	( cd $(FTDI_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
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
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--enable-shared \
		--enable-static \
	);
	touch $@

$(FTDI_BINARY): $(FTDI_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(FTDI_DIR)  all

$(FTDI_STAGING_BINARY): $(FTDI_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(FTDI_DIR) \
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    install

$(FTDI_TARGET_BINARY): $(FTDI_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi*.so* $(FTDI_TARGET_DIR)/
	$(TARGET_STRIP) $@

ftdi: $(FTDI_STAGING_BINARY)

ftdi-precompiled: uclibc usb-precompiled ftdi $(FTDI_TARGET_BINARY)

ftdi-source: $(FTDI_DIR)/.unpacked

ftdi-clean:
	-$(MAKE) -C $(FTDI_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi*

ftdi-uninstall:
	rm -f $(FTDI_TARGET_DIR)/libftdi*.so*

ftdi-dirclean:
	rm -rf $(FTDI_DIR)
