XYSSL_VERSION:=0.7
XYSSL_SOURCE:=xyssl-$(XYSSL_VERSION).tgz
XYSSL_SITE:=http://www.xyssl.org/code/download
XYSSL_MAKE_DIR:=$(MAKE_DIR)/libs
XYSSL_DIR:=$(SOURCE_DIR)/xyssl-$(XYSSL_VERSION)
XYSSL_BINARY:=$(XYSSL_DIR)/library/libxyssl.so
XYSSL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl.so
XYSSL_TARGET_DIR:=root/usr/lib
XYSSL_TARGET_BINARY:=$(XYSSL_TARGET_DIR)/libxyssl.so

$(DL_DIR)/$(XYSSL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(XYSSL_SITE)/$(XYSSL_SOURCE)

$(XYSSL_DIR)/.unpacked: $(DL_DIR)/$(XYSSL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(XYSSL_SOURCE)
	for i in $(XYSSL_MAKE_DIR)/patches/*.xyssl.patch; do \
		$(PATCH_TOOL) $(XYSSL_DIR) $$i; \
	done
	touch $@

$(XYSSL_BINARY): $(XYSSL_DIR)/.unpacked
	$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) -C $(XYSSL_DIR)/library \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLINUX -I../include" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		AR="$(TARGET_CROSS)ar" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		STRIP="$(TARGET_CROSS)strip" \
		shared

$(XYSSL_STAGING_BINARY): $(XYSSL_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp -a $(XYSSL_DIR)/library/libxyssl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
	cp -a $(XYSSL_DIR)/include/xyssl $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/

$(XYSSL_TARGET_BINARY): $(XYSSL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl*.so* $(XYSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

xyssl: $(XYSSL_STAGING_BINARY)

xyssl-precompiled: uclibc uclibc xyssl $(XYSSL_TARGET_BINARY)

xyssl-source: $(XYSSL_DIR)/.unpacked

xyssl-clean:
	-$(MAKE) -C $(XYSSL_DIR)/library clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/xyssl*

xyssl-uninstall:
	rm -f $(XYSSL_TARGET_DIR)/libxyssl*.so*

xyssl-dirclean: 
	rm -rf $(XYSSL_DIR)
