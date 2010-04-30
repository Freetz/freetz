$(call PKG_INIT_BIN,1.4)
$(PKG)_SOURCE:=bridge-utils-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/bridge
$(PKG)_BINARY:=$($(PKG)_DIR)/brctl/brctl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/brctl
$(PKG)_SOURCE_MD5:=0182fcac3a2b307113bbec34e5f1c673

$(PKG)_CONFIGURE_PRE_CMDS += ln -sf configure.in configure.ac;
$(PKG)_CONFIGURE_PRE_CMDS += autoconf > /dev/null 2>&1;

$(PKG)_CONFIGURE_OPTIONS += --with-linux-headers=$(KERNEL_HEADERS_DIR)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BRIDGE_UTILS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BRIDGE_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BRIDGE_UTILS_TARGET_BINARY)

$(PKG_FINISH)
