PACKAGE_LC:=openssl
PACKAGE_UC:=OPENSSL
$(PACKAGE_UC)_VERSION:=0.9.8e
$(PACKAGE_INIT_LIB)
OPENSSL_LIB_VERSION:=0.9.8
OPENSSL_SOURCE:=openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_SITE:=http://www.openssl.org/source/
OPENSSL_SSL_BINARY:=$(OPENSSL_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
OPENSSL_CRYPTO_BINARY:=$(OPENSSL_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION)
OPENSSL_STAGING_SSL_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl.so.$(OPENSSL_LIB_VERSION)
OPENSSL_STAGING_CRYPTO_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto.so.$(OPENSSL_LIB_VERSION)
OPENSSL_TARGET_SSL_BINARY:=$(OPENSSL_TARGET_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
OPENSSL_TARGET_CRYPTO_BINARY:=$(OPENSSL_TARGET_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION)

OPENSSL_NO_CIPHERS:= no-idea no-md2 no-mdc2 no-rc2 no-rc5 no-sha0 no-smime \
	no-rmd160 no-aes192 no-ripemd no-camellia no-ans1 no-krb5
OPENSSL_OPTIONS:= shared no-ec no-err no-fips no-hw no-threads no-engines \
	no-sse2 no-perlasm

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(OPENSSL_DIR)/.configured: $(OPENSSL_DIR)/.unpacked
	$(SED) -i -e 's/DS_MOD_OPTIMIZATION_FLAGS/$(TARGET_CFLAGS)/g' $(OPENSSL_DIR)/Configure
	( cd $(OPENSSL_DIR); \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		./Configure linux-ds-mod \
		--prefix=/usr \
		--openssldir=/mod/etc/ssl \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include \
		-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib \
		-ldl \
		-DOPENSSL_SMALL_FOOTPRINT \
		$(OPENSSL_NO_CIPHERS) \
		$(OPENSSL_OPTIONS) \
	);
	touch $@

$($(PACKAGE_UC)_SSL_BINARY) $($(PACKAGE_UC)_CRYPTO_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		SHARED_LDFLAGS="" \
		$(MAKE) -C $(OPENSSL_DIR) \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_CROSS)ar r" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		all build-shared
	# Work around openssl build bug to link libssl.so with libcrypto.so.
	-rm $(OPENSSL_DIR)/libssl.so.*.*.*
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(OPENSSL_DIR) \
		CC="$(TARGET_CC)" \
		CCOPTS="$(TARGET_CFLAGS) -fomit-frame-pointer" \
		do_linux-shared

$(OPENSSL_STAGING_SSL_BINARY) $(OPENSSL_STAGING_CRYPTO_BINARY): \
		$(OPENSSL_SSL_BINARY) $(OPENSSL_CRYPTO_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(OPENSSL_DIR) \
		INSTALL_PREFIX="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^prefix=.*,prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/\',g" \
	                 $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libcrypto.pc
	$(SED) -i -e "s,^prefix=.*,prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/\',g" \
	                 $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libssl.pc
	$(SED) -i -e "s,^prefix=.*,prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/\',g" \
	                 $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/openssl.pc

$(OPENSSL_TARGET_SSL_BINARY): $(OPENSSL_STAGING_SSL_BINARY) 
	# FIXME: Strange enough, this chmod is really necessary. Maybe the
	# previous 'install' can be parametrised differently fo fix this.
	chmod 755 $(OPENSSL_STAGING_SSL_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*.so* $(OPENSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(OPENSSL_TARGET_CRYPTO_BINARY): $(OPENSSL_STAGING_CRYPTO_BINARY)
	chmod 755 $(OPENSSL_STAGING_CRYPTO_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*.so* $(OPENSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

openssl: $(OPENSSL_STAGING_SSL_BINARY) $(OPENSSL_STAGING_CRYPTO_BINARY)

openssl-precompiled: uclibc zlib-precompiled openssl $(OPENSSL_TARGET_SSL_BINARY) $(OPENSSL_TARGET_CRYPTO_BINARY)

openssl-clean:
	-$(MAKE) -C $(OPENSSL_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/openssl
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/openssl

openssl-uninstall:
	rm -f $(OPENSSL_TARGET_DIR)/libssl*.so*
	rm -f $(OPENSSL_TARGET_DIR)/libcrypto*.so*

$(PACKAGE_FINI)
