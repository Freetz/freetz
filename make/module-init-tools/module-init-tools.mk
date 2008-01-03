$(call PKG_INIT_BIN,3.3-pre11)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.kernel.org/pub/linux/kernel/people/jcm/module-init-tools
$(PKG)_BINARY:=$($(PKG)_DIR)/modinfo
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/modinfo

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MODULE_INIT_TOOLS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(MODULE_INIT_TOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNS2TCP_TARGET_BINARY)

$(PKG_FINISH)
