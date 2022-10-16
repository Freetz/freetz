$(call PKG_INIT_BIN, 0.7.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=30719c9a4ffbcf15676b8f528233ccc54ee6cba96cb4590975f5fd60c68a066f
$(PKG)_SITE:=@SF/netcat
$(PKG)_BINARY:=$($(PKG)_DIR)/src/netcat
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/netcat

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-included-getopt

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NETCAT_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NETCAT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NETCAT_TARGET_BINARY)

$(PKG_FINISH)
