$(call PKG_INIT_BIN, 4.5.20)
$(PKG)_SOURCE:=strace-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=64dfe10d9db0c1e34030891695ffca4b
$(PKG)_SITE:=@SF/strace
$(PKG)_BINARY:=$($(PKG)_DIR)/strace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/strace

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(STRACE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STRACE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STRACE_TARGET_BINARY)

$(PKG_FINISH)
