$(call PKG_INIT_BIN, 0.10.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3a155a770cc2e05fc3af452731d48954
$(PKG)_SITE:=@SF/synce

$(PKG)_INSTALL_DIR:=/usr/sbin
$(PKG)_BINARY:=$($(PKG)_DIR)/src/synce-serial-chat
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$($(PKG)_INSTALL_DIR)/synce-serial-chat

$(PKG)_SCRIPTS:=synce-serial-abort synce-serial-config synce-serial-start synce-serial-common
$(PKG)_SCRIPTS_BUILD_DIR:=$($(PKG)_SCRIPTS:%=$($(PKG)_DIR)/script/%)
$(PKG)_SCRIPTS_TARGET_DIR:=$($(PKG)_SCRIPTS:%=$($(PKG)_DEST_DIR)$($(PKG)_INSTALL_DIR)/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $(SYNCE_SERIAL_DIR)/.configured
	$(SUBMAKE) -C $(SYNCE_SERIAL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SCRIPTS_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_INSTALL_DIR)/%: $($(PKG)_DIR)/script/%
	$(INSTALL_BINARY)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_SCRIPTS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SYNCE_SERIAL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SYNCE_SERIAL_TARGET_BINARY)

$(PKG_FINISH)
