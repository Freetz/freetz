$(call PKG_INIT_BIN,0.2.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/hp-levels
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/hp-levels

$(PKG)_DEPENDS_ON:= hplip

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(HP_UTILS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(HP_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HP_UTILS_TARGET_BINARY)

$(PKG_FINISH)
