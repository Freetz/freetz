LIBGCRYPT_VERSION:=1.2.2
LIBGCRYPT_SOURCE:=libgcrypt-$(LIBGCRYPT_VERSION).tar.gz
LIBGCRYPT_SITE:=http://ftp.gnupg.org/gcrypt/libgcrypt
LIBGCRYPT_DIR:=$(SOURCE_DIR)/libgcrypt-$(LIBGCRYPT_VERSION)
LIBGCRYPT_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(LIBGCRYPT_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LIBGCRYPT_SITE)/$(LIBGCRYPT_SOURCE)

$(LIBGCRYPT_DIR)/.unpacked: $(DL_DIR)/$(LIBGCRYPT_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBGCRYPT_SOURCE)
	for i in $(LIBGCRYPT_MAKE_DIR)/patches/*.libgcrypt.patch; do \
		patch -d $(LIBGCRYPT_DIR) -p0 < $$i; \
	done
	touch $@

$(LIBGCRYPT_DIR)/.configured: $(LIBGCRYPT_DIR)/.unpacked 
	( cd $(LIBGCRYPT_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		CC="$(TARGET_CC) -static-libgcc" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--enable-shared \
		--enable-static \
		--disable-asm \
		--with-gpg-error-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
	);
	touch $@

$(LIBGCRYPT_DIR)/.compiled: $(LIBGCRYPT_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBGCRYPT_DIR)
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt.so: $(LIBGCRYPT_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBGCRYPT_DIR) \
		prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		exec_prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		bindir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin \
		datadir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share \
		install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
libgcrypt libgcrypt-precompiled:
	@echo 'External compiler used. Skipping libgcrypt...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libgcrypt*.so* root/usr/lib/
else
libgcrypt: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt.so
libgcrypt-precompiled: uclibc libgcrypt
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*.so* root/usr/lib/
endif

libgcrypt-source: $(LIBGCRYPT_DIR)/.unpacked

libgcrypt-clean:
	-$(MAKE) -C $(LIBGCRYPT_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*
	rm -rf root/usr/lib/libgcrypt*.so*

libgcrypt-dirclean:
	rm -rf $(LIBGCRYPT_DIR)
