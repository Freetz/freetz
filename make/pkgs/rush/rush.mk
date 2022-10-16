$(call PKG_INIT_BIN, 1.7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=56ce434639d69817dd667d5243c49045f46101583ca9e0983f176d8b92eca301
$(PKG)_SITE:=@GNU/$(pkg)
$(PKG)_BINARIES:=$(pkg) $(pkg)last $(pkg)who
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(RUSH_DIR) all

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RUSH_DIR) clean
	$(RM) $(RUSH_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(RUSH_BINARIES_TARGET_DIR)

$(PKG_FINISH)
