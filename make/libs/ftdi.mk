PACKAGE_LC:=ftdi
PACKAGE_UC:=FTDI
$(PACKAGE_UC)_VERSION:=0.7
$(PACKAGE_INIT_LIB)
FTDI_LIB_VERSION:=0.7.0
FTDI_SOURCE:=libftdi-$(FTDI_VERSION).tar.gz
FTDI_SITE:=http://www.intra2net.com/de/produkte/opensource/ftdi/TGZ
FTDI_DIR:=$(SOURCE_DIR)/libftdi-$(FTDI_VERSION)
FTDI_BINARY:=$(FTDI_DIR)/src/.libs/libftdi.so.$(FTDI_LIB_VERSION)
FTDI_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi.so.$(FTDI_LIB_VERSION)
FTDI_TARGET_BINARY:=$(FTDI_TARGET_DIR)/libftdi.so.$(FTDI_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


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

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(FTDI_DIR) all

$(FTDI_STAGING_BINARY): $(FTDI_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(FTDI_DIR) \
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    install
	$(SED) -i -e "s,^inlcudedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libftdi.pc

$(FTDI_TARGET_BINARY): $(FTDI_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi*.so* $(FTDI_TARGET_DIR)/
	$(TARGET_STRIP) $@

ftdi: $(FTDI_STAGING_BINARY)

ftdi-precompiled: uclibc usb-precompiled ftdi $(FTDI_TARGET_BINARY)

ftdi-clean:
	-$(MAKE) -C $(FTDI_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi*

ftdi-uninstall:
	rm -f $(FTDI_TARGET_DIR)/libftdi*.so*

$(PACKAGE_FINI)
