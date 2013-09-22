$(call PKG_INIT_BIN, 0.9.32)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=18e2208aea6d772d1670c1a648bb6b77
$(PKG)_SITE:=@SF/haserl

$(PKG)_BINARY:=$($(PKG)_DIR)/src/haserl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/haserl

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HASERL_WITH_LUA

ifeq ($(strip $(FREETZ_PACKAGE_HASERL_WITH_LUA)),y)
$(PKG)_DEPENDS_ON := lua
$(PKG)_CONFIGURE_OPTIONS += --enable-luashell
$(PKG)_CONFIGURE_OPTIONS += --enable-luacshell
$(PKG)_CONFIGURE_OPTIONS += --with-lua
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HASERL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HASERL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HASERL_TARGET_BINARY)

$(PKG_FINISH)
