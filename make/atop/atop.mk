$(call PKG_INIT_BIN, 2.2-3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=034dc1544f2ec4e4d2c739d320dc326d
$(PKG)_SITE:=http://www.atoptool.nl/download

$(PKG)_BINARY:=$($(PKG)_DIR)/atop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/atop

$(PKG)_DEPENDS_ON += zlib ncurses

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ATOP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -Wall" \
		atop

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ATOP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(ATOP_TARGET_BINARY)

$(PKG_FINISH)
