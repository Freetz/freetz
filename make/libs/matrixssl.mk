PACKAGE_LC:=matrixssl
PACKAGE_UC:=MATRIXSSL
$(PACKAGE_UC)_VERSION:=1.7.3
$(PACKAGE_INIT_LIB)
#MATRIXSSL_VERSION:=1-8-3
#MATRIXSSL_SOURCE:=matrixssl-$(MATRIXSSL_VERSION)-open.tar.gz
MATRIXSSL_SOURCE:=matrixssl-$(MATRIXSSL_VERSION).tar.gz
MATRIXSSL_SITE:=http://downloads.openwrt.org/sources
MATRIXSSL_DIR:=$(SOURCE_DIR)/matrixssl
MATRIXSSL_BINARY:=$(MATRIXSSL_DIR)/src/libmatrixssl.so
MATRIXSSL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl.so
MATRIXSSL_TARGET_BINARY:=$(MATRIXSSL_TARGET_DIR)/libmatrixssl.so

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(MATRIXSSL_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLINUX" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		AR="$(TARGET_CROSS)ar" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		STRIP="$(TARGET_CROSS)strip" 

$(MATRIXSSL_STAGING_BINARY): $(MATRIXSSL_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp -a $(MATRIXSSL_DIR)/src/libmatrixssl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	cp $(MATRIXSSL_DIR)/src/libmatrixsslstatic.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl
	cp $(MATRIXSSL_DIR)/matrixSsl.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl
	ln -sf matrixSsl/matrixSsl.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl.h

$(MATRIXSSL_TARGET_BINARY): $(MATRIXSSL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl*.so* $(MATRIXSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

matrixssl: $(MATRIXSSL_STAGING_BINARY)

matrixssl-precompiled: uclibc uclibc matrixssl $(MATRIXSSL_TARGET_BINARY)

matrixssl-clean:
	-$(MAKE) -C $(MATRIXSSL_DIR)/src clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl*

matrixssl-uninstall:
	rm -f $(MATRIXSSL_TARGET_DIR)/libmatrixssl*.so*

$(PACKAGE_FINI)
