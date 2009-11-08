$(call PKG_INIT_BIN,3.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.kernel.org/pub/linux/utils/kernel/module-init-tools
$(PKG)_BINARY:=$($(PKG)_DIR)/modinfo
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/modinfo
$(PKG)_SOURCE_MD5:=db6ac059e80e8dd4389dbe81ee61f3c6 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(MODULE_INIT_TOOLS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MODULE_INIT_TOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MODULE_INIT_TOOLS_TARGET_BINARY)

$(PKG_FINISH)
