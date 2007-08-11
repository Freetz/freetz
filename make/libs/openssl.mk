OPENSSL_VERSION:=0.9.8b
OPENSSL_SOURCE:=openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_SITE:=http://www.openssl.org/source/
OPENSSL_DIR:=$(SOURCE_DIR)/openssl-$(OPENSSL_VERSION)
OPENSSL_MAKE_DIR:=$(MAKE_DIR)/libs

OPENSSL_NO_CIPHERS:=no-idea no-md2 no-mdc2 no-rc5 no-sha0 no-rmd160 no-aes192
OPENSSL_OPTIONS:=shared no-ec no-err no-fips no-hw no-krb5 no-threads no-zlib no-engines
# zlib-dynamic


$(DL_DIR)/$(OPENSSL_SOURCE):
	wget -P $(DL_DIR) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

$(OPENSSL_DIR)/.unpacked: $(DL_DIR)/$(OPENSSL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(OPENSSL_SOURCE)
	for i in $(OPENSSL_MAKE_DIR)/patches/*.openssl.patch; do \
		patch -d $(OPENSSL_DIR) -p0 < $$i; \
	done
	touch $@

$(OPENSSL_DIR)/.configured: $(OPENSSL_DIR)/.unpacked
	sed -i -e 's/DS_MOD_OPTIMIZATION_FLAGS/$(TARGET_CFLAGS)/g' $(OPENSSL_DIR)/Configure
	( cd $(OPENSSL_DIR); \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		./Configure linux-ds-mod \
		--prefix=/usr \
		--openssldir=/mod/etc/ssl \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include \
		-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib -ldl -static-libgcc \
		-DOPENSSL_SMALL_FOOTPRINT \
		$(CFLAGS_LARGEFILE) \
		$(OPENSSL_NO_CIPHERS) \
		$(OPENSSL_OPTIONS) \
	);
	touch $@

$(OPENSSL_DIR)/.compiled: $(OPENSSL_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(OPENSSL_DIR) \
		MAKEDEPPROG="$(TARGET_CC)" \
		depend
	PATH=$(TARGET_TOOLCHAIN_PATH) SHARED_LDFLAGS=-static-libgcc $(MAKE) \
		-C $(OPENSSL_DIR) \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_CROSS)ar r" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		all build-shared
	# Work around openssl build bug to link libssl.so with libcrypto.so.
	-rm $(OPENSSL_DIR)/libssl.so.*.*.*
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(OPENSSL_DIR) \
		CC="$(TARGET_CC)" \
		CCOPTS="$(TARGET_CFLAGS) -fomit-frame-pointer" \
		do_linux-shared
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl.so: $(OPENSSL_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(OPENSSL_DIR) \
		INSTALL_PREFIX="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
openssl openssl-precompiled:
	@echo 'External compiler used. Skipping openssl...'
else
openssl: uclibc $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl.so
openssl-precompiled: openssl
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*.so*
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*.so*
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*.so*
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*.so* root/usr/lib/
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*.so* root/usr/lib/
endif

openssl-source: $(OPENSSL_DIR)/.unpacked

openssl-clean:
	-$(MAKE) -C $(OPENSSL_DIR) clean

openssl-dirclean:
	rm -rf $(OPENSSL_DIR)
