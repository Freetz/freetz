PACKAGE_LC:=jpeg
PACKAGE_UC:=JPEG
$(PACKAGE_UC)_VERSION:=6b
$(PACKAGE_INIT_LIB)
JPEG_LIB_VERSION:=62.0.0
JPEG_SOURCE:=jpegsrc.v$(JPEG_VERSION).tar.gz
JPEG_SITE:=http://ijg.org/files
JPEG_BINARY:=$(JPEG_DIR)/.libs/libjpeg.so.$(JPEG_LIB_VERSION)
JPEG_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg.so.$(JPEG_LIB_VERSION)
JPEG_TARGET_BINARY:=$(JPEG_TARGET_DIR)/libjpeg.so.$(JPEG_LIB_VERSION)


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(JPEG_DIR)/.configured: $(JPEG_DIR)/.unpacked
	( cd $(JPEG_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		CC="$(TARGET_CC)" \
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
	   $(MAKE) -C $(JPEG_DIR)  all

$(JPEG_STAGING_BINARY): $(JPEG_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(JPEG_DIR) \
		libdir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		includedir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		install-headers install-lib

$(JPEG_TARGET_BINARY): $(JPEG_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*.so* $(JPEG_TARGET_DIR)/
	$(TARGET_STRIP) $@

jpeg: $(JPEG_STAGING_BINARY)

jpeg-precompiled: uclibc jpeg $(JPEG_TARGET_BINARY)

jpeg-clean:
	-$(MAKE) -C $(JPEG_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*

jpeg-uninstall:
	rm -f $(JPEG_TARGET_DIR)/libjpeg*.so*

$(PACKAGE_FINI)
