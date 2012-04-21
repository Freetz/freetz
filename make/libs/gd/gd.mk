$(call PKG_INIT_LIB, 2.0.36~rc1)
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=libgd2_$($(PKG)_VERSION)~dfsg.orig.tar.gz
$(PKG)_SOURCE_MD5:=0f4d2fa45627af0e87fcb74f653b66dd
$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/libg/libgd2

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/libgd2_$($(PKG)_VERSION)~dfsg.orig

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgd.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := jpeg libpng freetype

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-x=no
$(PKG)_CONFIGURE_OPTIONS += --with-xpm=no
$(PKG)_CONFIGURE_OPTIONS += --with-fontconfig=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GD_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(GD_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		includedir=/usr/include/gd \
		install-libLTLIBRARIES install-includeHEADERS install-binSCRIPTS
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gdlib-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GD_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/gd \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/gdlib-config

$(pkg)-uninstall:
	$(RM) $(GD_TARGET_DIR)/libgd*.so*

$(PKG_FINISH)
