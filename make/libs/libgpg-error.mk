LIBGPG_ERROR_VERSION:=1.1
LIBGPG_ERROR_LIB_VERSION:=0.1.4
LIBGPG_ERROR_SOURCE:=libgpg-error-$(LIBGPG_ERROR_VERSION).tar.gz
LIBGPG_ERROR_SITE:=http://ftp.gnupg.org/gcrypt/libgpg-error
LIBGPG_ERROR_DIR:=$(SOURCE_DIR)/libgpg-error-$(LIBGPG_ERROR_VERSION)
LIBGPG_ERROR_BINARY:=$(LIBGPG_ERROR_DIR)/src/.libs/libgpg-error.so.$(LIBGPG_ERROR_LIB_VERSION)
LIBGPG_ERROR_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error.so.$(LIBGPG_ERROR_LIB_VERSION)
LIBGPG_ERROR_TARGET_DIR:=root/usr/lib
LIBGPG_ERROR_TARGET_BINARY:=$(LIBGPG_ERROR_TARGET_DIR)/libgpg-error.so.$(LIBGPG_ERROR_LIB_VERSION)


$(DL_DIR)/$(LIBGPG_ERROR_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LIBGPG_ERROR_SITE)/$(LIBGPG_ERROR_SOURCE)

$(LIBGPG_ERROR_DIR)/.unpacked: $(DL_DIR)/$(LIBGPG_ERROR_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LIBGPG_ERROR_SOURCE)
	touch $@

$(LIBGPG_ERROR_DIR)/.configured: $(LIBGPG_ERROR_DIR)/.unpacked
	( cd $(LIBGPG_ERROR_DIR); rm -f config.{cache,status}; \
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
	);
	touch $@

$(LIBGPG_ERROR_BINARY): $(LIBGPG_ERROR_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBGPG_ERROR_DIR)

$(LIBGPG_ERROR_STAGING_BINARY): $(LIBGPG_ERROR_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBGPG_ERROR_DIR) \
		prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		exec_prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		bindir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin \
		datadir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share \
		install

$(LIBGPG_ERROR_TARGET_BINARY): $(LIBGPG_ERROR_STAGING_BINARY)
	$(TARGET_STRIP) $(LIBGPG_ERROR_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error*.so* $(LIBGPG_ERROR_TARGET_DIR)/

libgpg-error: $(LIBGPG_ERROR_STAGING_BINARY)

libgpg-error-precompiled: uclibc libgpg-error $(LIBGPG_ERROR_TARGET_BINARY)

libgpg-error-source: $(LIBGPG_ERROR_DIR)/.unpacked

libgpg-error-clean:
	-$(MAKE) -C $(LIBGPG_ERROR_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error*

libgpg-error-uninstall:
	rm -f $(LIBGPG_ERROR_TARGET_DIR)/libgpg-error*.so*

libgpg-error-dirclean:
	rm -rf $(LIBGPG_ERROR_DIR)
