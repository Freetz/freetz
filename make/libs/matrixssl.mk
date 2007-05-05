#MATRIXSSL_VERSION:=1-8-3
MATRIXSSL_VERSION:=1.7.3
#MATRIXSSL_SOURCE:=matrixssl-$(MATRIXSSL_VERSION)-open.tar.gz
MATRIXSSL_SOURCE:=matrixssl-$(MATRIXSSL_VERSION).tar.gz
MATRIXSSL_SITE:=http://downloads.openwrt.org/sources
MATRIXSSL_DIR:=$(SOURCE_DIR)/matrixssl
MATRIXSSL_MAKE_DIR:=$(MAKE_DIR)/libs

$(DL_DIR)/$(MATRIXSSL_SOURCE):
	wget -P $(DL_DIR) $(MATRIXSSL_SITE)/$(MATRIXSSL_SOURCE)

$(MATRIXSSL_DIR)/.unpacked: $(DL_DIR)/$(MATRIXSSL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MATRIXSSL_SOURCE)
#	for i in $(MATRIXSSL_MAKE_DIR)/patches/*.matrixssl.patch; do \
#		patch -d $(MATRIXSSL_DIR) -p1 < $$i; \
#	done
	touch $@

$(MATRIXSSL_DIR)/.compiled: $(MATRIXSSL_DIR)/.unpacked
	$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) -C $(MATRIXSSL_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLINUX" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
		AR="$(TARGET_CROSS)ar" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		STRIP="$(TARGET_CROSS)strip" 
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl.so: $(MATRIXSSL_DIR)/.compiled
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp $(MATRIXSSL_DIR)/src/libmatrixssl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp $(MATRIXSSL_DIR)/src/libmatrixsslstatic.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl
	cp $(MATRIXSSL_DIR)/matrixSsl.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl
	ln -sf matrixSsl/matrixSsl.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl.h
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
matrixssl matrixssl-precompiled:
	@echo 'External compiler used. Skipping matrixssl...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libmatrixssl.so* root/usr/lib/
else
matrixssl: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl.so
matrixssl-precompiled: uclibc uclibc matrixssl
	chmod 0644 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl.so*
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl.so*
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libmatrixssl.so* root/usr/lib/
endif

matrixssl-source: $(MATRIXSSL_DIR)/.unpacked

matrixssl-clean:
	-$(MAKE) -C $(MATRIXSSL_DIR)/src clean

matrixssl-dirclean: matrixssl-stagingclean
	rm -rf $(MATRIXSSL_DIR)

matrixssl-stagingclean:
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl*.so*
	rm -f $(MATRIXSSL_DIR)/.installed

