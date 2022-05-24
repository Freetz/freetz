$(call PKG_INIT_LIB, 1.02.27)
$(PKG)_LIB_VERSION:=1.02
$(PKG)_SOURCE:=devmapper_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_HASH:=df062f70a57ca98294ee69f8ebe25fc49b7f27752f3add4620692fece369a25a
$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/d/devmapper

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/ioctl/libdevmapper.so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdevmapper.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libdevmapper.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-pkgconfig
$(PKG)_CONFIGURE_OPTIONS += --with-user=""
$(PKG)_CONFIGURE_OPTIONS += --with-group=""
$(PKG)_CONFIGURE_OPTIONS += --with-optimisation=""
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DEVMAPPER_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(DEVMAPPER_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/devmapper.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DEVMAPPER_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdevmapper.*

$(pkg)-uninstall:
	$(RM) $(DEVMAPPER_TARGET_DIR)/libdevmapper*.so*

$(PKG_FINISH)
