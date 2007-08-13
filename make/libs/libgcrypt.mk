LIBGCRYPT_VERSION:=1.2.2
LIBGCRYPT_LIB_VERSION:=11.2.1
LIBGCRYPT_SOURCE:=libgcrypt-$(LIBGCRYPT_VERSION).tar.gz
LIBGCRYPT_SITE:=http://ftp.gnupg.org/gcrypt/libgcrypt
LIBGCRYPT_MAKE_DIR:=$(MAKE_DIR)/libs
LIBGCRYPT_DIR:=$(SOURCE_DIR)/libgcrypt-$(LIBGCRYPT_VERSION)
LIBGCRYPT_BINARY:=$(LIBGCRYPT_DIR)/src/.libs/libgcrypt.so.$(LIBGCRYPT_LIB_VERSION)
LIBGCRYPT_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt.so.$(LIBGCRYPT_LIB_VERSION)
LIBGCRYPT_TARGET_DIR:=root/usr/lib
LIBGCRYPT_TARGET_BINARY:=$(LIBGCRYPT_TARGET_DIR)/libgcrypt.so.$(LIBGCRYPT_LIB_VERSION)


$(DL_DIR)/$(LIBGCRYPT_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LIBGCRYPT_SITE)/$(LIBGCRYPT_SOURCE)

$(LIBGCRYPT_DIR)/.unpacked: $(DL_DIR)/$(LIBGCRYPT_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBGCRYPT_SOURCE)
	for i in $(LIBGCRYPT_MAKE_DIR)/patches/*.libgcrypt.patch; do \
		$(PATCH_TOOL) $(LIBGCRYPT_DIR) $$i; \
	done
	touch $@

$(LIBGCRYPT_DIR)/.configured: $(LIBGCRYPT_DIR)/.unpacked 
	( cd $(LIBGCRYPT_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		CC="$(TARGET_CC)" \
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

$(LIBGCRYPT_BINARY): $(LIBGCRYPT_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBGCRYPT_DIR)

$(LIBGCRYPT_STAGING_BINARY): $(LIBGCRYPT_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBGCRYPT_DIR) \
		prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		exec_prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		bindir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin \
		datadir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgcrypt.la

$(LIBGCRYPT_TARGET_BINARY): $(LIBGCRYPT_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*.so* $(LIBGCRYPT_TARGET_DIR)/
	$(TARGET_STRIP) $@

libgcrypt: $(LIBGCRYPT_STAGING_BINARY)

libgcrypt-precompiled: uclibc libgcrypt $(LIBGCRYPT_TARGET_BINARY)

libgcrypt-source: $(LIBGCRYPT_DIR)/.unpacked

libgcrypt-clean:
	-$(MAKE) -C $(LIBGCRYPT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*

libgcrypt-uninstall:
	rm -f $(LIBGCRYPT_TARGET_DIR)/libgcrypt*.so*

libgcrypt-dirclean:
	rm -rf $(LIBGCRYPT_DIR)
