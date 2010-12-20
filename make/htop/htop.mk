$(call PKG_INIT_BIN, 0.9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=7c5507f35f363f3f40183a2ba3c561f8
$(PKG)_SITE:=@SF/htop

$(PKG)_BINARY:=$($(PKG)_DIR)/htop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/htop

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_OPTIONS += ac_cv_file__proc_stat=yes
$(PKG)_CONFIGURE_OPTIONS += ac_cv_file__proc_meminfo=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HTOP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HTOP_DIR) clean
	$(RM) $(HTOP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HTOP_TARGET_BINARY)

$(PKG_FINISH)
