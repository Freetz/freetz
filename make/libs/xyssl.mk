PACKAGE_LC:=xyssl
PACKAGE_UC:=XYSSL
$(PACKAGE_UC)_VERSION:=0.7
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_SOURCE:=xyssl-$($(PACKAGE_UC)_VERSION).tgz
$(PACKAGE_UC)_SITE:=http://www.xyssl.org/code/download
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/library/libxyssl.so
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl.so
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libxyssl.so

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(XYSSL_DIR)/library \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLINUX -I../include" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		AR="$(TARGET_CROSS)ar" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		STRIP="$(TARGET_CROSS)strip" \
		shared

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp -a $(XYSSL_DIR)/library/libxyssl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
	cp -a $(XYSSL_DIR)/include/xyssl $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl*.so* $(XYSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

xyssl: $($(PACKAGE_UC)_STAGING_BINARY)

xyssl-precompiled: uclibc uclibc xyssl $($(PACKAGE_UC)_TARGET_BINARY)

xyssl-clean:
	-$(MAKE) -C $(XYSSL_DIR)/library clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/xyssl*

xyssl-uninstall:
	rm -f $(XYSSL_TARGET_DIR)/libxyssl*.so*

$(PACKAGE_FINI)
