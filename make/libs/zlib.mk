ZLIB_VERSION:=1.2.3
ZLIB_LIB_VERSION:=$(ZLIB_VERSION)
ZLIB_SOURCE:=zlib-$(ZLIB_VERSION).tar.gz
ZLIB_SITE:=http://mesh.dl.sourceforge.net/sourceforge/libpng
ZLIB_MAKE_DIR:=$(MAKE_DIR)/libs
ZLIB_DIR:=$(SOURCE_DIR)/zlib-$(ZLIB_VERSION)
ZLIB_BINARY:=$(ZLIB_DIR)/libz.so.$(ZLIB_LIB_VERSION)
ZLIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.so.$(ZLIB_LIB_VERSION)
ZLIB_TARGET_DIR:=root/usr/lib
ZLIB_TARGET_BINARY:=$(ZLIB_TARGET_DIR)/libz.so.$(ZLIB_LIB_VERSION)

$(DL_DIR)/$(ZLIB_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(ZLIB_SITE)/$(ZLIB_SOURCE)

$(ZLIB_DIR)/.unpacked: $(DL_DIR)/$(ZLIB_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(ZLIB_SOURCE)
	for i in $(ZLIB_MAKE_DIR)/patches/*.zlib.patch; do \
		patch -d $(ZLIB_DIR) -p0 < $$i; \
	done
	touch $@

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

$(ZLIB_BINARY): $(ZLIB_DIR)/.configured
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

zlib-source: $(ZLIB_DIR)/.unpacked

zlib-clean:
	-$(MAKE) -C $(ZLIB_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.* \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/zlib.h \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/zconf.h 	

zlib-uninstall:
	rm -f $(ZLIB_TARGET_DIR)/libz*.so*

zlib-dirclean:
	rm -rf $(ZLIB_DIR)
