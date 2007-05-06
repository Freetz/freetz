ZLIB_VERSION:=1.2.3
ZLIB_SOURCE:=zlib-$(ZLIB_VERSION).tar.gz
ZLIB_SITE:=http://mesh.dl.sourceforge.net/sourceforge/libpng
ZLIB_DIR:=$(SOURCE_DIR)/zlib-$(ZLIB_VERSION)
ZLIB_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(ZLIB_SOURCE):
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
		CFLAGS="$(TARGET_CFLAGS) $(CFLAGS_LARGEFILE)" \
		LDSHARED="$(TARGET_CC) -static-libgcc -shared -Wl,-soname,libz.so.1" \
		./configure \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--sysconfdir=/etc \
		--shared \
	);
	touch $@

$(ZLIB_DIR)/.compiled: $(ZLIB_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(ZLIB_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(CFLAGS_LARGEFILE)" \
		libz.a libz.so
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.so: $(ZLIB_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(ZLIB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
zlib zlib-precompiled:
	@echo 'External compiler used. Trying to copy libz from external Toolchain...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libz*.so* root/usr/lib/
else
zlib: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.so
zlib-precompiled: uclibc zlib
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz*.so* root/usr/lib/
endif

zlib-source: $(ZLIB_DIR)/.unpacked

zlib-clean:
	-$(MAKE) -C $(ZLIB_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz*
	rm -rf root/usr/lib/libz*.so* 
	
zlib-dirclean:
	rm -rf $(ZLIB_DIR)
