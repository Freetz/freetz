$(call PKG_INIT_BIN, 0.8.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/htop
$(PKG)_BINARY:=$($(PKG)_DIR)/htop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/htop
$(PKG)_SOURCE_MD5:=5c9f093f9eaddf6e77aa6d54c2116d0c
$(PKG)_SOURCE_MD5:=5c9f093f9eaddf6e77aa6d54c2116d0c 

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_OPTIONS += ac_cv_file__proc_stat=yes
$(PKG)_CONFIGURE_OPTIONS += ac_cv_file__proc_meminfo=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(HTOP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(HTOP_DIR) clean
	$(RM) $(HTOP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HTOP_TARGET_BINARY)

$(PKG_FINISH)
