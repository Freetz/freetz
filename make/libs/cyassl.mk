PACKAGE_LC:=cyassl
PACKAGE_UC:=CYASSL
$(PACKAGE_UC)_VERSION:=0.8.5
$(PACKAGE_INIT_LIB)
CYASSL_SOURCE:=cyassl-$(CYASSL_VERSION).zip
CYASSL_SITE:=http://yassl.com
CYASSL_BINARY:=$(CYASSL_DIR)/src/.libs/libcyassl.so
CYASSL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl.so
CYASSL_TARGET_BINARY:=$(CYASSL_TARGET_DIR)/libcyassl.so

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(CYASSL_DIR)/.configured: $(CYASSL_DIR)/.unpacked
	( cd $(CYASSL_DIR); rm -f config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
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
		--enable-opensslExtra \
	);
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(CYASSL_DIR)

$(CYASSL_STAGING_BINARY): $(CYASSL_BINARY)
	cp -a $(CYASSL_DIR)/src/.libs/libcyassl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/

$(CYASSL_TARGET_BINARY): $(CYASSL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*.so* $(CYASSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

cyassl: $(CYASSL_STAGING_BINARY)

cyassl-precompiled: uclibc cyassl $(CYASSL_TARGET_BINARY)

cyassl-clean:
	-$(MAKE) -C $(CYASSL_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cyassl*

cyassl-uninstall:
	rm -f $(CYASSL_TARGET_DIR)/libcyassl*.so*

$(PACKAGE_FINI)
