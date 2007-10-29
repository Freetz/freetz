PACKAGE_LC:=libiconv
PACKAGE_UC:=LIBICONV
$(PACKAGE_UC)_VERSION:=1.9.1
$(PACKAGE_INIT_LIB)
LIBICONV_LIB_VERSION:=2.2.0
LIBICONV_SOURCE:=libiconv-$(LIBICONV_VERSION).tar.gz
LIBICONV_SITE:=http://ftp.gnu.org/pub/gnu/libiconv
LIBICONV_BINARY:=$(LIBICONV_DIR)/lib/.libs/libiconv.so.$(LIBICONV_LIB_VERSION)
LIBICONV_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiconv.so.$(LIBICONV_LIB_VERSION)
LIBICONV_TARGET_BINARY:=$(LIBICONV_TARGET_DIR)/libiconv.so.$(LIBICONV_LIB_VERSION)


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(LIBICONV_DIR)/.configured: $(LIBICONV_DIR)/.unpacked
	( cd $(LIBICONV_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		CC="$(TARGET_CROSS)gcc" \
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
		--enable-shared \
		--enable-static \
		--disable-rpath \
		--with-gnu-ld \
	);
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBICONV_DIR) \
		CC="$(TARGET_CROSS)gcc"

$(LIBICONV_STAGING_BINARY): $(LIBICONV_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBICONV_DIR) \
		includedir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		libdir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		all install-lib
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libiconv.la

$(LIBICONV_TARGET_BINARY): $(LIBICONV_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiconv*.so* $(LIBICONV_TARGET_DIR)/
	$(TARGET_STRIP) $@

libiconv: $(LIBICONV_STAGING_BINARY)

libiconv-precompiled: uclibc libiconv $(LIBICONV_TARGET_BINARY)

libiconv-clean:
	-$(MAKE) -C $(LIBICONV_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiconv*

libiconv-uninstall:
	rm -f $(LIBICONV_TARGET_DIR)/libiconv*.so*

$(PACKAGE_FINI)
