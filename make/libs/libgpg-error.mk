LIBGPG_ERROR_VERSION:=1.1
LIBGPG_ERROR_SOURCE:=libgpg-error-$(LIBGPG_ERROR_VERSION).tar.gz
LIBGPG_ERROR_SITE:=http://ftp.gnupg.org/gcrypt/libgpg-error
LIBGPG_ERROR_DIR:=$(SOURCE_DIR)/libgpg-error-$(LIBGPG_ERROR_VERSION)


$(DL_DIR)/$(LIBGPG_ERROR_SOURCE):
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

$(LIBGPG_ERROR_DIR)/.compiled: $(LIBGPG_ERROR_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBGPG_ERROR_DIR)
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error.so: $(LIBGPG_ERROR_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LIBGPG_ERROR_DIR) \
		prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		exec_prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		bindir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin \
		datadir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share \
		install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
libgpg-error libgpg-error-precompiled:
	@echo 'External compiler used. Trying to copy libgpg-error from external Toolchain...'
	cp -a $(TARGET_MAKE_PATH)/usr/lib/libgpg-error*.so* root/usr/lib/
else
libgpg-error: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error.so
libgpg-error-precompiled: libgpg-error
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error*.so* root/usr/lib/
endif

libgpg-error-source: $(LIBGPG_ERROR_DIR)/.unpacked

libgpg-error-clean:
	-$(MAKE) -C $(LIBGPG_ERROR_DIR) clean

libgpg-error-dirclean:
	rm -rf $(LIBGPG_ERROR_DIR)
