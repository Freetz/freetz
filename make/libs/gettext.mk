$(eval $(call PKG_INIT_LIB, 0.16.1))
$(PKG)_LIB_VERSION:=8.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gnu.org/gnu/gettext/
$(PKG)_BINARY:=$($(PKG)_DIR)/gettext-runtime/intl/.libs/libintl.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libintl.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-nls                   
$(PKG)_CONFIGURE_OPTIONS += --disable-java                 
$(PKG)_CONFIGURE_OPTIONS += --disable-native-java          
$(PKG)_CONFIGURE_OPTIONS += --disable-openmp         
$(PKG)_CONFIGURE_OPTIONS += --with-included-gettext  
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix 
$(PKG)_CONFIGURE_OPTIONS += --without-libexpat-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-emacs          


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

# We only want libintl
$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GETTEXT_DIR)/gettext-runtime/intl \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GETTEXT_DIR)/gettext-runtime/intl \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libintl.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl*.so* $(GETTEXT_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: uclibc $(pkg) $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GETTEXT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgettext*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl*

$(pkg)-uninstall:
	rm -f $(GETTEXT_TARGET_DIR)/libintl*.so*

$(PKG_FINISH)