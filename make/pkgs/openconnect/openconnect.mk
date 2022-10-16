$(call PKG_INIT_BIN, 7.04)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=baac1fdf8f5f9debe1f91a2f3ca6895cf24ef0f8b2d8c2c67f5ce6789f28663b
$(PKG)_SITE:=ftp://ftp.infradead.org/pub/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)
$(PKG)_STARTLEVEL=81

$(PKG)_DEPENDS_ON += libxml2 openssl zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENCONNECT_STATIC

$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --with-vpnc-script=/mod/etc/vpnc/vpnc-script
$(PKG)_LDFLAGS +=$(if $(FREETZ_PACKAGE_OPENCONNECT_STATIC),-all-static)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENCONNECT_DIR) openconnect \
		LDFLAGS="$(OPENCONNECT_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENCONNECT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OPENCONNECT_TARGET_BINARY)

$(PKG_FINISH)
