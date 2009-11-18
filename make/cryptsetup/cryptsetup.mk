$(call PKG_INIT_BIN, 1.0.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://cryptsetup.googlecode.com/files
$(PKG)_BINARY:=$($(PKG)_DIR)/src/cryptsetup
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/cryptsetup
$(PKG)_SOURCE_MD5:=00d452eb7a76e39f5749545d48934a10

$(PKG)_DEPENDS_ON := devmapper e2fsprogs popt

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;

$(PKG)_CONFIGURE_OPTIONS += --disable-libgcrypt
$(PKG)_CONFIGURE_OPTIONS += --enable-libdevmapper
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-shared-library
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CRYPTSETUP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CRYPTSETUP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CRYPTSETUP_TARGET_BINARY)

$(PKG_FINISH)
