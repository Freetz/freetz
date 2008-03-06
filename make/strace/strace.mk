$(call PKG_INIT_BIN, 4.5.16)
$(PKG)_SOURCE:=strace-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/strace
$(PKG)_BINARY:=$($(PKG)_DIR)/strace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/strace


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(STRACE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(STRACE_DIR) clean

$(pkg)-uninstall:
	rm -f $(STRACE_TARGET_BINARY)

$(PKG_FINISH)
