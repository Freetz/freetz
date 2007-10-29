PACKAGE_LC:=zlib
PACKAGE_UC:=ZLIB
$(PACKAGE_UC)_VERSION:=1.2.3
$(PACKAGE_INIT_LIB)
ZLIB_LIB_VERSION:=$(ZLIB_VERSION)
ZLIB_SOURCE:=zlib-$(ZLIB_VERSION).tar.gz
ZLIB_SITE:=http://mesh.dl.sourceforge.net/sourceforge/libpng
ZLIB_BINARY:=$(ZLIB_DIR)/libz.so.$(ZLIB_LIB_VERSION)
ZLIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.so.$(ZLIB_LIB_VERSION)
ZLIB_TARGET_BINARY:=$(ZLIB_TARGET_DIR)/libz.so.$(ZLIB_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(ZLIB_DIR)/.configured: $(ZLIB_DIR)/.unpacked
	( cd $(ZLIB_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDSHARED="$(TARGET_CC) -shared -Wl,-soname,libz.so.1" \
		./configure \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--sysconfdir=/etc \
		--shared \
	);
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(ZLIB_DIR) \
	   libz.a libz.so

$(ZLIB_STAGING_BINARY): $(ZLIB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(ZLIB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(ZLIB_TARGET_BINARY): $(ZLIB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz*.so* $(ZLIB_TARGET_DIR)/
	$(TARGET_STRIP) $@

zlib: $(ZLIB_STAGING_BINARY)

zlib-precompiled: uclibc zlib $(ZLIB_TARGET_BINARY)

zlib-clean:
	-$(MAKE) -C $(ZLIB_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.* \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/zlib.h \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/zconf.h 	

zlib-uninstall:
	rm -f $(ZLIB_TARGET_DIR)/libz*.so*

$(PACKAGE_FINI)
