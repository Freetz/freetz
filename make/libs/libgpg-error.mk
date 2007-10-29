PACKAGE_LC:=libgpg-error
PACKAGE_UC:=LIBGPG_ERROR
$(PACKAGE_UC)_VERSION:=1.1
$(PACKAGE_INIT_LIB)
LIBGPG_ERROR_LIB_VERSION:=0.1.4
LIBGPG_ERROR_SOURCE:=libgpg-error-$(LIBGPG_ERROR_VERSION).tar.gz
LIBGPG_ERROR_SITE:=http://ftp.gnupg.org/gcrypt/libgpg-error
LIBGPG_ERROR_BINARY:=$(LIBGPG_ERROR_DIR)/src/.libs/libgpg-error.so.$(LIBGPG_ERROR_LIB_VERSION)
LIBGPG_ERROR_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error.so.$(LIBGPG_ERROR_LIB_VERSION)
LIBGPG_ERROR_TARGET_BINARY:=$(LIBGPG_ERROR_TARGET_DIR)/libgpg-error.so.$(LIBGPG_ERROR_LIB_VERSION)


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)

$(LIBGPG_ERROR_DIR)/.configured: $(LIBGPG_ERROR_DIR)/.unpacked
	( cd $(LIBGPG_ERROR_DIR); rm -f config.{cache,status}; \
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
	);
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBGPG_ERROR_DIR)

$(LIBGPG_ERROR_STAGING_BINARY): $(LIBGPG_ERROR_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBGPG_ERROR_DIR) \
		prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		exec_prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		bindir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin \
		datadir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgpg-error.la

$(LIBGPG_ERROR_TARGET_BINARY): $(LIBGPG_ERROR_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error*.so* $(LIBGPG_ERROR_TARGET_DIR)/
	$(TARGET_STRIP) $@

libgpg-error: $(LIBGPG_ERROR_STAGING_BINARY)

libgpg-error-precompiled: uclibc libgpg-error $(LIBGPG_ERROR_TARGET_BINARY)

libgpg-error-clean:
	-$(MAKE) -C $(LIBGPG_ERROR_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error*

libgpg-error-uninstall:
	rm -f $(LIBGPG_ERROR_TARGET_DIR)/libgpg-error*.so*

$(PACKAGE_FINI)
