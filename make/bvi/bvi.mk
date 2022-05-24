$(call PKG_INIT_BIN, 1.4.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).src.tar.gz
$(PKG)_HASH:=015a3c2832c7c097d98a5527deef882119546287ba8f2a70c736227d764ef802
$(PKG)_SITE:=@SF/bvi

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_BINARIES_ALL := bvi bmore
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_BVI_bvi),,$($(PKG)_DEST_DIR)/usr/bin/bview)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BVI_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(BVI_DEST_DIR)/usr/bin/bview: $(BVI_DEST_DIR)/usr/bin/bvi
	ln -sf $(notdir $<) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $(if $(FREETZ_PACKAGE_BVI_bvi),$($(PKG)_DEST_DIR)/usr/bin/bview)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BVI_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BVI_BINARIES_ALL:%=$(BVI_DEST_DIR)/usr/bin/%) $(BVI_DEST_DIR)/usr/bin/bview

$(PKG_FINISH)
