$(call PKG_INIT_BIN, 4.5.18)
$(PKG)_SOURCE:=strace-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=@SF/strace
$(PKG)_BINARY:=$($(PKG)_DIR)/strace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/strace
$(PKG)_SOURCE_MD5:=e9449fcee97e6a8ed73934c883c870e0 


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
