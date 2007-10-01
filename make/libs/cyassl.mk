CYASSL_VERSION:=0.8.5
CYASSL_SOURCE:=cyassl-$(CYASSL_VERSION).zip
CYASSL_SITE:=http://yassl.com
CYASSL_MAKE_DIR:=$(MAKE_DIR)/libs
CYASSL_DIR:=$(SOURCE_DIR)/cyassl-$(CYASSL_VERSION)
CYASSL_BINARY:=$(CYASSL_DIR)/src/.libs/libcyassl.so
CYASSL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl.so
CYASSL_TARGET_DIR:=root/usr/lib
CYASSL_TARGET_BINARY:=$(CYASSL_TARGET_DIR)/libcyassl.so

$(DL_DIR)/$(CYASSL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(CYASSL_SITE)/$(CYASSL_SOURCE)

$(CYASSL_DIR)/.unpacked: $(DL_DIR)/$(CYASSL_SOURCE)
	unzip -d $(SOURCE_DIR) $(DL_DIR)/$(CYASSL_SOURCE)
	#for i in $(CYASSL_MAKE_DIR)/patches/*.cyassl.patch; do \
	#	$(PATCH_TOOL) $(CYASSL_DIR) $$i; \
	#done
	touch $@

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

$(CYASSL_BINARY): $(CYASSL_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(CYASSL_DIR)

$(CYASSL_STAGING_BINARY): $(CYASSL_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp -a $(CYASSL_DIR)/src/.libs/libcyassl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/

$(CYASSL_TARGET_BINARY): $(CYASSL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*.so* $(CYASSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

cyassl: $(CYASSL_STAGING_BINARY)

cyassl-precompiled: uclibc cyassl $(CYASSL_TARGET_BINARY)

cyassl-source: $(CYASSL_DIR)/.unpacked

cyassl-clean:
	-$(MAKE) -C $(CYASSL_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cyassl*

cyassl-uninstall:
	rm -f $(CYASSL_TARGET_DIR)/libcyassl*.so*

cyassl-dirclean: 
	rm -rf $(CYASSL_DIR)
